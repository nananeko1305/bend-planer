// What the scheduled runs owe the band, worked out from the gigs and the
// clock alone. Each gig carries its own marks, so a repeated run finds
// nothing left to do, and a run that ran out of budget leaves the rest due.

import { addDays } from './message.js';

const MAX_TIP_NAGS = 3;

/** How many days back a missing tip is still asked about. */
export const TIP_DAYS = 7;

const on = (gig) => gig.cancelled !== true;

// How a gig shares its tip, as in the app (lib/models/gig.dart): 'equal' is
// one total for the band, 'own' an entry per player in `tips`. Gigs from
// before 1.2 have neither field and are 'equal'.
const playersOf = (gig) => (Array.isArray(gig.players) ? gig.players : []);
const isOwn = (gig) => gig.tipSplit === 'own';

/** The players' own entries that count: someone unticked later drops out. */
function ownEntries(gig) {
  const players = playersOf(gig);
  return Object.entries(gig.tips && typeof gig.tips === 'object' ? gig.tips : {}).filter(
    ([uid, minor]) => Number.isInteger(minor) && (players.length === 0 || players.includes(uid)),
  );
}

/** The band's tip of a gig: the total, or the sum of the entries; null while none. */
export function gigTipTotal(gig) {
  if (!isOwn(gig)) return Number.isInteger(gig.tipMinor) ? gig.tipMinor : null;
  const entries = ownEntries(gig);
  return entries.length === 0 ? null : entries.reduce((sum, [, minor]) => sum + minor, 0);
}

/** Nothing left to enter: the total, or an entry from every player (0 counts). */
export function tipComplete(gig) {
  if (!isOwn(gig)) return Number.isInteger(gig.tipMinor);
  const entered = new Set(ownEntries(gig).map(([uid]) => uid));
  const players = playersOf(gig);
  return players.length === 0 ? entered.size > 0 : players.every((uid) => entered.has(uid));
}
const byStart = (a, b) => (a.start ?? '').localeCompare(b.start ?? '');

/** In the evening: tomorrow's gigs nobody has been reminded of. */
export function dueTomorrow(gigs, today) {
  const tomorrow = addDays(today, 1);
  return gigs
    .filter((g) => on(g) && g.date === tomorrow && g.remindedEve !== tomorrow)
    .sort(byStart);
}

/** In the morning: today's gigs nobody has been reminded of. */
export function dueToday(gigs, today) {
  return gigs
    .filter((g) => on(g) && g.date === today && g.remindedDay !== today)
    .sort(byStart);
}

/** In the morning: played gigs still waiting for the tip, once a day each. */
export function dueTipNags(gigs, today) {
  const oldest = addDays(today, -TIP_DAYS);
  return gigs
    .filter(
      (g) =>
        on(g) &&
        g.hasTip === true &&
        !tipComplete(g) &&
        g.date < today &&
        g.date >= oldest &&
        (g.tipNags ?? 0) < MAX_TIP_NAGS &&
        g.lastNag !== today,
    )
    .sort((a, b) => a.date.localeCompare(b.date));
}

/** "2026-10" for any day in November 2026. */
export function previousMonth(today) {
  const [y, m] = today.split('-').map(Number);
  return m === 1 ? `${y - 1}-12` : `${y}-${String(m - 1).padStart(2, '0')}`;
}

/**
 * The report on the first days of a month, for the month before, unless it
 * went out already. A few days of grace cover an outage on the first.
 */
export function reportMonthDue(today, lastSent) {
  const day = Number(today.slice(8, 10));
  const month = previousMonth(today);
  return day <= 3 && lastSent !== month ? month : null;
}

/** Count and money of [month] ("2026-10"): agreed plus tips, per currency. */
export function monthTotals(gigs, month) {
  let count = 0;
  const sums = {};
  for (const g of gigs) {
    if (!on(g) || !g.date.startsWith(`${month}-`)) continue;
    count++;
    const c = g.currency === 'RSD' ? 'RSD' : 'EUR';
    sums[c] = (sums[c] ?? 0) + (g.priceMinor ?? 0) + (gigTipTotal(g) ?? 0);
  }
  return { count, sums };
}
