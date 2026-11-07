// Bend Planer push worker. Holds the service account key, which cannot ship
// in a public APK, and does the two things the app cannot: tell the rest of
// the band about a change, and remind everyone on time. See README.md.

import { createRemoteJWKSet, jwtVerify } from 'jose';

import { announce, KINDS } from './announce.js';
import { loadBand } from './band.js';
import { runScheduled } from './cron.js';
import { connect } from './google.js';

const FIREBASE_KEYS = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com',
  ),
);

const answer = (status) => new Response(null, { status });

/** The uid of a valid Firebase ID token in [request], or null. */
async function callerOf(request, env) {
  const header = request.headers.get('Authorization') ?? '';
  if (!header.startsWith('Bearer ')) return null;
  const project = env.FIREBASE_PROJECT_ID;
  try {
    const { payload } = await jwtVerify(header.slice(7), FIREBASE_KEYS, {
      issuer: `https://securetoken.google.com/${project}`,
      audience: project,
      algorithms: ['RS256'],
      requiredClaims: ['exp', 'sub'],
    });
    return payload.sub;
  } catch {
    return null;
  }
}

/** {kind, id} from the body, or null when it could not be one. */
async function targetOf(request) {
  const body = await request.json().catch(() => null);
  const kind = body?.kind;
  const id = body?.id;
  if (!KINDS.includes(kind)) return null;
  if (typeof id !== 'string' || !/^[A-Za-z0-9]{1,128}$/.test(id)) return null;
  return { kind, id };
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname !== '/announce') return answer(404);
    if (request.method !== 'POST') return answer(405);
    const uid = await callerOf(request, env);
    if (!uid) return answer(401);
    const target = await targetOf(request);
    if (!target) return answer(400);
    const google = await connect(env);
    const band = await loadBand(google);
    return answer(
      await announce(google, band, uid, target.kind, target.id, new Date()),
    );
  },

  async scheduled(event, env) {
    const google = await connect(env);
    const band = await loadBand(google);
    await runScheduled(google, band, new Date(event.scheduledTime));
  },
};
