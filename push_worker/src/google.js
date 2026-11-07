import { importPKCS8, SignJWT } from 'jose';

// All Firestore and FCM calls of the worker. Everything else is plain logic
// that can be tested without a network.

const TOKEN_URL = 'https://oauth2.googleapis.com/token';
const SCOPES = [
  'https://www.googleapis.com/auth/datastore',
  'https://www.googleapis.com/auth/firebase.messaging',
].join(' ');

const FIRESTORE_URL = 'https://firestore.googleapis.com/v1';

// A conditional write that lost: the document changed or is gone.
const LOST_RACE_CODES = new Set([404, 409, 412]);
const LOST_RACE_STATUSES = new Set([
  'FAILED_PRECONDITION',
  'ABORTED',
  'NOT_FOUND',
]);

// Firestore answers these for a batch write whose document is gone, which is
// fine: it was deleted while the run was sending.
const GONE_CODES = new Set([5, 9]);

function serviceAccount(env) {
  try {
    return JSON.parse(env.GOOGLE_SERVICE_ACCOUNT);
  } catch {
    // Not the parser's message: it quotes the text it could not read.
    throw new Error('GOOGLE_SERVICE_ACCOUNT is not valid JSON');
  }
}

/** Signs in as the service account and returns a client for its token. */
export async function connect(env) {
  const account = serviceAccount(env);
  const key = await importPKCS8(account.private_key, 'RS256');
  const now = Math.floor(Date.now() / 1000);
  const assertion = await new SignJWT({ scope: SCOPES })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuer(account.client_email)
    .setAudience(TOKEN_URL)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);
  const response = await fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!response.ok) {
    throw new Error(`Google sign-in failed with ${response.status}`);
  }
  const { access_token: token } = await response.json();
  return new Google(env.FIREBASE_PROJECT_ID, token);
}

export function decodeValue(value) {
  if ('arrayValue' in value) {
    // Firestore leaves `values` out of an empty array.
    return (value.arrayValue.values ?? []).map(decodeValue);
  }
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  return (
    value.stringValue ?? value.booleanValue ?? value.timestampValue ?? null
  );
}

/** A Firestore document as plain values, with its id and update time. */
export function decode(document) {
  const fields = {};
  for (const [name, value] of Object.entries(document.fields ?? {})) {
    fields[name] = decodeValue(value);
  }
  return {
    ...fields,
    id: document.name.split('/').pop(),
    updateTime: document.updateTime,
  };
}

export function encode(fields) {
  const encoded = {};
  for (const [name, value] of Object.entries(fields)) {
    if (typeof value === 'boolean') encoded[name] = { booleanValue: value };
    else if (Number.isInteger(value)) encoded[name] = { integerValue: String(value) };
    else encoded[name] = { stringValue: String(value) };
  }
  return encoded;
}

/** Whether a refused message is about the token rather than the message. */
function refusesToken(body) {
  return (body.error?.details ?? []).some(
    (detail) =>
      detail.errorCode === 'UNREGISTERED' ||
      (detail.fieldViolations ?? []).some((v) => v.field === 'message.token'),
  );
}

export class Google {
  /** [firestoreUrl] is only for pointing tests at the emulator. */
  constructor(project, token, firestoreUrl = FIRESTORE_URL) {
    this.root = `projects/${project}/databases/(default)/documents`;
    this.documents = `${firestoreUrl}/${this.root}`;
    this.messages = `https://fcm.googleapis.com/v1/projects/${project}/messages:send`;
    this.headers = {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    };
  }

