import assert from 'node:assert/strict';
import { test } from 'node:test';

import { plan } from '../src/cron.js';
import {
  dueTipNags,
  dueToday,
  dueTomorrow,
  gigTipTotal,
  monthTotals,
  previousMonth,
  reportMonthDue,
  tipComplete,
} from '../src/due.js';
import { decodeValue } from '../src/google.js';

const gig = (id, date, extra = {}) => ({
  id,
  date,
  start: '20:00',
  venue: 'Sala',
  city: 'Čačak',
  priceMinor: 100000,
  currency: 'EUR',
  hasTip: true,
  tipMinor: null,
  cancelled: false,
  ...extra,
});

test('tomorrow and today, once each, never a cancelled gig', () => {
  const gigs = [
    gig('a', '2026-11-08'),
    gig('b', '2026-11-08', { cancelled: true }),
    gig('c', '2026-11-08', { remindedEve: '2026-11-08' }),
    gig('d', '2026-11-07'),
    gig('e', '2026-11-07', { remindedDay: '2026-11-07' }),
  ];
  assert.deepEqual(dueTomorrow(gigs, '2026-11-07').map((g) => g.id), ['a']);
  assert.deepEqual(dueToday(gigs, '2026-11-07').map((g) => g.id), ['d']);
});

test('a moved gig is reminded again for its new day', () => {
  const moved = gig('a', '2026-11-09', { remindedEve: '2026-11-08' });
  assert.deepEqual(dueTomorrow([moved], '2026-11-08').map((g) => g.id), ['a']);
});

test('a missing tip is asked about daily, three times, for a week', () => {
  const today = '2026-11-07';
  const gigs = [
    gig('yesterday', '2026-11-06'),
    gig('asked', '2026-11-05', { lastNag: today }),
    gig('enough', '2026-11-04', { tipNags: 3 }),
    gig('entered', '2026-11-04', { tipMinor: 0 }),
    gig('notip', '2026-11-04', { hasTip: false }),
    gig('old', '2026-10-20'),
    gig('tonight', today),
  ];
  assert.deepEqual(dueTipNags(gigs, today).map((g) => g.id), ['yesterday']);
});

test('the report goes on the first days of a month, once', () => {
  assert.equal(previousMonth('2026-01-02'), '2025-12');
  assert.equal(reportMonthDue('2026-11-01', '2026-09'), '2026-10');
  assert.equal(reportMonthDue('2026-11-03', '2026-10'), null);
  assert.equal(reportMonthDue('2026-11-04', '2026-09'), null);
});

test('month totals add tips, keep currencies apart, skip cancelled', () => {
  const totals = monthTotals(
    [
      gig('a', '2026-10-03', { tipMinor: 35000 }),
      gig('b', '2026-10-10', { currency: 'RSD', priceMinor: 6000000 }),
      gig('c', '2026-10-11', { cancelled: true }),
      gig('d', '2026-11-01'),
    ],
    '2026-10',
  );
  assert.deepEqual(totals, { count: 2, sums: { EUR: 135000, RSD: 6000000 } });
});

test('the plan follows the clock in Belgrade', () => {
  const gigs = [gig('t', '2026-11-08'), gig('d', '2026-11-07'), gig('y', '2026-11-06')];
  // 19:00 UTC = 20:00 in Belgrade in November: tomorrow's gig.
  const evening = plan(gigs, new Date('2026-11-07T19:00:00Z'), '2026-10');
  assert.deepEqual(evening.map((j) => j.message.data.kind), ['tomorrow']);
  // 08:00 UTC = 09:00: today's gig and yesterday's tip.
  const morning = plan(gigs, new Date('2026-11-07T08:00:00Z'), '2026-10');
  assert.deepEqual(morning.map((j) => j.message.data.kind), ['today', 'tipReminder']);
  // 07:00 UTC = 08:00: too early for anything.
  assert.deepEqual(plan(gigs, new Date('2026-11-07T07:00:00Z'), '2026-10'), []);
  // On the first, the report joins in.
  const first = plan([], new Date('2026-12-01T08:00:00Z'), '2026-10');
  assert.deepEqual(first.map((j) => j.message.data.kind), ['report']);
  assert.deepEqual(first[0].marks, [{ path: 'meta/report', fields: { month: '2026-11' }, mustExist: false }]);
});

test('each their own: the total is the sum, complete once every player entered', () => {
  const own = (tips, players = ['ana', 'bob']) => gig('o', '2026-11-06', { tipSplit: 'own', players, tips });
  assert.equal(gigTipTotal(own({})), null);
  assert.equal(tipComplete(own({ ana: 10000 })), false);
  assert.equal(gigTipTotal(own({ ana: 10000 })), 10000);
  assert.equal(tipComplete(own({ ana: 10000, bob: 0 })), true);
  // Someone unticked after entering no longer counts.
  assert.equal(gigTipTotal(own({ ana: 10000, bob: 5000 }, ['ana'])), 10000);
  // Shared equally, or a gig from before 1.2: the total alone.
  assert.equal(tipComplete(gig('e', '2026-11-06', { tipMinor: 0 })), true);
  assert.equal(gigTipTotal(gig('e', '2026-11-06', { tipSplit: 'equal', tipMinor: 2000 })), 2000);
});

test('a tip of each their own is asked about until everyone entered', () => {
  const today = '2026-11-07';
  const gigs = [
    gig('half', '2026-11-06', { tipSplit: 'own', players: ['ana', 'bob'], tips: { ana: 100 } }),
    gig('all', '2026-11-06', { tipSplit: 'own', players: ['ana', 'bob'], tips: { ana: 100, bob: 0 } }),
  ];
  assert.deepEqual(dueTipNags(gigs, today).map((g) => g.id), ['half']);
  assert.deepEqual(monthTotals(gigs, '2026-11'), { count: 2, sums: { EUR: 200200 } });
});

test('a map from Firestore reads as an object', () => {
  const v = { mapValue: { fields: { ana: { integerValue: '10000' }, bob: { integerValue: '0' } } } };
  assert.deepEqual(decodeValue(v), { ana: 10000, bob: 0 });
  assert.deepEqual(decodeValue({ mapValue: {} }), {});
});
