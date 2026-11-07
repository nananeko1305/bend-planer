import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bend Planer'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Every gig, every euro, the whole band.'**
  String get appTagline;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the account your band leader made for you.'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get resetSent;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @minChars6.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get minChars6;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get wait;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @newVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'New version available'**
  String get newVersionTitle;

  /// No description provided for @newVersionBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is ready to download. You have {current}.'**
  String newVersionBody(String version, String current);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @checkUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkUpdates;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for updates.'**
  String get updateCheckFailed;

  /// No description provided for @upToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the latest version.'**
  String get upToDate;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get passwordChanged;

  /// No description provided for @passwordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNoMatch;

  /// No description provided for @errNoNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errNoNetwork;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email is not valid.'**
  String get errInvalidEmail;

  /// No description provided for @errEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists.'**
  String get errEmailInUse;

  /// No description provided for @errWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak (min. 6 characters).'**
  String get errWeakPassword;

  /// No description provided for @errUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is disabled.'**
  String get errUserDisabled;

  /// No description provided for @errWrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errWrongCredentials;

  /// No description provided for @errRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign out, sign in again and try once more.'**
  String get errRecentLogin;

  /// No description provided for @errTooMany.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a few minutes.'**
  String get errTooMany;

  /// No description provided for @errPermission.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission for this action.'**
  String get errPermission;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @tabGigs.
  ///
  /// In en, this message translates to:
  /// **'Gigs'**
  String get tabGigs;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get tabReport;

  /// No description provided for @tabBand.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get tabBand;

  /// No description provided for @addGig.
  ///
  /// In en, this message translates to:
  /// **'Gig'**
  String get addGig;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @contractedSoFar.
  ///
  /// In en, this message translates to:
  /// **'agreed so far'**
  String get contractedSoFar;

  /// No description provided for @gigCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 gig} other{{count} gigs}}'**
  String gigCount(int count);

  /// No description provided for @awaitingTip.
  ///
  /// In en, this message translates to:
  /// **'Awaiting tip'**
  String get awaitingTip;

  /// No description provided for @enterTipShort.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get enterTipShort;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @noUpcoming.
  ///
  /// In en, this message translates to:
  /// **'No gigs booked yet. Tap + Gig to add one.'**
  String get noUpcoming;

  /// No description provided for @noPast.
  ///
  /// In en, this message translates to:
  /// **'No past gigs yet.'**
  String get noPast;

  /// No description provided for @tonightAt.
  ///
  /// In en, this message translates to:
  /// **'Tonight · {time}'**
  String tonightAt(String time);

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today · {time}'**
  String todayAt(String time);

  /// No description provided for @inDaysAt.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tomorrow} other{In {count} days}} · {time}'**
  String inDaysAt(int count, String time);

  /// No description provided for @tipChip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tipChip;

  /// No description provided for @noTipChip.
  ///
  /// In en, this message translates to:
  /// **'No tip'**
  String get noTipChip;

  /// No description provided for @depositChip.
  ///
  /// In en, this message translates to:
  /// **'Deposit {amount}'**
  String depositChip(String amount);

  /// No description provided for @tipAmountChip.
  ///
  /// In en, this message translates to:
  /// **'Tip {amount}'**
  String tipAmountChip(String amount);

  /// No description provided for @cancelledChip.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledChip;

  /// No description provided for @typeWedding.
  ///
  /// In en, this message translates to:
  /// **'Wedding'**
  String get typeWedding;

  /// No description provided for @typeBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get typeBirthday;

  /// No description provided for @typeKafana.
  ///
  /// In en, this message translates to:
  /// **'Kafana'**
  String get typeKafana;

  /// No description provided for @typeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company party'**
  String get typeCompany;

  /// No description provided for @typeConcert.
  ///
  /// In en, this message translates to:
  /// **'Concert'**
  String get typeConcert;

  /// No description provided for @typeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get typeOther;

  /// No description provided for @newGigTitle.
  ///
  /// In en, this message translates to:
  /// **'New gig'**
  String get newGigTitle;

  /// No description provided for @editGigTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit gig'**
  String get editGigTitle;

  /// No description provided for @sectionWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get sectionWhen;

  /// No description provided for @sectionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get sectionType;

  /// No description provided for @sectionWhere.
  ///
  /// In en, this message translates to:
  /// **'Where and for whom'**
  String get sectionWhere;

  /// No description provided for @sectionMoney.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get sectionMoney;

  /// No description provided for @sectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get sectionNotes;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End (optional)'**
  String get endTime;

  /// No description provided for @sameDayWarning.
  ///
  /// In en, this message translates to:
  /// **'There is already a gig that day: {what}.'**
  String sameDayWarning(String what);

  /// No description provided for @venue.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get venue;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get address;

  /// No description provided for @clientPhone.
  ///
  /// In en, this message translates to:
  /// **'Client\'s phone (optional)'**
  String get clientPhone;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Agreed price'**
  String get price;

  /// No description provided for @depositGiven.
  ///
  /// In en, this message translates to:
  /// **'Deposit paid'**
  String get depositGiven;

  /// No description provided for @depositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositAmount;

  /// No description provided for @depositHolder.
  ///
  /// In en, this message translates to:
  /// **'Who has it'**
  String get depositHolder;

  /// No description provided for @tipQuestion.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tipQuestion;

  /// No description provided for @hasTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get hasTip;

  /// No description provided for @noTip.
  ///
  /// In en, this message translates to:
  /// **'No tip'**
  String get noTip;

  /// No description provided for @tipHint.
  ///
  /// In en, this message translates to:
  /// **'After the gig it waits for someone to enter the tip, and everyone gets a reminder.'**
  String get tipHint;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Gear, sound, what to play'**
  String get notesHint;

  /// No description provided for @saveGig.
  ///
  /// In en, this message translates to:
  /// **'Save gig'**
  String get saveGig;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get enterAmount;

  /// No description provided for @depositTooBig.
  ///
  /// In en, this message translates to:
  /// **'The deposit is more than the price'**
  String get depositTooBig;

  /// No description provided for @whenLabel.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get whenLabel;

  /// No description provided for @whereLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get whereLabel;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientLabel;

  /// No description provided for @priceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceLabel;

  /// No description provided for @depositLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositLabel;

  /// No description provided for @tipLabel.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get tipLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get openMap;

  /// No description provided for @addedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String addedBy(String name);

  /// No description provided for @tipBy.
  ///
  /// In en, this message translates to:
  /// **'Entered by {name}'**
  String tipBy(String name);

  /// No description provided for @tipWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the tip'**
  String get tipWaiting;

  /// No description provided for @tipLater.
  ///
  /// In en, this message translates to:
  /// **'After the gig'**
  String get tipLater;

  /// No description provided for @enterTip.
  ///
  /// In en, this message translates to:
  /// **'Enter tip'**
  String get enterTip;

  /// No description provided for @changeTip.
  ///
  /// In en, this message translates to:
  /// **'Change tip'**
  String get changeTip;

  /// No description provided for @tipFor.
  ///
  /// In en, this message translates to:
  /// **'Tip for {what}'**
  String tipFor(String what);

  /// No description provided for @tipAmount.
  ///
  /// In en, this message translates to:
  /// **'Tip amount'**
  String get tipAmount;

  /// No description provided for @cancelGig.
  ///
  /// In en, this message translates to:
  /// **'Cancel gig'**
  String get cancelGig;

  /// No description provided for @cancelGigConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this gig? It stays in the history and everyone gets a notification.'**
  String get cancelGigConfirm;

  /// No description provided for @keepGig.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepGig;

  /// No description provided for @restoreGig.
  ///
  /// In en, this message translates to:
  /// **'Restore gig'**
  String get restoreGig;

  /// No description provided for @deleteGig.
  ///
  /// In en, this message translates to:
  /// **'Delete gig'**
  String get deleteGig;

  /// No description provided for @deleteGigConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this gig for good? Only for a gig entered by mistake. Nobody gets a notification.'**
  String get deleteGigConfirm;

  /// No description provided for @gigGone.
  ///
  /// In en, this message translates to:
  /// **'This gig no longer exists.'**
  String get gigGone;

  /// No description provided for @nothingThatDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing booked on this day.'**
  String get nothingThatDay;

  /// No description provided for @addOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'Add a gig on this day'**
  String get addOnThisDay;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get totalEarned;

  /// No description provided for @agreedPlusTips.
  ///
  /// In en, this message translates to:
  /// **'agreed + tips'**
  String get agreedPlusTips;

  /// No description provided for @agreed.
  ///
  /// In en, this message translates to:
  /// **'Agreed'**
  String get agreed;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @gigsLabel.
  ///
  /// In en, this message translates to:
  /// **'Gigs'**
  String get gigsLabel;

  /// No description provided for @cancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelledLabel;

  /// No description provided for @averageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get averageLabel;

  /// No description provided for @biggestTip.
  ///
  /// In en, this message translates to:
  /// **'Biggest tip'**
  String get biggestTip;

  /// No description provided for @byType.
  ///
  /// In en, this message translates to:
  /// **'By type'**
  String get byType;

  /// No description provided for @alreadyBooked.
  ///
  /// In en, this message translates to:
  /// **'{month} · already booked'**
  String alreadyBooked(String month);

  /// No description provided for @reportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No gigs this month.'**
  String get reportEmpty;

  /// No description provided for @tipsPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 gig still waits for its tip.} other{{count} gigs still wait for their tip.}}'**
  String tipsPending(int count);

  /// No description provided for @dinarsApart.
  ///
  /// In en, this message translates to:
  /// **'Amounts in dinars are counted apart from euros.'**
  String get dinarsApart;

  /// No description provided for @bandTitle.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get bandTitle;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// No description provided for @editMember.
  ///
  /// In en, this message translates to:
  /// **'Edit member'**
  String get editMember;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @instrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument (optional)'**
  String get instrument;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phone;

  /// No description provided for @startPassword.
  ///
  /// In en, this message translates to:
  /// **'Starting password'**
  String get startPassword;

  /// No description provided for @startPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Tell it to the member; they can change it in Settings.'**
  String get startPasswordHint;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Band leader'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleMember;

  /// No description provided for @roleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get roleOwner;

  /// No description provided for @youSuffix.
  ///
  /// In en, this message translates to:
  /// **'(you)'**
  String get youSuffix;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove from band'**
  String get removeMember;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the band? They can no longer sign in. The gigs they entered stay.'**
  String removeMemberConfirm(String name);

  /// No description provided for @removedMembers.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removedMembers;

  /// No description provided for @restoreMember.
  ///
  /// In en, this message translates to:
  /// **'Bring back'**
  String get restoreMember;

  /// No description provided for @makeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make band leader'**
  String get makeAdmin;

  /// No description provided for @makeMember.
  ///
  /// In en, this message translates to:
  /// **'Make a regular member'**
  String get makeMember;

  /// No description provided for @memberCreated.
  ///
  /// In en, this message translates to:
  /// **'{name} can now sign in with {email}.'**
  String memberCreated(String name, String email);

  /// No description provided for @noMembers.
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet. Add the first member.'**
  String get noMembers;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @look.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get look;

  /// No description provided for @skinBina.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get skinBina;

  /// No description provided for @skinNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get skinNeon;

  /// No description provided for @skinZlato.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get skinZlato;

  /// No description provided for @skinBinaHint.
  ///
  /// In en, this message translates to:
  /// **'Concert lights'**
  String get skinBinaHint;

  /// No description provided for @skinNeonHint.
  ///
  /// In en, this message translates to:
  /// **'A club at night'**
  String get skinNeonHint;

  /// No description provided for @skinZlatoHint.
  ///
  /// In en, this message translates to:
  /// **'Black and gold'**
  String get skinZlatoHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languagePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone language'**
  String get languagePhone;

  /// No description provided for @notificationsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose which ones you get'**
  String get notificationsHint;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Ideas and problems go straight to the person who makes the app.'**
  String get feedbackHint;

  /// No description provided for @feedbackField.
  ///
  /// In en, this message translates to:
  /// **'What would you change?'**
  String get feedbackField;

  /// No description provided for @feedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. Thank you!'**
  String get feedbackSent;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share the app'**
  String get shareApp;

  /// No description provided for @shareAppHint.
  ///
  /// In en, this message translates to:
  /// **'Scan the code with another phone\'s camera, or send the link. Android will ask to allow installing from that source.'**
  String get shareAppHint;

  /// No description provided for @shareAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Bend Planer: every gig of the band in one place.'**
  String get shareAppMessage;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get linkCopied;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendLink;

  /// No description provided for @ownerSection.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerSection;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked: nobody in the band can use the app.'**
  String get appLocked;

  /// No description provided for @appUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked: the band uses the app.'**
  String get appUnlocked;

  /// No description provided for @lockApp.
  ///
  /// In en, this message translates to:
  /// **'Lock the app'**
  String get lockApp;

  /// No description provided for @unlockApp.
  ///
  /// In en, this message translates to:
  /// **'Unlock the app'**
  String get unlockApp;

  /// No description provided for @lockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Lock the app for the whole band? Nothing is deleted, and unlocking brings everything back.'**
  String get lockConfirm;

  /// No description provided for @requiredVersion.
  ///
  /// In en, this message translates to:
  /// **'Required version'**
  String get requiredVersion;

  /// No description provided for @anyVersion.
  ///
  /// In en, this message translates to:
  /// **'Any version may be used.'**
  String get anyVersion;

  /// No description provided for @versionRequired.
  ///
  /// In en, this message translates to:
  /// **'Build {build} or newer is required.'**
  String versionRequired(int build);

  /// No description provided for @requireLatest.
  ///
  /// In en, this message translates to:
  /// **'Require version {version}'**
  String requireLatest(String version);

  /// No description provided for @allowAnyVersion.
  ///
  /// In en, this message translates to:
  /// **'Allow any version'**
  String get allowAnyVersion;

  /// No description provided for @feedbackList.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackList;

  /// No description provided for @noFeedback.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet.'**
  String get noFeedback;

  /// No description provided for @claimOwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the app'**
  String get claimOwnerTitle;

  /// No description provided for @claimOwnerBody.
  ///
  /// In en, this message translates to:
  /// **'This is the first account. It becomes the owner: it can lock the app and adds the band leader.'**
  String get claimOwnerBody;

  /// No description provided for @claimOwnerButton.
  ///
  /// In en, this message translates to:
  /// **'Become the owner'**
  String get claimOwnerButton;

  /// No description provided for @noAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'No access'**
  String get noAccessTitle;

  /// No description provided for @noAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Ask the band leader to add you.'**
  String get noAccessBody;

  /// No description provided for @removedTitle.
  ///
  /// In en, this message translates to:
  /// **'You are no longer in the band'**
  String get removedTitle;

  /// No description provided for @removedBody.
  ///
  /// In en, this message translates to:
  /// **'Ask the band leader if this is a mistake.'**
  String get removedBody;

  /// No description provided for @lockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lockedTitle;

  /// No description provided for @lockedBody.
  ///
  /// In en, this message translates to:
  /// **'The app is locked for now.'**
  String get lockedBody;

  /// No description provided for @lockedSafe.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe'**
  String get lockedSafe;

  /// No description provided for @lockedSafeBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been deleted. Once it is unlocked, everything is back.'**
  String get lockedSafeBody;

  /// No description provided for @lockedContact.
  ///
  /// In en, this message translates to:
  /// **'Ask your band leader for details.'**
  String get lockedContact;

  /// No description provided for @lockedContactLeader.
  ///
  /// In en, this message translates to:
  /// **'Ask whoever set up the app for the band.'**
  String get lockedContactLeader;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update needed'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'This version is too old. Download the new one to go on.'**
  String get forceUpdateBody;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @pushGigNew.
  ///
  /// In en, this message translates to:
  /// **'New gig · {date}'**
  String pushGigNew(String date);

  /// No description provided for @pushGigChanged.
  ///
  /// In en, this message translates to:
  /// **'Gig changed · {date}'**
  String pushGigChanged(String date);

  /// No description provided for @pushGigCancelled.
  ///
  /// In en, this message translates to:
  /// **'Gig cancelled · {date}'**
  String pushGigCancelled(String date);

  /// No description provided for @pushTip.
  ///
  /// In en, this message translates to:
  /// **'Tip entered · {date}'**
  String pushTip(String date);

  /// No description provided for @pushTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Playing tomorrow'**
  String get pushTomorrow;

  /// No description provided for @pushToday.
  ///
  /// In en, this message translates to:
  /// **'Playing today'**
  String get pushToday;

  /// No description provided for @pushTipReminder.
  ///
  /// In en, this message translates to:
  /// **'Enter the tip'**
  String get pushTipReminder;

  /// No description provided for @pushReport.
  ///
  /// In en, this message translates to:
  /// **'Report for {month}'**
  String pushReport(String month);

  /// No description provided for @pushMemberAdded.
  ///
  /// In en, this message translates to:
  /// **'New band member'**
  String get pushMemberAdded;

  /// No description provided for @pushMemberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Member left the band'**
  String get pushMemberRemoved;

  /// No description provided for @pushFeedback.
  ///
  /// In en, this message translates to:
  /// **'New feedback'**
  String get pushFeedback;

  /// No description provided for @notificationsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationsOffTitle;

  /// No description provided for @notificationsOffBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t hear about new gigs or get reminders.'**
  String get notificationsOffBody;

  /// No description provided for @hibernationTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the notifications coming'**
  String get hibernationTitle;

  /// No description provided for @hibernationBody.
  ///
  /// In en, this message translates to:
  /// **'Android puts apps you don\'t open for a while to sleep, and notifications stop. Turn that off for this app.'**
  String get hibernationBody;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @welcomeChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Izaberi jezik · Choose your language'**
  String get welcomeChooseLanguage;

  /// No description provided for @welcomeNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get welcomeNext;

  /// No description provided for @welcomeLookTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your look'**
  String get welcomeLookTitle;

  /// No description provided for @welcomeLookHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to see all three. You can change it any time in Settings.'**
  String get welcomeLookHint;

  /// No description provided for @welcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get welcomeStart;

  /// No description provided for @welcomeSampleVenue.
  ///
  /// In en, this message translates to:
  /// **'Hotel Grand'**
  String get welcomeSampleVenue;

  /// No description provided for @welcomeSampleCity.
  ///
  /// In en, this message translates to:
  /// **'Belgrade'**
  String get welcomeSampleCity;

  /// No description provided for @tipSplitLabel.
  ///
  /// In en, this message translates to:
  /// **'How you share the tip'**
  String get tipSplitLabel;

  /// No description provided for @tipSplitEqual.
  ///
  /// In en, this message translates to:
  /// **'Shared equally'**
  String get tipSplitEqual;

  /// No description provided for @tipSplitOwn.
  ///
  /// In en, this message translates to:
  /// **'Each their own'**
  String get tipSplitOwn;

  /// No description provided for @tipSplitEqualHint.
  ///
  /// In en, this message translates to:
  /// **'After the gig someone enters the band\'s total; it is split evenly among those who played.'**
  String get tipSplitEqualHint;

  /// No description provided for @tipSplitOwnHint.
  ///
  /// In en, this message translates to:
  /// **'After the gig everyone enters what they got; the band\'s tip is the sum.'**
  String get tipSplitOwnHint;

  /// No description provided for @tipSplitSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'For new gigs; each gig can change it.'**
  String get tipSplitSettingsHint;

  /// No description provided for @tipSplitLeaderOnly.
  ///
  /// In en, this message translates to:
  /// **'The band leader chooses this.'**
  String get tipSplitLeaderOnly;

  /// No description provided for @whoPlays.
  ///
  /// In en, this message translates to:
  /// **'Who plays'**
  String get whoPlays;

  /// No description provided for @pickPlayers.
  ///
  /// In en, this message translates to:
  /// **'Tick at least one member.'**
  String get pickPlayers;

  /// No description provided for @tipTotal.
  ///
  /// In en, this message translates to:
  /// **'Total {amount}'**
  String tipTotal(String amount);

  /// No description provided for @tipForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Tip: {name}'**
  String tipForPlayer(String name);

  /// No description provided for @tipNotEntered.
  ///
  /// In en, this message translates to:
  /// **'not entered'**
  String get tipNotEntered;

  /// No description provided for @tipsByMember.
  ///
  /// In en, this message translates to:
  /// **'Tips by member'**
  String get tipsByMember;

  /// No description provided for @tipOnly.
  ///
  /// In en, this message translates to:
  /// **'Tips only'**
  String get tipOnly;

  /// No description provided for @tipOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'No agreed price: the band plays for tips.'**
  String get tipOnlyHint;

  /// No description provided for @tipOnlyPrice.
  ///
  /// In en, this message translates to:
  /// **'For tips'**
  String get tipOnlyPrice;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