  async #query(structuredQuery) {
    const response = await fetch(`${this.documents}:runQuery`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({ structuredQuery }),
    });
    if (!response.ok) {
      throw new Error(`Firestore query failed with ${response.status}`);
    }
    const rows = await response.json();
    // A failed query must not read as an empty one.
    if (rows.some((row) => row.error)) {
      throw new Error('Firestore query answered with an error');
    }
    return rows.filter((row) => row.document).map((row) => decode(row.document));
  }

  /** A whole small collection: the band's users or its phones. */
  all(collectionId, limit = 300) {
    return this.#query({ from: [{ collectionId }], limit });
  }

  /** Gigs on days [from] to [to], both included, as yyyy-MM-dd. */
  gigsBetween(from, to, limit = 300) {
    const bound = (op, stringValue) => ({
      fieldFilter: { field: { fieldPath: 'date' }, op, value: { stringValue } },
    });
    return this.#query({
      from: [{ collectionId: 'gigs' }],
      where: {
        compositeFilter: {
          op: 'AND',
          filters: [
            bound('GREATER_THAN_OR_EQUAL', from),
            bound('LESS_THAN_OR_EQUAL', to),
          ],
        },
      },
      limit,
    });
  }

  /** The document at [path], or null when there is none. */
  async get(path) {
    const response = await fetch(`${this.documents}/${path}`, {
      headers: this.headers,
    });
    if (response.status === 404) return null;
    if (!response.ok) {
      throw new Error(`Firestore read failed with ${response.status}`);
    }
    return decode(await response.json());
  }

  /**
   * Writes [fields] only if the document still has [updateTime]. False means
   * someone else got there first; any other failure throws.
   *
   * Through :commit, not a PATCH with currentDocument in its URL: on the
   * Firestore emulator that reads the update time as 0, and always loses.
   */
  async writeIf(path, fields, updateTime) {
    const response = await fetch(`${this.documents}:commit`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({
        writes: [
          {
            update: { name: `${this.root}/${path}`, fields: encode(fields) },
            updateMask: { fieldPaths: Object.keys(fields) },
            currentDocument: { updateTime },
          },
        ],
      }),
    });
    if (response.ok) return true;
    if (LOST_RACE_CODES.has(response.status)) return false;
    const body = await response.json().catch(() => ({}));
    if (LOST_RACE_STATUSES.has(body.error?.status)) return false;
    throw new Error(`Firestore write failed with ${response.status}`);
  }

  /**
   * Records a run in one call: [marks] ({path, fields, mustExist}) on the
   * documents, and the dead [stale] tokens deleted. Throws when the call
   * fails, logs a write that failed for any reason but a deleted document.
   *
   * Through :batchWrite, so a gig deleted meanwhile does not cost the rest
   * their marks. It takes one write per document, and can apply nothing and
   * still answer 200.
   */
  async record(marks, stale = []) {
    const writes = [
      ...marks.map(({ path, fields, mustExist = true }) => ({
        update: { name: `${this.root}/${path}`, fields: encode(fields) },
        updateMask: { fieldPaths: Object.keys(fields) },
        // Without it a mark would bring a deleted gig back as a stub.
        ...(mustExist ? { currentDocument: { exists: true } } : {}),
      })),
      ...[...new Set(stale)].map((token) => ({
        delete: `${this.root}/pushTokens/${encodeURIComponent(token)}`,
      })),
    ];
    if (writes.length === 0) return;
    const response = await fetch(`${this.documents}:batchWrite`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({ writes }),
    });
    if (!response.ok) {
      throw new Error(`Firestore batch write failed with ${response.status}`);
    }
    const { status = [] } = await response.json();
    const failed = status.filter(
      (s) => (s.code ?? 0) !== 0 && !GONE_CODES.has(s.code),
    );
    if (failed.length > 0) {
      console.error(`${failed.length} of ${writes.length} writes failed`);
    }
  }

  /**
   * Sends [message] to one phone: 'sent', 'unregistered' when that token is
   * of no further use, or 'failed'. Never throws: one phone's failure must
   * not stop the others.
   */
  async send(token, message) {
    try {
      const response = await fetch(this.messages, {
        method: 'POST',
        headers: this.headers,
        body: JSON.stringify({ message: { token, ...message } }),
      });
      if (response.ok) return 'sent';
      const body = await response.json().catch(() => ({}));
      // Only when the error names the token: a badly built message also comes
      // back as INVALID_ARGUMENT, and must not cost anyone their phone.
      if (refusesToken(body)) return 'unregistered';
      // Only Google's reason: never the token or what the gig is.
      console.error(
        `FCM refused a push with ${response.status}: ${body.error?.status}`,
      );
      return 'failed';
    } catch (error) {
      console.error(`Sending a push failed: ${error.name}`);
      return 'failed';
    }
  }
}
