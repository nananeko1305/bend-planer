import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
  writeBatch,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-bend-planer-rules',
    firestore: { rules: readFileSync('firestore.rules', 'utf8') },
  });
});
after(() => env.cleanup());
beforeEach(() => env.clearFirestore());

const as = (uid) => env.authenticatedContext(uid).firestore();

/** A profile the way the app writes it. */
const profile = (role, changes = {}) => ({
  email: `${role}@x.rs`,
  role,
  disabled: false,
  firstName: 'Ime',
  lastName: 'Prezime',
  instrument: '',
  phone: '',
  announced: false,
  createdAt: serverTimestamp(),
  ...changes,
});

/** What the form writes for a new gig. */
const gig = (uid, changes = {}) => ({
  date: '2026-11-14',
  start: '20:00',
  end: '',
  type: 'wedding',
  venue: 'Sala Kristal',
  city: 'Kraljevo',
  address: '',
  clientName: '',
  clientPhone: '',
  priceMinor: 150000,
  currency: 'EUR',
  depositMinor: 30000,
  depositHolder: uid,
  hasTip: true,
  notes: '',
  ownerId: uid,
  tipMinor: null,
  tipBy: '',
  cancelled: false,
  rev: 1,
  updatedBy: uid,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...changes,
});

/** The band as stored, after the worker announced everyone: owner, a
 * leader, two members and one removed. */
async function seedBand({ locked = false } = {}) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'meta/owner'), { uid: 'owner' });
    await setDoc(doc(db, 'users/owner'), profile('owner', { createdAt: new Date() }));
    const known = { announced: true, createdAt: new Date() };
    await setDoc(doc(db, 'users/leader'), profile('admin', known));
    await setDoc(doc(db, 'users/ana'), profile('member', known));
    await setDoc(doc(db, 'users/bob'), profile('member', known));
    await setDoc(doc(db, 'users/gone'), profile('member', { disabled: true, createdAt: new Date() }));
    if (locked) await setDoc(doc(db, 'meta/app'), { locked: true });
  });
}

async function seedGig(id = 'g1', uid = 'ana', extra = {}) {
  await env.withSecurityRulesDisabled((ctx) =>
    setDoc(doc(ctx.firestore(), `gigs/${id}`), {
      ...gig(uid),
      createdAt: new Date(),
      updatedAt: new Date(),
      ...extra,
    }),
  );
}

describe('owner claim', () => {
  test('the first account becomes the owner, once', async () => {
    const claim = (uid) => {
      const db = as(uid);
      const batch = writeBatch(db);
      batch.set(doc(db, `users/${uid}`), profile('owner'));
      batch.set(doc(db, 'meta/owner'), { uid });
      return batch.commit();
    };
    await assertSucceeds(claim('first'));
    await assertFails(claim('second'));
  });

  test('nobody can make themselves a leader or a member', async () => {
    await assertFails(setDoc(doc(as('x'), 'users/x'), profile('admin')));
    await assertFails(setDoc(doc(as('x'), 'users/x'), profile('member')));
  });
});

describe('members', () => {
  test('a leader adds a member, a member cannot', async () => {
    await seedBand();
    await assertSucceeds(setDoc(doc(as('leader'), 'users/new1'), profile('member')));
    await assertFails(setDoc(doc(as('ana'), 'users/new2'), profile('member')));
    await assertFails(setDoc(doc(as('leader'), 'users/new3'), profile('admin')));
  });

  test('a leader removes a member, and the removal is announced', async () => {
    await seedBand();
    const ref = doc(as('leader'), 'users/ana');
    await assertFails(updateDoc(ref, { disabled: true }));
    await assertFails(updateDoc(ref, { disabled: true, announced: true }));
    await assertSucceeds(updateDoc(ref, { disabled: true, announced: false }));
  });

  test('nobody but the owner touches the owner or a role', async () => {
    await seedBand();
    await assertFails(updateDoc(doc(as('leader'), 'users/owner'), { firstName: 'X' }));
    await assertFails(updateDoc(doc(as('leader'), 'users/ana'), { role: 'admin' }));
    await assertSucceeds(updateDoc(doc(as('owner'), 'users/ana'), { role: 'admin' }));
    await assertFails(updateDoc(doc(as('owner'), 'users/ana'), { role: 'owner' }));
  });

  test('anyone edits their own details, not their role', async () => {
    await seedBand();
    await assertSucceeds(updateDoc(doc(as('ana'), 'users/ana'), { instrument: 'Bubnjevi' }));
    await assertFails(updateDoc(doc(as('ana'), 'users/ana'), { role: 'admin' }));
    await assertFails(updateDoc(doc(as('ana'), 'users/bob'), { firstName: 'X' }));
  });

  test('a removed member reads only their own profile', async () => {
    await seedBand();
    await assertSucceeds(getDoc(doc(as('gone'), 'users/gone')));
    await assertFails(getDocs(collection(as('gone'), 'users')));
    await assertFails(setDoc(doc(as('gone'), 'gigs/x'), gig('gone')));
  });
});

