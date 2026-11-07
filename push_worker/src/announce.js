// POST /announce: an app asks the worker to tell the band about something
// it changed. The record says what is due; the request only says where to
// look, so a repeated or forged call can at most repeat nothing.

import { bandPhones, isActive, isLeader, ownerPhones, sendTo } from './band.js';
import {
  addDays,
  dateLabel,
  dayInBelgrade,
  formatMoney,
  gigLine,
  message,
} from './message.js';

const CLAIM_ATTEMPTS = 2;

export const KINDS = ['gig', 'tip', 'member', 'feedback'];

/** The kind of push a gig change is, from what the band was told so far. */
export function gigPushKind(gig) {
  if (gig.cancelled === true) return 'gigCancelled';
  return (gig.pushRev ?? 0) === 0 ? 'gigNew' : 'gigChanged';
}

// Per kind: where the record lives, whether it is due, whether [uid] may ask,
// the mark that settles it, and the push.
const SPECS = {
  gig: {
    path: (id) => `gigs/${id}`,
    due: (g) => (g.pushRev ?? 0) < (g.rev ?? 1),
    mayAsk: (g, uid) => g.updatedBy === uid,
    mark: (g) => ({ pushRev: g.rev ?? 1 }),
    push: (g, band, uid, now) => {
      // A change to a gig long past interests nobody; it is only marked.
      if (g.date < addDays(dayInBelgrade(now), -1)) return null;
      return {
        phones: bandPhones(band, { except: uid }),
        message: message(gigPushKind(g), {
          arg: dateLabel(g.date),
          text: gigLine(g),
          gigId: g.id,
        }),
      };
    },
  },
  tip: {
    path: (id) => `gigs/${id}`,
    due: (g) => Number.isInteger(g.tipMinor) && g.tipAnnounced !== true,
    mayAsk: (g, uid) => g.tipBy === uid,
    mark: () => ({ tipAnnounced: true }),
    push: (g, band, uid) => ({
      phones: bandPhones(band, { except: uid }),
      message: message('tip', {
        arg: dateLabel(g.date),
        text: [gigLine(g, { withPrice: false }), formatMoney(g.tipMinor, g.currency)]
          .filter((s) => s)
          .join(' · '),
        gigId: g.id,
      }),
    }),
  },
  member: {
    path: (id) => `users/${id}`,
    due: (u) => u.announced === false && u.role !== 'owner',
    mayAsk: (u, uid, band) => isLeader(band.users.get(uid)),
    mark: () => ({ announced: true }),
    push: (u, band, uid) => ({
      phones: bandPhones(band, { except: uid }),
      message: message(u.disabled ? 'memberRemoved' : 'memberAdded', {
        text: [`${u.firstName ?? ''} ${u.lastName ?? ''}`.trim(), u.instrument]
          .filter((s) => s)
          .join(' · '),
      }),
    }),
  },
  feedback: {
    path: (id) => `feedback/${id}`,
    due: (f) => f.announced === false,
    mayAsk: (f, uid) => f.uid === uid,
    mark: () => ({ announced: true }),
    push: (f, band) => {
      const from = band.users.get(f.uid);
      const name = `${from?.firstName ?? ''} ${from?.lastName ?? ''}`.trim();
      return {
        phones: ownerPhones(band),
        message: message('feedback', { text: [name, f.text].filter((s) => s).join(': ') }),
      };
    },
  },
};

/**
 * Handles one announcement and returns the HTTP status to answer with: 204
 * when sent or nothing was due, 403 when [uid] may not ask, 404 when the
 * record is gone, 409 when another caller kept winning the race.
 */
export async function announce(google, band, uid, kind, id, now) {
  const spec = SPECS[kind];
  if (!isActive(band, band.users.get(uid))) return 403;
  const path = spec.path(id);
  let record = await google.get(path);
  if (!record) return 404;
  if (!spec.mayAsk(record, uid, band)) return 403;
  // Mark first, send second: if FCM fails right then, that push is lost, but
  // nothing is ever sent twice.
  for (let attempt = 1; ; attempt++) {
    if (!spec.due(record)) return 204;
    if (await google.writeIf(path, spec.mark(record), record.updateTime)) break;
    if (attempt === CLAIM_ATTEMPTS) return 409;
    record = await google.get(path);
    if (!record) return 404;
  }
  const push = spec.push(record, band, uid, now);
  if (!push || push.phones.length === 0) return 204;
  const stale = await sendTo(google, push.phones, push.message);
  await google.record([], stale);
  return 204;
}
