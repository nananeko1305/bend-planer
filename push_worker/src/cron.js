// The scheduled runs: reminders the evening before and the morning of a gig,
// asking for missing tips, and the monthly report. Cron fires every half hour
// in a window around the right hour (see wrangler.toml); the clock in
// Belgrade decides what each run does, and the marks keep repeats harmless.

import { bandPhones, MAX_SENDS, sendTo } from './band.js';
import {
  dueTipNags,
  dueToday,
  dueTomorrow,
  monthTotals,
  reportMonthDue,
} from './due.js';
import {
  addDays,
  dateLabel,
  dayInBelgrade,
  formatSums,
  gigLine,
  hourInBelgrade,
  listBody,
  message,
  monthLabel,
} from './message.js';

const MORNING = { from: 9, to: 13 };
const EVENING = { from: 20, to: 23 };

const within = (hour, span) => hour >= span.from && hour < span.to;

/**
 * The jobs a run at [now] would do, most urgent first, each with its push
 * and the marks that settle it. Pure, apart from the clock passed in.
 */
export function plan(gigs, now, lastReport) {
  const today = dayInBelgrade(now);
  const hour = hourInBelgrade(now);
  const jobs = [];
  if (within(hour, EVENING)) {
    const tomorrow = addDays(today, 1);
    const due = dueTomorrow(gigs, today);
    if (due.length > 0) {
      jobs.push({
        message: message('tomorrow', {
          text: listBody(due.map((g) => gigLine(g))),
          gigId: due.length === 1 ? due[0].id : '',
        }),
        marks: due.map((g) => ({ path: `gigs/${g.id}`, fields: { remindedEve: tomorrow } })),
      });
    }
  }
  if (within(hour, MORNING)) {
    const due = dueToday(gigs, today);
    if (due.length > 0) {
      jobs.push({
        message: message('today', {
          text: listBody(due.map((g) => gigLine(g))),
          gigId: due.length === 1 ? due[0].id : '',
        }),
        marks: due.map((g) => ({ path: `gigs/${g.id}`, fields: { remindedDay: today } })),
      });
    }
    const nags = dueTipNags(gigs, today);
    if (nags.length > 0) {
      jobs.push({
        message: message('tipReminder', {
          text: listBody(nags.map((g) => `${dateLabel(g.date)} ${gigLine(g, { withPrice: false })}`)),
          gigId: nags.length === 1 ? nags[0].id : '',
        }),
        marks: nags.map((g) => ({
          path: `gigs/${g.id}`,
          fields: { tipNags: (g.tipNags ?? 0) + 1, lastNag: today },
        })),
      });
    }
    const month = reportMonthDue(today, lastReport);
    if (month) {
      const { count, sums } = monthTotals(gigs, month);
      jobs.push({
        message: message('report', {
          arg: monthLabel(month),
          bodyArgs: [count, formatSums(sums)],
        }),
        marks: [{ path: 'meta/report', fields: { month }, mustExist: false }],
      });
    }
  }
  return jobs;
}

/** Runs what is due at [now], within the budget of outside calls. */
export async function runScheduled(google, band, now) {
  // A locked band gets nothing; it all waits until unlocked, if still due.
  if (band.locked) return;
  const today = dayInBelgrade(now);
  const [gigs, report] = await Promise.all([
    // From the oldest tip worth asking about to the day after tomorrow.
    google.gigsBetween(addDays(today, -40), addDays(today, 2)),
    google.get('meta/report'),
  ]);
  const jobs = plan(gigs, now, report?.month);
  if (jobs.length === 0) return;
  const phones = bandPhones(band);
  const marks = [];
  const stale = [];
  let budget = MAX_SENDS;
  for (const job of jobs) {
    // A job goes to everyone or waits for the next run: half a band told is
    // worse than all of it half an hour later.
    if (phones.length > budget) break;
    budget -= phones.length;
    stale.push(...(await sendTo(google, phones, job.message)));
    marks.push(...job.marks);
  }
  await google.record(marks, stale);
}