describe('gigs', () => {
  test('anyone in the band books a gig, as themselves', async () => {
    await seedBand();
    await assertSucceeds(setDoc(doc(as('ana'), 'gigs/a'), gig('ana')));
    await assertFails(setDoc(doc(as('ana'), 'gigs/b'), gig('bob')));
    await assertFails(setDoc(doc(as('ana'), 'gigs/c'), { ...gig('ana'), pushRev: 1 }));
    await assertFails(setDoc(doc(as('ana'), 'gigs/d'), gig('ana', { priceMinor: 0 })));
    await assertFails(setDoc(doc(as('ana'), 'gigs/e'), gig('ana', { depositMinor: 999999 })));
    await assertFails(setDoc(doc(as('ana'), 'gigs/f'), gig('ana', { date: '14.11.2026' })));
  });

  test('the author or a leader edits; the revision counts up', async () => {
    await seedBand();
    await seedGig('g1', 'ana');
    const edit = (uid, changes = {}) => updateDoc(doc(as(uid), 'gigs/g1'), {
      venue: 'Hotel Breza',
      rev: 2,
      updatedBy: uid,
      updatedAt: serverTimestamp(),
      ...changes,
    });
    await assertFails(edit('bob'));
    await assertFails(edit('ana', { rev: 1 }));
    await assertFails(edit('ana', { pushRev: 2 }));
    await assertSucceeds(edit('ana'));
    await assertSucceeds(edit('leader', { rev: 3 }));
  });

  test('anyone enters the tip, and nothing else with it', async () => {
    await seedBand();
    await seedGig('g1', 'ana');
    const tip = (uid, changes = {}) => updateDoc(doc(as(uid), 'gigs/g1'), {
      tipMinor: 35000,
      tipBy: uid,
      tipAnnounced: false,
      updatedAt: serverTimestamp(),
      ...changes,
    });
    await assertFails(tip('bob', { priceMinor: 1 }));
    await assertFails(tip('bob', { tipBy: 'ana' }));
    await assertSucceeds(tip('bob'));
  });

  test('no tip on a gig without one, or a cancelled one', async () => {
    await seedBand();
    await seedGig('g1', 'ana', { hasTip: false });
    await seedGig('g2', 'ana', { cancelled: true });
    for (const id of ['gigs/g1', 'gigs/g2']) {
      await assertFails(updateDoc(doc(as('bob'), id), {
        tipMinor: 100,
        tipBy: 'bob',
        tipAnnounced: false,
        updatedAt: serverTimestamp(),
      }));
    }
  });

  test('the author or a leader deletes', async () => {
    await seedBand();
    await seedGig('g1', 'ana');
    await assertFails(deleteDoc(doc(as('bob'), 'gigs/g1')));
    await assertSucceeds(deleteDoc(doc(as('leader'), 'gigs/g1')));
  });
});

describe('lock', () => {
  test('locked: the band can do nothing, the owner everything', async () => {
    await seedBand({ locked: true });
    await seedGig('g1', 'ana');
    await assertFails(getDocs(collection(as('ana'), 'gigs')));
    await assertFails(getDocs(collection(as('leader'), 'gigs')));
    await assertFails(setDoc(doc(as('ana'), 'gigs/x'), gig('ana')));
    await assertSucceeds(getDoc(doc(as('ana'), 'meta/app')));
    await assertSucceeds(getDoc(doc(as('ana'), 'users/ana')));
    await assertSucceeds(getDocs(collection(as('owner'), 'gigs')));
  });

  test('only the owner locks, unlocks and sets the version', async () => {
    await seedBand();
    await assertFails(setDoc(doc(as('leader'), 'meta/app'), { locked: true }));
    await assertSucceeds(setDoc(doc(as('owner'), 'meta/app'), { locked: true }, { merge: true }));
    await assertSucceeds(setDoc(doc(as('owner'), 'meta/app'), { minBuild: 12 }, { merge: true }));
    await assertFails(setDoc(doc(as('owner'), 'meta/app'), { other: 1 }, { merge: true }));
  });
});

describe('push tokens and feedback', () => {
  test('a token belongs to whoever saves it', async () => {
    await seedBand();
    await assertSucceeds(setDoc(doc(as('ana'), 'pushTokens/t1'), { uid: 'ana' }));
    await assertFails(setDoc(doc(as('ana'), 'pushTokens/t2'), { uid: 'bob' }));
    await assertFails(getDoc(doc(as('ana'), 'pushTokens/t1')));
    await assertSucceeds(deleteDoc(doc(as('ana'), 'pushTokens/t1')));
  });

  test('members write feedback, only the owner reads it', async () => {
    await seedBand();
    const note = (uid) => ({ uid, text: 'Dodajte setlistu', announced: false, createdAt: serverTimestamp() });
    await assertSucceeds(setDoc(doc(as('ana'), 'feedback/f1'), note('ana')));
    await assertFails(setDoc(doc(as('ana'), 'feedback/f2'), note('bob')));
    await assertFails(getDocs(collection(as('leader'), 'feedback')));
    await assertSucceeds(getDocs(collection(as('owner'), 'feedback')));
  });
});
