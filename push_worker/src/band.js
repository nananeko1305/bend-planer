// Who is in the band right now and which phones they have; shared by the
// route and the cron. The worker skips the Firestore rules, so these checks
// are its own.

// The free plan allows 50 outside calls per run; a run spends a handful on
// reading and recording, the rest on pushes.
export const MAX_SENDS = 40;

/** Everything a run needs to know about the band, in three reads. */
export async function loadBand(google) {
  const [users, tokens, app] = await Promise.all([
    google.all('users'),
    google.all('pushTokens'),
    google.get('meta/app'),
  ]);
  return {
    users: new Map(users.map((u) => [u.id, u])),
    tokens,
    locked: app?.locked === true,
  };
}

export const isOwner = (user) => user?.role === 'owner';
export const isLeader = (user) =>
  user?.disabled === false && (user.role === 'admin' || isOwner(user));

/** In the band and allowed in: not removed, and the app not locked. */
export function isActive(band, user) {
  if (!user) return false;
  if (isOwner(user)) return true;
  return user.disabled === false && !band.locked;
}

/**
 * The phones that get a band push: active members, not the owner (who is not
 * in the band), not [except] (who did the thing and knows).
 */
export function bandPhones(band, { except = '' } = {}) {
  return band.tokens.filter((t) => {
    const user = band.users.get(t.uid);
    return t.uid !== except && user && !isOwner(user) && isActive(band, user);
  });
}

/** The owner's phones, for feedback. */
export function ownerPhones(band) {
  return band.tokens.filter((t) => isOwner(band.users.get(t.uid)));
}

/**
 * Sends [message] to [phones] and returns the tokens FCM no longer knows,
 * for the caller to delete with its other writes.
 */
export async function sendTo(google, phones, message) {
  const results = await Promise.all(
    phones.map(async (phone) => ({
      token: phone.id,
      result: await google.send(phone.id, message),
    })),
  );
  const failed = results.filter((r) => r.result === 'failed').length;
  if (failed > 0) console.error(`${failed} of ${results.length} pushes failed`);
  return results.filter((r) => r.result === 'unregistered').map((r) => r.token);
}
