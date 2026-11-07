// What the scheduled runs owe the band, worked out from the gigs and the
// clock alone. Each gig carries its own marks, so a repeated run finds
// nothing left to do, and a run that ran out of budget leaves the rest due.

import { addDays } from './message.js';

const MAX_TIP_NAGS = 3;

/** How many days back a missing tip is still asked about. */
export const TIP_DAYS = 7;

const on = (gig) => gig.cancelled !== true;
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
        !Number.isInteger(g.tipMinor) &&
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
    sums[c] = (sums[c] ?? 0) + (g.priceMinor ?? 0) + (Number.isInteger(g.tipMinor) ? g.tipMinor : 0);
  }
  return { count, sums };
}
