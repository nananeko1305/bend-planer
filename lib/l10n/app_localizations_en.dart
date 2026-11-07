// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bend Planer';

  @override
  String get appTagline => 'Every gig, every euro, the whole band.';

  @override
  String get loginSubtitle => 'Use the account your band leader made for you.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetSent => 'Password reset email sent.';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get minChars6 => 'At least 6 characters';

  @override
  String get wait => 'Please wait...';

  @override
  String get required => 'Required';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get send => 'Send';

  @override
  String get open => 'Open';

  @override
  String get call => 'Call';

  @override
  String get synced => 'Synced';

  @override
  String get syncing => 'Syncing...';

  @override
  String get download => 'Download';

  @override
  String get later => 'Later';

  @override
  String get newVersionTitle => 'New version available';

  @override
  String newVersionBody(String version, String current) {
    return 'Version $version is ready to download. You have $current.';
  }

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get checkUpdates => 'Check for updates';

  @override
  String get updateCheckFailed => 'Couldn\'t check for updates.';

  @override
  String get upToDate => 'You have the latest version.';

  @override
  String get nextMonth => 'Next month';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get passwordChanged => 'Password changed.';

  @override
  String get passwordsNoMatch => 'Passwords do not match';

  @override
  String get errNoNetwork => 'No internet connection.';

  @override
  String get errInvalidEmail => 'The email is not valid.';

  @override
  String get errEmailInUse => 'An account with this email already exists.';

  @override
  String get errWeakPassword => 'Password is too weak (min. 6 characters).';

  @override
  String get errUserDisabled => 'This account is disabled.';

  @override
  String get errWrongCredentials => 'Wrong email or password.';

  @override
  String get errRecentLogin => 'Sign out, sign in again and try once more.';

  @override
  String get errTooMany => 'Too many attempts. Try again in a few minutes.';

  @override
  String get errPermission => 'You don\'t have permission for this action.';

  @override
  String get errGeneric => 'Something went wrong. Please try again.';

  @override
  String get tabGigs => 'Gigs';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabReport => 'Report';

  @override
  String get tabBand => 'Band';

  @override
  String get addGig => 'Gig';

  @override
  String get notifications => 'Notifications';

  @override
  String get settings => 'Settings';

  @override
  String get contractedSoFar => 'agreed so far';

  @override
  String gigCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gigs',
      one: '1 gig',
    );
    return '$_temp0';
  }

  @override
  String get awaitingTip => 'Awaiting tip';

  @override
  String get enterTipShort => 'Enter';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get noUpcoming => 'No gigs booked yet. Tap + Gig to add one.';

  @override
  String get noPast => 'No past gigs yet.';

  @override
  String tonightAt(String time) {
    return 'Tonight · $time';
  }

  @override
  String todayAt(String time) {
    return 'Today · $time';
  }

  @override
  String inDaysAt(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count days',
      one: 'Tomorrow',
    );
    return '$_temp0 · $time';
  }

  @override
  String get tipChip => 'Tip';

  @override
  String get noTipChip => 'No tip';

  @override
  String depositChip(String amount) {
    return 'Deposit $amount';
  }

  @override
  String tipAmountChip(String amount) {
    return 'Tip $amount';
  }

  @override
  String get cancelledChip => 'Cancelled';

  @override
  String get typeWedding => 'Wedding';

  @override
  String get typeBirthday => 'Birthday';

  @override
  String get typeKafana => 'Kafana';

  @override
  String get typeCompany => 'Company party';

  @override
  String get typeConcert => 'Concert';

  @override
  String get typeOther => 'Other';

  @override
  String get newGigTitle => 'New gig';

  @override
  String get editGigTitle => 'Edit gig';

  @override
  String get sectionWhen => 'When';

  @override
  String get sectionType => 'Type';

  @override
  String get sectionWhere => 'Where and for whom';

  @override
  String get sectionMoney => 'Price';

  @override
  String get sectionNotes => 'Notes';

  @override
  String get date => 'Date';

  @override
  String get startTime => 'Start';

  @override
  String get endTime => 'End (optional)';

  @override
  String sameDayWarning(String what) {
    return 'There is already a gig that day: $what.';
  }

  @override
  String get venue => 'Venue';

  @override
  String get city => 'City';

  @override
  String get address => 'Address (optional)';

  @override
  String get clientPhone => 'Client\'s phone (optional)';

  @override
  String get price => 'Agreed price';

  @override
  String get depositGiven => 'Deposit paid';

  @override
  String get depositAmount => 'Deposit';

  @override
  String get depositHolder => 'Who has it';

  @override
  String get tipQuestion => 'Tip';

  @override
  String get hasTip => 'Tip';

  @override
  String get noTip => 'No tip';

  @override
  String get tipHint =>
      'After the gig it waits for someone to enter the tip, and everyone gets a reminder.';

  @override
  String get notesHint => 'Gear, sound, what to play';

  @override
  String get saveGig => 'Save gig';

  @override
  String get enterAmount => 'Enter an amount';

  @override
  String get depositTooBig => 'The deposit is more than the price';

  @override
  String get whenLabel => 'When';

  @override
  String get whereLabel => 'Where';

  @override
  String get clientLabel => 'Client';

  @override
  String get priceLabel => 'Price';

  @override
  String get depositLabel => 'Deposit';

  @override
  String get tipLabel => 'Tip';

  @override
  String get notesLabel => 'Notes';

  @override
  String get openMap => 'Map';

  @override
  String addedBy(String name) {
    return 'Added by $name';
  }

  @override
  String tipBy(String name) {
    return 'Entered by $name';
  }

  @override
  String get tipWaiting => 'Waiting for the tip';

  @override
  String get tipLater => 'After the gig';

  @override
  String get enterTip => 'Enter tip';

  @override
  String get changeTip => 'Change tip';

  @override
  String tipFor(String what) {
    return 'Tip for $what';
  }

  @override
  String get tipAmount => 'Tip amount';

  @override
  String get cancelGig => 'Cancel gig';

  @override
  String get cancelGigConfirm =>
      'Cancel this gig? It stays in the history and everyone gets a notification.';

  @override
  String get keepGig => 'Keep it';

  @override
  String get restoreGig => 'Restore gig';

  @override
  String get deleteGig => 'Delete gig';

  @override
  String get deleteGigConfirm =>
      'Delete this gig for good? Only for a gig entered by mistake. Nobody gets a notification.';

  @override
  String get gigGone => 'This gig no longer exists.';

  @override
  String get nothingThatDay => 'Nothing booked on this day.';

  @override
  String get addOnThisDay => 'Add a gig on this day';

  @override
  String get totalEarned => 'Total earned';

  @override
  String get agreedPlusTips => 'agreed + tips';

  @override
  String get agreed => 'Agreed';

  @override
  String get tips => 'Tips';

  @override
  String get gigsLabel => 'Gigs';

  @override
  String get cancelledLabel => 'Cancelled';

  @override
  String get averageLabel => 'Average';

  @override
  String get biggestTip => 'Biggest tip';

  @override
  String get byType => 'By type';

  @override
  String alreadyBooked(String month) {
    return '$month · already booked';
  }

  @override
  String get reportEmpty => 'No gigs this month.';

  @override
  String tipsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gigs still wait for their tip.',
      one: '1 gig still waits for its tip.',
    );
    return '$_temp0';
  }

  @override
  String get dinarsApart => 'Amounts in dinars are counted apart from euros.';

  @override
  String get bandTitle => 'Band';

  @override
  String get addMember => 'Add member';

  @override
  String get editMember => 'Edit member';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get instrument => 'Instrument (optional)';

  @override
  String get phone => 'Phone (optional)';

  @override
  String get startPassword => 'Starting password';

  @override
  String get startPasswordHint =>
      'Tell it to the member; they can change it in Settings.';

  @override
  String get roleAdmin => 'Band leader';

  @override
  String get roleMember => 'Member';

  @override
  String get roleOwner => 'Owner';

  @override
  String get youSuffix => '(you)';

  @override
  String get removeMember => 'Remove from band';

  @override
  String removeMemberConfirm(String name) {
    return 'Remove $name from the band? They can no longer sign in. The gigs they entered stay.';
  }

  @override
  String get removedMembers => 'Removed';

  @override
  String get restoreMember => 'Bring back';

  @override
  String get makeAdmin => 'Make band leader';

  @override
  String get makeMember => 'Make a regular member';

  @override
  String memberCreated(String name, String email) {
    return '$name can now sign in with $email.';
  }

  @override
  String get noMembers => 'Nobody here yet. Add the first member.';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get look => 'Look';

  @override
  String get skinBina => 'Stage';

  @override
  String get skinNeon => 'Neon';

  @override
  String get skinZlato => 'Gold';

  @override
  String get skinBinaHint => 'Concert lights';

  @override
  String get skinNeonHint => 'A club at night';

  @override
  String get skinZlatoHint => 'Black and gold';

  @override
  String get language => 'Language';

  @override
  String get languagePhone => 'Phone language';

  @override
  String get notificationsHint => 'Choose which ones you get';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get feedbackHint =>
      'Ideas and problems go straight to the person who makes the app.';

  @override
  String get feedbackField => 'What would you change?';

  @override
  String get feedbackSent => 'Sent. Thank you!';

  @override
  String get shareApp => 'Share the app';

  @override
  String get shareAppHint =>
      'Scan the code with another phone\'s camera, or send the link. Android will ask to allow installing from that source.';

  @override
  String get shareAppMessage =>
      'Bend Planer: every gig of the band in one place.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied.';

  @override
  String get sendLink => 'Send';

  @override
  String get ownerSection => 'Owner';

  @override
  String get appLocked => 'Locked: nobody in the band can use the app.';

  @override
  String get appUnlocked => 'Unlocked: the band uses the app.';

  @override
  String get lockApp => 'Lock the app';

  @override
  String get unlockApp => 'Unlock the app';

  @override
  String get lockConfirm =>
      'Lock the app for the whole band? Nothing is deleted, and unlocking brings everything back.';

  @override
  String get requiredVersion => 'Required version';

  @override
  String get anyVersion => 'Any version may be used.';

  @override
  String versionRequired(int build) {
    return 'Build $build or newer is required.';
  }

  @override
  String requireLatest(String version) {
    return 'Require version $version';
  }

  @override
  String get allowAnyVersion => 'Allow any version';

  @override
  String get feedbackList => 'Feedback';

  @override
  String get noFeedback => 'No feedback yet.';

  @override
  String get claimOwnerTitle => 'Set up the app';

  @override
  String get claimOwnerBody =>
      'This is the first account. It becomes the owner: it can lock the app and adds the band leader.';

  @override
  String get claimOwnerButton => 'Become the owner';

  @override
  String get noAccessTitle => 'No access';

  @override
  String get noAccessBody => 'Ask the band leader to add you.';

  @override
  String get removedTitle => 'You are no longer in the band';

  @override
  String get removedBody => 'Ask the band leader if this is a mistake.';

  @override
  String get lockedTitle => 'Locked';

  @override
  String get lockedBody => 'The app is locked for now.';

  @override
  String get lockedSafe => 'Your data is safe';

  @override
  String get lockedSafeBody =>
      'Nothing has been deleted. Once it is unlocked, everything is back.';

  @override
  String get lockedContact => 'Ask your band leader for details.';

  @override
  String get lockedContactLeader => 'Ask whoever set up the app for the band.';

  @override
  String get forceUpdateTitle => 'Update needed';

  @override
  String get forceUpdateBody =>
      'This version is too old. Download the new one to go on.';

  @override
  String get tryAgain => 'Try again';

  @override
  String pushGigNew(String date) {
    return 'New gig · $date';
  }

  @override
  String pushGigChanged(String date) {
    return 'Gig changed · $date';
  }

  @override
  String pushGigCancelled(String date) {
    return 'Gig cancelled · $date';
  }

  @override
  String pushTip(String date) {
    return 'Tip entered · $date';
  }

  @override
  String get pushTomorrow => 'Playing tomorrow';

  @override
  String get pushToday => 'Playing today';

  @override
  String get pushTipReminder => 'Enter the tip';

  @override
  String pushReport(String month) {
    return 'Report for $month';
  }

  @override
  String get pushMemberAdded => 'New band member';

  @override
  String get pushMemberRemoved => 'Member left the band';

  @override
  String get pushFeedback => 'New feedback';

  @override
  String get notificationsOffTitle => 'Notifications are off';

  @override
  String get notificationsOffBody =>
      'You won\'t hear about new gigs or get reminders.';

  @override
  String get hibernationTitle => 'Keep the notifications coming';

  @override
  String get hibernationBody =>
      'Android puts apps you don\'t open for a while to sleep, and notifications stop. Turn that off for this app.';

  @override
  String get turnOn => 'Turn on';

  @override
  String get openSettings => 'Open settings';

  @override
  String get notNow => 'Not now';

  @override
  String get welcomeChooseLanguage => 'Izaberi jezik · Choose your language';

  @override
  String get welcomeNext => 'Next';

  @override
  String get welcomeLookTitle => 'Pick your look';

  @override
  String get welcomeLookHint =>
      'Swipe to see all three. You can change it any time in Settings.';

  @override
  String get welcomeStart => 'Let\'s go';

  @override
  String get welcomeSampleVenue => 'Hotel Grand';

  @override
  String get welcomeSampleCity => 'Belgrade';

  @override
  String get tipSplitLabel => 'How you share the tip';

  @override
  String get tipSplitEqual => 'Shared equally';

  @override
  String get tipSplitOwn => 'Each their own';

  @override
  String get tipSplitEqualHint =>
      'After the gig someone enters the band\'s total; it is split evenly among those who played.';

  @override
  String get tipSplitOwnHint =>
      'After the gig everyone enters what they got; the band\'s tip is the sum.';

  @override
  String get tipSplitSettingsHint => 'For new gigs; each gig can change it.';

  @override
  String get tipSplitLeaderOnly => 'The band leader chooses this.';

  @override
  String get whoPlays => 'Who plays';

  @override
  String get pickPlayers => 'Tick at least one member.';

  @override
  String tipTotal(String amount) {
    return 'Total $amount';
  }

  @override
  String tipForPlayer(String name) {
    return 'Tip: $name';
  }

  @override
  String get tipNotEntered => 'not entered';

  @override
  String get tipsByMember => 'Tips by member';

  @override
  String get tipOnly => 'Tips only';

  @override
  String get tipOnlyHint => 'No agreed price: the band plays for tips.';

  @override
  String get tipOnlyPrice => 'For tips';
}
