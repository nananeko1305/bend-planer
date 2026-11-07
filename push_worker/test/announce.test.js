import assert from 'node:assert/strict';
import { test } from 'node:test';

import { announce, gigPushKind, tipText } from '../src/announce.js';
import { runScheduled } from '../src/cron.js';

/** An in-memory stand-in for the Google client, recording what it did. */
function fakeGoogle(docs) {
  const store = new Map(Object.entries(docs).map(([k, v]) => [k, { ...v, updateTime: 't1' }]));
  return {
    sent: [],
    writes: [],
    recorded: [],
    loseNext: 0,
    async get(path) {
      const d = store.get(path);
      return d ? { ...d, id: path.split('/').pop() } : null;
    },
    async writeIf(path, fields, updateTime) {
      if (this.loseNext > 0) {
        this.loseNext--;
        store.set(path, { ...store.get(path), updateTime: 't2' });
        return false;
      }
      if (store.get(path)?.updateTime !== updateTime) return false;
      store.set(path, { ...store.get(path), ...fields, updateTime: 't3' });
      this.writes.push({ path, fields });
      return true;
    },
    async send(token, message) {
      this.sent.push({ token, kind: message.data.kind });
      return token === 'dead' ? 'unregistered' : 'sent';
    },
    async record(marks, stale) {
      this.recorded.push({ marks, stale });
    },
    async gigsBetween() {
      return [...store.entries()]
        .filter(([k]) => k.startsWith('gigs/'))
        .map(([k, v]) => ({ ...v, id: k.split('/').pop() }));
    },
  };
}

const user = (role, extra = {}) => ({ role, disabled: false, firstName: 'A', lastName: 'B', ...extra });

function band({ locked = false } = {}) {
  return {
    locked,
    users: new Map([
      ['owner', user('owner')],
      ['leader', user('admin')],
      ['ana', user('member')],
      ['bob', user('member')],
      ['gone', user('member', { disabled: true })],
    ]),
    tokens: [
      { id: 'tOwner', uid: 'owner' },
      { id: 'tLeader', uid: 'leader' },
      { id: 'tAna', uid: 'ana' },
      { id: 'tBob', uid: 'bob' },
      { id: 'dead', uid: 'bob' },
      { id: 'tGone', uid: 'gone' },
    ],
  };
}

const now = new Date('2026-11-07T12:00:00Z');
const gigDoc = (extra = {}) => ({
  date: '2026-11-14', start: '20:00', venue: 'Sala', city: 'Kraljevo',
  priceMinor: 150000, currency: 'EUR', hasTip: true, tipMinor: null,
  cancelled: false, rev: 1, updatedBy: 'ana', ...extra,
});

test('a new gig goes to the rest of the band, once', async () => {
  const google = fakeGoogle({ 'gigs/g1': gigDoc() });
  assert.equal(await announce(google, band(), 'ana', 'gig', 'g1', now), 204);
  assert.deepEqual(google.sent.map((s) => s.token).sort(), ['dead', 'tBob', 'tLeader']);
  assert.ok(google.sent.every((s) => s.kind === 'gigNew'));
  assert.deepEqual(google.recorded[0].stale, ['dead']);
  // Asked again: already told, nothing is sent.
  google.sent.length = 0;
  assert.equal(await announce(google, band(), 'ana', 'gig', 'g1', now), 204);
  assert.equal(google.sent.length, 0);
});

test('only whoever changed it may ask, and only while in the band', async () => {
  const google = fakeGoogle({ 'gigs/g1': gigDoc() });
  assert.equal(await announce(google, band(), 'bob', 'gig', 'g1', now), 403);
  assert.equal(await announce(google, band(), 'gone', 'gig', 'g1', now), 403);
  assert.equal(await announce(google, band({ locked: true }), 'ana', 'gig', 'g1', now), 403);
  assert.equal(await announce(google, band(), 'ana', 'gig', 'nope', now), 404);
  assert.equal(google.sent.length, 0);
});

