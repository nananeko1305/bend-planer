# Bend Planer: architecture map

Android-only Flutter app for one band that books gigs. Accounts exist only if
a leader creates them; a hidden owner above the leader can lock the app.

The README below is imported and holds the product rules, the data model, the
push design and the release process. This file adds what the README does not:
how the code fits together, and what breaks if you forget it.

@README.md

The global guidelines about Go layout and Neutrino libraries do not apply here:
there is no Go in this repository.

**Keep this true:** a change that alters anything below updates this file in the
same commit. No version numbers, line counts or lists of every file. The
repository is **public**, so nothing secret goes here.

## System

```
                     ┌─ Firebase Auth      email/password, no self sign-up
 Android app ────────┼─ Firestore          direct from the app, offline cache on
 (Flutter)           ├─ Push worker        POST /announce
                     ├─ GitHub Pages       version.json, the update check
                     └─ FCM                receives pushes

 Push worker ────────┬─ Firestore REST     service account, bypasses the rules
 (Cloudflare, cron)  └─ FCM v1             per-phone pushes

 GitHub Actions ─────┬─ GitHub Release     the APK
 (push to main)      ├─ GitHub Pages       download page + version.json
                     └─ FCM topic          `releases`, every install
```

**`firestore.rules` is the security boundary** for everything the app does,
including the lock. The worker skips those rules, so **its own checks in
`push_worker/src/band.js` and `announce.js` are the only boundary on its
path**: the caller's token, active and not locked, and that the caller made
the change.

## Code map

Start-up: `main.dart` → `StartGate` (first start on this phone: `WelcomeScreen`,
language then look) → `AuthGate` (signed in?) → `ProfileGate` (profile,
removed, or the one-time owner claim) → `AppGate` (`meta/app`: locked, or build
too old) → `HomeScreen`. Each gate watches live; `AuthGate` keys `ProfileGate`
by uid, so switching accounts resets everything below.

| Path | Holds |
|---|---|
| `lib/models/` | Immutable classes and the pure logic: `Gig` + `GigDraft` (and the exact maps the rules expect), `MonthReport`, `day_key` (dates as text, times), `BandPush` |
| `lib/money/` | `Currency`, formatting and parsing |
| `lib/services/` | Repositories (`XRepository.instance`), `LiveData`, `Announcer` + `worker_client`, push, auth, updates, `ReminderHealth` |
| `lib/screens/` | Gates, `HomeScreen` (the shell with four tabs), the tabs, gig form and detail, settings, feedback, share |
| `lib/widgets/` | Reusable pieces: gig card and formatting, skin widgets, dialogs, owner section |
| `lib/theme/` | `AppColors` (one `ThemeExtension` per look), `kSkins`, `AppTheme`, `SkinBackdrop`, `ThemeController` |
| `lib/l10n/` | `app_en.arb` (template) and `app_sr.arb`; the generated Dart is committed |
| `push_worker/src/` | `index.js` the routes, `announce.js` the route's checks and pushes, `cron.js` + `due.js` the scheduled runs, `band.js` who gets what, `message.js` text and dates (pure), `google.js` all Firestore and FCM calls |
| `rules_test/` | The rules on the Firestore emulator |
| `android/app/src/main/` | `MainActivity.kt` creates the six notification channels and answers `ReminderHealth`; `res/values*/strings.xml` hold push titles |

## How the app works

- **Reads go through `LiveData`** (users and gigs), owned by `HomeScreen`. It
  resubscribes with backoff, because a Firestore listener that errors never
  recovers. Filtering and sorting are on the client, so `firestore.indexes.json`
  is empty. The worker's `gigsBetween` is a range on one field, which needs no
  composite index either.
- **Writes go through `saveInBackground`; never await a Firestore write in UI.**
  It does not complete offline. Exceptions: the owner claim and adding a member,
  which wait for the answer.
- **Every write matches one case of the rules exactly.** `Gig.newDocMap`,
  `editMap`, `cancelMap` and `tipMap` are those cases; a new field goes in the
  rules' key lists and `validGig` too, or every save fails.
- **Dates are `yyyy-MM-dd` text**, times `HH:mm`. The worker compares them as
  text in Belgrade days.
- **Serbian is `sr-Latn`, never plain `sr`** (Cyrillic dates). Any Serbian,
  Croatian or Bosnian phone gets `sr-Latn` (`resolveLocale`). Push titles are in
  `values-sr` and `values-b+sr+Latn`; keep the two the same.
- **Looks:** read colors and fonts through `context.colors`, never hard-coded.
  `AppColors.display()` is the display font with the look's glow. All three
  looks are dark.
- **Money is an `int` in minor units**; EUR and RSD never add up.
- **User-visible text goes through `AppLocalizations`**, in both `.arb` files,
  then `flutter gen-l10n`.
- **SnackBars with an action need `persist: false`** (Flutter 3.47 keeps them
  otherwise).
- **A widget that reads `themeController` or `localeController` listens to it
  itself** (`ListenableBuilder`): used as `const`, its parent's rebuild skips
  it and it shows the old value (`skin_picker_test.dart`).
- **Tabs pad their content, not the `TabHeader`**, so the header sits at the
  same place on every tab.
- **Sign-out order** (`AuthService.signOut`): delete the token document (needs
  the sign-in), sign out, then delete the FCM token.

## What a change has to touch

**New field on a gig:** `GigDraft` (form fields) or `Gig`, `fromDoc` with a
default (old documents and old APKs exist), the rules (`formKeys` or
`newGigKeys`, `validGig`; leave it out of `requiredFormKeys` so an older app
can still create), the README table, `rules_test/`. Deploy the rules first.

**Price:** show it through `priceOf` (it says "Za bakšiš" for a tips-only gig,
`Gig.tipOnly`, price 0); the worker's `gigLine` leaves a 0 price out.

**Tips:** read them through `Gig.tipTotal`, `tipComplete` and `tipShares`,
never `tipMinor` alone (that is only the equal-split total). The worker's
`gigTipTotal` and `tipComplete` in `due.js` mirror them; change both.

**New push kind:** `message.js` (`KINDS`), `PushKind` in `band_push.dart` and
`bandPushTitle`, the l10n key, the title in `res/values/`, `values-sr/` and
`values-b+sr+Latn/strings.xml`, `res/raw/keep.xml` (or shrinking empties the
notification), and the CI step "Verify notification resources". A new channel
also goes in `MainActivity.kt`.

**Worker reads a new field:** `decodeValue` reads strings, booleans, integers,
doubles, timestamps and arrays; anything else comes back as null.

## Shipping

- **This project has its own accounts.** Firebase: `firebase login:use` is set
  for this folder (managerbend@gmail.com). Cloudflare: `push_worker/.env`,
  loaded by the npm scripts; a bare `wrangler` uses another account. gcloud:
  `CLOUDSDK_CONFIG=~/.config/gcloud-bend`.
- Work on `dev`; the owner merges PRs into `main`, and every merge reaches every
  phone.
- Conventional Commits with a scope; `feat` bumps the minor, `ci(pages):` for
  page-only work.

## Testing

There is no fake Firestore, and repositories bind `FirebaseFirestore.instance`
when created. Logic worth testing goes in `models/` or takes its dependencies
as arguments (`pendingAnnouncements`, `LiveData(listen: false)`).
`test/screens_fit_test.dart` renders the home and report tabs in every look and
both languages at 360 px.
