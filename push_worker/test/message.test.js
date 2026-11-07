import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  addDays,
  dateLabel,
  dayInBelgrade,
  formatMoney,
  formatSums,
  gigLine,
  hourInBelgrade,
  listBody,
  message,
  monthLabel,
} from '../src/message.js';

test('Belgrade days and hours across daylight saving', () => {
  // 23:30 UTC on 25 October 2026 is 00:30 on the 26th in Belgrade (winter).
  assert.equal(dayInBelgrade(new Date('2026-10-25T23:30:00Z')), '2026-10-26');
  assert.equal(hourInBelgrade(new Date('2026-07-01T07:00:00Z')), 9);
  assert.equal(hourInBelgrade(new Date('2026-12-01T08:00:00Z')), 9);
});

test('days move by the calendar', () => {
  assert.equal(addDays('2026-10-31', 1), '2026-11-01');
  assert.equal(addDays('2026-03-01', -1), '2026-02-28');
  assert.equal(addDays('2026-12-31', 2), '2027-01-02');
});

test('labels and money read the Serbian way', () => {
  assert.equal(dateLabel('2026-11-07'), '7.11.');
  assert.equal(monthLabel('2026-10'), '10.2026.');
  assert.equal(formatMoney(150000, 'EUR'), '1.500 €');
  assert.equal(formatMoney(1250050, 'RSD'), '12.500,50 RSD');
  assert.equal(formatSums({ EUR: 985000, RSD: 6000000 }), '9.850 € · 60.000 RSD');
  assert.equal(formatSums({}), '0 €');
});

test('a gig in one line leaves out what is empty', () => {
  const g = { venue: 'Sala Kristal', city: '', start: '20:00', priceMinor: 150000, currency: 'EUR' };
  assert.equal(gigLine(g), 'Sala Kristal · 20:00 · 1.500 €');
  assert.equal(gigLine(g, { withPrice: false }), 'Sala Kristal · 20:00');
});

test('a long list is cut before FCM would refuse it', () => {
  const body = listBody(Array.from({ length: 200 }, () => 'x'.repeat(40)));
  assert.ok(new TextEncoder().encode(body).length <= 3001);
  assert.ok(body.endsWith('…'));
});

test('every value in a message is a string', () => {
  const m = message('report', { arg: '10.2026.', bodyArgs: [9, '9.850 €'] });
  for (const v of Object.values(m.data)) assert.equal(typeof v, 'string');
  for (const v of m.android.notification.body_loc_args) assert.equal(typeof v, 'string');
  assert.equal(m.android.notification.channel_id, 'reports');
  assert.equal(m.data.text, '9 · 9.850 €');
  assert.throws(() => message('nope', {}));
});