test('a lost race is tried again, then given up', async () => {
  const google = fakeGoogle({ 'gigs/g1': gigDoc() });
  google.loseNext = 1;
  assert.equal(await announce(google, band(), 'ana', 'gig', 'g1', now), 204);
  assert.equal(google.writes.length, 1);
  const stubborn = fakeGoogle({ 'gigs/g1': gigDoc() });
  stubborn.loseNext = 5;
  assert.equal(await announce(stubborn, band(), 'ana', 'gig', 'g1', now), 409);
  assert.equal(stubborn.sent.length, 0);
});

test('what kind of gig push, from what was told before', () => {
  assert.equal(gigPushKind({ rev: 1 }), 'gigNew');
  assert.equal(gigPushKind({ rev: 2, pushRev: 1 }), 'gigChanged');
  assert.equal(gigPushKind({ rev: 3, pushRev: 2, cancelled: true }), 'gigCancelled');
});

test('a change to a long-past gig is marked, not sent', async () => {
  const google = fakeGoogle({ 'gigs/g1': gigDoc({ date: '2026-10-01', rev: 2, pushRev: 1 }) });
  assert.equal(await announce(google, band(), 'ana', 'gig', 'g1', now), 204);
  assert.equal(google.writes.length, 1);
  assert.equal(google.sent.length, 0);
});

test('a tip, a member and feedback reach the right phones', async () => {
  const google = fakeGoogle({
    'gigs/g1': gigDoc({ tipMinor: 35000, tipBy: 'bob' }),
    'users/new': user('member', { announced: false }),
    'feedback/f1': { uid: 'ana', text: 'Setlista!', announced: false },
  });
  const b = band();
  b.users.set('new', user('member', { announced: false }));
  assert.equal(await announce(google, b, 'bob', 'tip', 'g1', now), 204);
  assert.equal(await announce(google, b, 'ana', 'member', 'new', now), 403);
  assert.equal(await announce(google, b, 'leader', 'member', 'new', now), 204);
  assert.equal(await announce(google, b, 'ana', 'feedback', 'f1', now), 204);
  const kinds = google.sent.map((s) => `${s.kind}:${s.token}`);
  assert.ok(kinds.includes('tip:tAna') && !kinds.includes('tip:tBob'));
  assert.ok(kinds.includes('memberAdded:tAna') && !kinds.includes('memberAdded:tOwner'));
  assert.deepEqual(kinds.filter((k) => k.startsWith('feedback')), ['feedback:tOwner']);
});

test('the scheduled run sends, marks, and stays silent while locked', async () => {
  const docs = { 'gigs/g1': gigDoc({ date: '2026-11-07' }) };
  const morning = new Date('2026-11-07T08:00:00Z');
  const locked = fakeGoogle(docs);
  await runScheduled(locked, band({ locked: true }), morning);
  assert.equal(locked.sent.length, 0);
  const google = fakeGoogle(docs);
  await runScheduled(google, band(), morning);
  // Leader, ana and bob's two phones: not the owner, not a removed member.
  assert.equal(google.sent.filter((s) => s.kind === 'today').length, 4);
  assert.deepEqual(google.recorded[0].marks, [
    { path: 'gigs/g1', fields: { remindedDay: '2026-11-07' } },
  ]);
});

test('a tip of each their own says whose it is', async () => {
  const b = band();
  b.users.set('ana', user('member', { firstName: 'Ana', lastName: 'Ilić' }));
  const own = gigDoc({ tipSplit: 'own', players: ['ana', 'bob'], tips: { ana: 10000 }, tipPlayer: 'ana', tipBy: 'bob' });
  assert.equal(tipText(own, b), 'Ana Ilić: 100 €');
  assert.equal(tipText(gigDoc({ tipMinor: 35000 }), b), '350 €');
  const google = fakeGoogle({ 'gigs/g1': own });
  assert.equal(await announce(google, b, 'bob', 'tip', 'g1', now), 204);
  const kinds = google.sent.map((s) => `${s.kind}:${s.token}`);
  assert.ok(kinds.includes('tip:tAna') && !kinds.includes('tip:tBob'));
  assert.deepEqual(google.writes.map((w) => w.fields), [{ tipAnnounced: true }]);
});
