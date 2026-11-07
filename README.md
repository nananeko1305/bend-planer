# Bend Planer

Android app (Flutter + Firebase) for one band that books gigs ("tezge"):
everyone sees every gig, adds new ones, and enters the tip after playing.
Serbian (Latin) and English. Three looks to pick from on each phone: the
first start shows a welcome where you choose the language and see each look
live, and both can be changed later in Settings.

Firebase project: `bend-manager` (Firestore in `eur3`), on the Google
account managerbend@gmail.com. The push worker runs on the Cloudflare
account of the same address.

## Accounts and roles

There is no public registration.

| Role | Who | Can |
|---|---|---|
| owner | whoever sells and looks after the app | everything a leader can, plus lock and unlock the app, require a version, make members leaders, read feedback. Hidden from the band and never locked out |
| admin ("šef benda") | the band leader | add members (name, instrument, phone, email, starting password), edit them, remove and bring back |
| member | everyone else | see everything, add gigs, edit and cancel their own, enter any tip |

1. The first account signs in (made in the Firebase console, Authentication →
   Users → Add user) and taps **Postani vlasnik**. This works exactly once:
   `meta/owner` then locks the role.
2. The owner adds the band leader as a member, then makes them leader
   (Bend → tap the member).
3. The leader adds the rest of the band.

A removed member cannot sign in to anything; the gigs they entered keep their
name. Auth accounts are never deleted from the app.

## The lock

`meta/app {locked, minBuild}`, written only by the owner (Settings → Vlasnik):

- **Locked:** the rules refuse every read and write to anyone but the owner,
  and the app shows "Zaključano". Nothing is deleted; unlocking brings it all
  back at once. The worker sends nothing while locked.
- **Required version:** phones on an older build than `minBuild` see only a
  "download the new version" screen. "Traži verziju X" takes the build of the
  newest release from `version.json`.

## Gigs

Date, start and optional end, type (wedding, birthday, kafana, company party,
concert, other), venue, city, address, the client's phone, agreed price in
EUR or RSD, deposit and who holds it, tip yes/no, notes. With a tip: how it
is shared and who plays.

- **Samo za bakšiš (tips only):** a gig without an agreed price, stored as
  `priceMinor` 0 (the rules allow 0 only with a tip, and then no deposit). It
  shows "Za bakšiš" instead of a price, and the report counts it with 0 agreed
  plus its tip.
- Upcoming = today or later. A played gig with a tip waits on the home screen
  ("Čeka bakšiš") until the tip is complete; 0 is a valid tip.
- **Tips are shared one of two ways**, the band's default set by a leader
  (Settings), changeable per gig:
  - *Delimo jednako* (`equal`): someone enters the band's total; it is split
    evenly among the players ticked on the gig, a leftover cent each to the
    first ones so it adds up exactly.
  - *Svako svoje* (`own`): each player's own amount, entered by anyone in the
    band (for themselves, or for a player without the app); the band's tip is
    the sum. Complete once every player has an entry.
- **The report** covers a month or a whole year (then also month by month),
  in two views:
  - *Moja zarada*: a member's own earnings, their part of each agreed price,
    split evenly among the players like an equal tip, plus their tips, with
    gigs played and per gig. The owner, outside the band, sees only the band.
  - *Bend*: the band's totals and "Zarada po članu", each member's earnings
    with the tips part.
  Gigs from before "Ko svira" count as played by the band as it is now.
- Cancelling keeps the gig in the history, struck through, out of the
  report. Delete is for gigs entered by mistake and tells nobody.
- The monthly report is computed from the gigs every time, never stored:
  agreed, tips, total, average, biggest tip, by type, cancelled, what is
  already booked for the next month. Euros and dinars are never added.

## Data model

| Collection | Fields |
|---|---|
| `users/{uid}` | `email`, `role` (`owner`/`admin`/`member`), `disabled`, `firstName`, `lastName`, `instrument`, `phone`, `announced`, `createdAt` |
| `gigs/{id}` | `ownerId`, `date` (yyyy-MM-dd), `start`, `end` (HH:mm or ''), `type`, `venue`, `city`, `address`, `clientName`, `clientPhone`, `priceMinor`, `currency`, `depositMinor`, `depositHolder` (uid or ''), `hasTip`, `tipSplit` (`equal`/`own`, missing = `equal`), `players` (uids who play), `tipMinor` (equal: the band's total, null until entered), `tips` (own: uid → amount), `tipPlayer` (whose entry was written last), `tipBy`, `notes`, `cancelled`, `rev`, `updatedBy`, `createdAt`, `updatedAt`; worker only: `pushRev`, `tipAnnounced`, `remindedEve`, `remindedDay`, `tipNags`, `lastNag` |
| `feedback/{id}` | `uid`, `text`, `announced`, `createdAt`; read by the owner only |
| `pushTokens/{token}` | `uid`; read only by the worker |
| `meta/owner` | `uid` of the owner (one-time claim marker) |
| `meta/app` | `locked`, `minBuild` |
| `meta/band` | `tipSplit`: the band's default way of sharing tips; a leader writes it |
| `meta/report` | `month` of the last monthly report sent (worker) |

Money is in minor units (cents / para) as integers. All access rules are in
[firestore.rules](firestore.rules), tested in [rules_test](rules_test).

## Pushes

Band pushes name gigs and money, so they never go to a topic: the
[push worker](push_worker) sends them to the phones of active members one by
one. The owner is not in the band and gets only feedback.

| Push | When | Channel |
|---|---|---|
| New / changed / cancelled gig | on save; not to whoever saved it | gigs |
| Tip entered | on save | tips |
| "Sutra svirate" | 20:00 the evening before | reminders |
| "Danas svirate" | 09:00 on the day | reminders |
| "Unesite bakšiš" | 09:00, daily, up to 3 times within a week | reminders |
| Monthly report | 09:00 on the 1st (or the next two days) | reports |
| New member / member left | when a leader adds or removes | band |
| Feedback | when a member sends it; owner only | band |
| New version | after every release (CI, topic `releases`) | updates |

How a change reaches the band:

1. Every edit bumps `rev`; entering a tip sets `tipAnnounced: false`; a new or
   removed member has `announced: false`.
2. The phone that made the change asks `POST /announce {kind, id}` with its
   Firebase ID token once the server has the change. It asks again on every
   start until the worker marks it, which covers offline saves and a worker
   that was down.
3. The worker checks the token, that the caller is active and the one who
   made the change, marks the record only if it has not changed since it read
   it, and only then sends. A repeated call sends nothing; if FCM fails right
   then, that push is lost rather than sent twice.

Titles are string resources in the app, so each phone shows its own language.
Every kind has its own Android channel, so each member can mute one kind in
the phone's settings (Settings → Obaveštenja).

## Release

- Work happens on `dev`; a PR from `dev` to `main` ships. **Every merge into
  `main` builds a signed APK, publishes a GitHub Release and the download page
  with `version.json`, and notifies every install.** A change to
  `.github/pages/**` alone redeploys only the page.
- The commit type sets the version: `feat` bumps the minor, anything else the
  patch, a breaking change the major. `pubspec.yaml` is only a floor.
- Download page: https://nananeko1305.github.io/bend-planer/
- The APK is named after its version (`bend-planer-1.3.2.apk`); the page and
  `version.json` link to that file of their release. Every release also
  carries the same APK as `bend-planer.apk`, because installs up to 1.3.1
  open `releases/latest/download/bend-planer.apk`. Newer installs share and
  download through the page instead.

| Piece | Deployed by | When |
|---|---|---|
| App | CI, on a push to `main` | merging is the release |
| `firestore.rules` | `firebase deploy --only firestore:rules` | **before** the merge that needs them |
| Push worker | `npm run deploy` in `push_worker/` | **before** the merge that needs it |

GitHub secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `FCM_SERVICE_ACCOUNT`.
Cloudflare secret: `GOOGLE_SERVICE_ACCOUNT`. The originals are kept outside
this repository, together with a list of what each one is.

## Testing

```sh
flutter analyze && flutter test       # the same gate CI runs
cd push_worker && npm test            # the worker, with fakes
cd rules_test && npm install && npm test   # the rules, on the Firestore emulator
```

## Fonts

Unbounded, Manrope, Tilt Neon, Monoton, Outfit and Playfair Display, bundled
under `assets/fonts/` with their SIL Open Font Licenses.
