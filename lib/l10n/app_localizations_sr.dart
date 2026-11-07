// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Bend Planer';

  @override
  String get appTagline => 'Svaka tezga, svaki evro, ceo bend.';

  @override
  String get loginSubtitle => 'Koristi nalog koji ti je napravio šef benda.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Lozinka';

  @override
  String get signIn => 'Prijavi se';

  @override
  String get signOut => 'Odjavi se';

  @override
  String get forgotPassword => 'Zaboravljena lozinka?';

  @override
  String get resetSent => 'Poslat je email za promenu lozinke.';

  @override
  String get invalidEmail => 'Unesi ispravan email';

  @override
  String get minChars6 => 'Najmanje 6 karaktera';

  @override
  String get wait => 'Sačekaj...';

  @override
  String get required => 'Obavezno';

  @override
  String get save => 'Sačuvaj';

  @override
  String get cancel => 'Otkaži';

  @override
  String get close => 'Zatvori';

  @override
  String get delete => 'Obriši';

  @override
  String get edit => 'Izmeni';

  @override
  String get send => 'Pošalji';

  @override
  String get open => 'Otvori';

  @override
  String get call => 'Pozovi';

  @override
  String get synced => 'Sinhronizovano';

  @override
  String get syncing => 'Sinhronizujem...';

  @override
  String get download => 'Preuzmi';

  @override
  String get later => 'Kasnije';

  @override
  String get newVersionTitle => 'Dostupna je nova verzija';

  @override
  String newVersionBody(String version, String current) {
    return 'Verzija $version je spremna za preuzimanje. Ti imaš $current.';
  }

  @override
  String appVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get checkUpdates => 'Proveri ažuriranja';

  @override
  String get updateCheckFailed => 'Provera ažuriranja nije uspela.';

  @override
  String get upToDate => 'Imaš najnoviju verziju.';

  @override
  String get nextMonth => 'Sledeći mesec';

  @override
  String get previousMonth => 'Prethodni mesec';

  @override
  String get changePassword => 'Promeni lozinku';

  @override
  String get currentPassword => 'Trenutna lozinka';

  @override
  String get newPassword => 'Nova lozinka';

  @override
  String get confirmPassword => 'Potvrdi novu lozinku';

  @override
  String get passwordChanged => 'Lozinka je promenjena.';

  @override
  String get passwordsNoMatch => 'Lozinke se ne poklapaju';

  @override
  String get errNoNetwork => 'Nema internet konekcije.';

  @override
  String get errInvalidEmail => 'Email nije ispravan.';

  @override
  String get errEmailInUse => 'Nalog sa ovim emailom već postoji.';

  @override
  String get errWeakPassword => 'Lozinka je preslaba (min. 6 karaktera).';

  @override
  String get errUserDisabled => 'Ovaj nalog je onemogućen.';

  @override
  String get errWrongCredentials => 'Pogrešan email ili lozinka.';

  @override
  String get errRecentLogin =>
      'Odjavi se, prijavi se ponovo i pokušaj još jednom.';

  @override
  String get errTooMany =>
      'Previše pokušaja. Pokušaj ponovo za nekoliko minuta.';

  @override
  String get errPermission => 'Nemaš dozvolu za ovu akciju.';

  @override
  String get errGeneric => 'Nešto nije u redu. Pokušaj ponovo.';

  @override
  String get tabGigs => 'Tezge';

  @override
  String get tabCalendar => 'Kalendar';

  @override
  String get tabReport => 'Izveštaj';

  @override
  String get tabBand => 'Bend';

  @override
  String get addGig => 'Tezga';

  @override
  String get notifications => 'Obaveštenja';

  @override
  String get settings => 'Podešavanja';

  @override
  String get contractedSoFar => 'ugovoreno do sada';

  @override
  String gigCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count svirki',
      few: '$count svirke',
      one: '$count svirka',
    );
    return '$_temp0';
  }

  @override
  String get awaitingTip => 'Čeka bakšiš';

  @override
  String get enterTipShort => 'Unesi';

  @override
  String get upcoming => 'Nadolazeće';

  @override
  String get past => 'Prošle';

  @override
  String get noUpcoming => 'Još nema zakazanih tezgi. Dodirni + Tezga.';

  @override
  String get noPast => 'Još nema prošlih tezgi.';

  @override
  String tonightAt(String time) {
    return 'Večeras · $time';
  }

  @override
  String todayAt(String time) {
    return 'Danas · $time';
  }

  @override
  String inDaysAt(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Za $count dana',
      one: 'Sutra',
    );
    return '$_temp0 · $time';
  }

  @override
  String get tipChip => 'Bakšiš';

  @override
  String get noTipChip => 'Bez bakšiša';

  @override
  String depositChip(String amount) {
    return 'Kapara $amount';
  }

  @override
  String tipAmountChip(String amount) {
    return 'Bakšiš $amount';
  }

  @override
  String get cancelledChip => 'Otkazana';

  @override
  String get typeWedding => 'Svadba';

  @override
  String get typeBirthday => 'Rođendan';

  @override
  String get typeKafana => 'Kafana';

  @override
  String get typeCompany => 'Proslava firme';

  @override
  String get typeConcert => 'Koncert';

  @override
  String get typeOther => 'Ostalo';

  @override
  String get newGigTitle => 'Nova tezga';

  @override
  String get editGigTitle => 'Izmeni tezgu';

  @override
  String get sectionWhen => 'Kada';

  @override
  String get sectionType => 'Vrsta';

  @override
  String get sectionWhere => 'Gde i za koga';

  @override
  String get sectionMoney => 'Pare';

  @override
  String get sectionNotes => 'Napomena';

  @override
  String get date => 'Datum';

  @override
  String get startTime => 'Početak';

  @override
  String get endTime => 'Kraj (nije obavezno)';

  @override
  String sameDayWarning(String what) {
    return 'Tog dana već imate tezgu: $what.';
  }

  @override
  String get venue => 'Lokal ili sala';

  @override
  String get city => 'Grad';

  @override
  String get address => 'Adresa (nije obavezno)';

  @override
  String get clientName => 'Naručilac (nije obavezno)';

  @override
  String get clientPhone => 'Telefon naručioca (nije obavezno)';

  @override
  String get price => 'Dogovorena cena';

  @override
  String get depositGiven => 'Kapara data';

  @override
  String get depositAmount => 'Iznos kapare';

  @override
  String get depositHolder => 'Kod koga je';

  @override
  String get tipQuestion => 'Bakšiš';

  @override
  String get hasTip => 'Ima bakšiš';

  @override
  String get noTip => 'Nema';

  @override
  String get tipHint =>
      'Posle svirke tezga čeka da neko unese bakšiš, a svima stiže podsetnik.';

  @override
  String get notesHint => 'Oprema, ozvučenje, šta se svira';

  @override
  String get saveGig => 'Sačuvaj tezgu';

  @override
  String get enterAmount => 'Unesi iznos';

  @override
  String get depositTooBig => 'Kapara je veća od cene';

  @override
  String get whenLabel => 'Kada';

  @override
  String get whereLabel => 'Gde';

  @override
  String get clientLabel => 'Naručilac';

  @override
  String get priceLabel => 'Cena';

  @override
  String get depositLabel => 'Kapara';

  @override
  String get tipLabel => 'Bakšiš';

  @override
  String get notesLabel => 'Napomena';

  @override
  String get openMap => 'Mapa';

  @override
  String addedBy(String name) {
    return 'Uneo/la: $name';
  }

  @override
  String tipBy(String name) {
    return 'Uneo/la: $name';
  }

  @override
  String get tipWaiting => 'Čeka se bakšiš';

  @override
  String get tipLater => 'Posle svirke';

  @override
  String get enterTip => 'Unesi bakšiš';

  @override
  String get changeTip => 'Izmeni bakšiš';

  @override
  String tipFor(String what) {
    return 'Bakšiš za $what';
  }

  @override
  String get tipAmount => 'Iznos bakšiša';

  @override
  String get cancelGig => 'Otkaži tezgu';

  @override
  String get cancelGigConfirm =>
      'Otkazati ovu tezgu? Ostaje u istoriji i svima stiže obaveštenje.';

  @override
  String get keepGig => 'Ne otkazuj';

  @override
  String get restoreGig => 'Vrati tezgu';

  @override
  String get deleteGig => 'Obriši tezgu';

  @override
  String get deleteGigConfirm =>
      'Trajno obrisati ovu tezgu? Samo za tezgu unetu greškom. Niko ne dobija obaveštenje.';

  @override
  String get gigGone => 'Ova tezga više ne postoji.';

  @override
  String get nothingThatDay => 'Za ovaj dan nema tezgi.';

  @override
  String get addOnThisDay => 'Dodaj tezgu za ovaj dan';

  @override
  String get totalEarned => 'Ukupno zarađeno';

  @override
  String get agreedPlusTips => 'dogovoreno + bakšiš';

  @override
  String get agreed => 'Dogovoreno';

  @override
  String get tips => 'Bakšiš';

  @override
  String get gigsLabel => 'Svirke';

  @override
  String get cancelledLabel => 'Otkazano';

  @override
  String get averageLabel => 'Prosek';

  @override
  String get biggestTip => 'Najveći bakšiš';

  @override
  String get byType => 'Po vrsti';

  @override
  String alreadyBooked(String month) {
    return '$month · već ugovoreno';
  }

  @override
  String get reportEmpty => 'Ovog meseca nema tezgi.';

  @override
  String tipsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tezgi još čeka bakšiš.',
      few: '$count tezge još čekaju bakšiš.',
      one: '$count tezga još čeka bakšiš.',
    );
    return '$_temp0';
  }

  @override
  String get dinarsApart => 'Iznosi u dinarima računaju se posebno od evra.';

  @override
  String get bandTitle => 'Bend';

  @override
  String get addMember => 'Dodaj člana';

  @override
  String get editMember => 'Izmeni člana';

  @override
  String get firstName => 'Ime';

  @override
  String get lastName => 'Prezime';

  @override
  String get instrument => 'Instrument (nije obavezno)';

  @override
  String get phone => 'Telefon (nije obavezno)';

  @override
  String get startPassword => 'Početna lozinka';

  @override
  String get startPasswordHint =>
      'Javi je članu; može da je promeni u Podešavanjima.';

  @override
  String get roleAdmin => 'Šef benda';

  @override
  String get roleMember => 'Član';

  @override
  String get roleOwner => 'Vlasnik';

  @override
  String get youSuffix => '(ti)';

  @override
  String get removeMember => 'Ukloni iz benda';

  @override
  String removeMemberConfirm(String name) {
    return 'Ukloniti $name iz benda? Više ne može da se prijavi. Tezge koje je uneo/la ostaju.';
  }

  @override
  String get removedMembers => 'Uklonjeni';

  @override
  String get restoreMember => 'Vrati u bend';

  @override
  String get makeAdmin => 'Postavi za šefa benda';

  @override
  String get makeMember => 'Vrati na običnog člana';

  @override
  String memberCreated(String name, String email) {
    return '$name sada može da se prijavi sa $email.';
  }

  @override
  String get noMembers => 'Još nikog nema. Dodaj prvog člana.';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Izmeni profil';

  @override
  String get look => 'Izgled';

  @override
  String get skinBina => 'Bina';

  @override
  String get skinNeon => 'Neon';

  @override
  String get skinZlato => 'Zlato';

  @override
  String get skinBinaHint => 'Reflektori sa bine';

  @override
  String get skinNeonHint => 'Noćni klub';

  @override
  String get skinZlatoHint => 'Crno i zlatno';

  @override
  String get language => 'Jezik';

  @override
  String get languagePhone => 'Jezik telefona';

  @override
  String get notificationsHint => 'Izaberi koja dobijaš';

  @override
  String get sendFeedback => 'Pošalji predlog';

  @override
  String get feedbackHint =>
      'Predlozi i problemi idu pravo onome ko pravi aplikaciju.';

  @override
  String get feedbackField => 'Šta bi promenio/la?';

  @override
  String get feedbackSent => 'Poslato. Hvala!';

  @override
  String get shareApp => 'Podeli aplikaciju';

  @override
  String get shareAppHint =>
      'Skeniraj kod kamerom drugog telefona ili pošalji link. Android će tražiti dozvolu za instalaciju iz tog izvora.';

  @override
  String get shareAppMessage => 'Bend Planer: sve tezge benda na jednom mestu.';

  @override
  String get copyLink => 'Kopiraj link';

  @override
  String get linkCopied => 'Link je kopiran.';

  @override
  String get sendLink => 'Pošalji';

  @override
  String get ownerSection => 'Vlasnik';

  @override
  String get appLocked =>
      'Zaključano: niko iz benda ne može da koristi aplikaciju.';

  @override
  String get appUnlocked => 'Otključano: bend koristi aplikaciju.';

  @override
  String get lockApp => 'Zaključaj aplikaciju';

  @override
  String get unlockApp => 'Otključaj aplikaciju';

  @override
  String get lockConfirm =>
      'Zaključati aplikaciju za ceo bend? Ništa se ne briše, a otključavanje vraća sve kako je bilo.';

  @override
  String get requiredVersion => 'Obavezna verzija';

  @override
  String get anyVersion => 'Može svaka verzija.';

  @override
  String versionRequired(int build) {
    return 'Obavezno izdanje $build ili novije.';
  }

  @override
  String requireLatest(String version) {
    return 'Traži verziju $version';
  }

  @override
  String get allowAnyVersion => 'Dozvoli svaku verziju';

  @override
  String get feedbackList => 'Predlozi';

  @override
  String get noFeedback => 'Još nema predloga.';

  @override
  String get claimOwnerTitle => 'Podešavanje aplikacije';

  @override
  String get claimOwnerBody =>
      'Ovo je prvi nalog. Postaje vlasnik: može da zaključa aplikaciju i dodaje šefa benda.';

  @override
  String get claimOwnerButton => 'Postani vlasnik';

  @override
  String get noAccessTitle => 'Nemaš pristup';

  @override
  String get noAccessBody => 'Zamoli šefa benda da te doda.';

  @override
  String get removedTitle => 'Više nisi u bendu';

  @override
  String get removedBody => 'Pitaj šefa benda ako je ovo greška.';

  @override
  String get lockedTitle => 'Zaključano';

  @override
  String get lockedBody => 'Aplikacija je privremeno zaključana.';

  @override
  String get lockedSafe => 'Podaci su sačuvani';

  @override
  String get lockedSafeBody =>
      'Ništa nije obrisano. Čim se otključa, sve je tu kao pre.';

  @override
  String get lockedContact => 'Za više informacija javite se šefu benda.';

  @override
  String get lockedContactLeader =>
      'Javite se onome ko je bendu postavio aplikaciju.';

  @override
  String get forceUpdateTitle => 'Potrebno ažuriranje';

  @override
  String get forceUpdateBody =>
      'Ova verzija je zastarela. Preuzmi novu da nastaviš.';

  @override
  String get tryAgain => 'Pokušaj ponovo';

  @override
  String pushGigNew(String date) {
    return 'Nova tezga · $date';
  }

  @override
  String pushGigChanged(String date) {
    return 'Izmenjena tezga · $date';
  }

  @override
  String pushGigCancelled(String date) {
    return 'Otkazana tezga · $date';
  }

  @override
  String pushTip(String date) {
    return 'Bakšiš unet · $date';
  }

  @override
  String get pushTomorrow => 'Sutra svirate';

  @override
  String get pushToday => 'Danas svirate';

  @override
  String get pushTipReminder => 'Unesite bakšiš';

  @override
  String pushReport(String month) {
    return 'Izveštaj za $month';
  }

  @override
  String get pushMemberAdded => 'Novi član benda';

  @override
  String get pushMemberRemoved => 'Član je napustio bend';

  @override
  String get pushFeedback => 'Novi predlog';

  @override
  String get notificationsOffTitle => 'Obaveštenja su isključena';

  @override
  String get notificationsOffBody =>
      'Nećeš saznati za nove tezge niti dobijati podsetnike.';

  @override
  String get hibernationTitle => 'Neka obaveštenja stižu';

  @override
  String get hibernationBody =>
      'Android uspava aplikacije koje dugo ne otvaraš i tada obaveštenja ne stižu. Isključi to za ovu aplikaciju.';

  @override
  String get turnOn => 'Uključi';

  @override
  String get openSettings => 'Otvori podešavanja';

  @override
  String get notNow => 'Ne sada';

  @override
  String get welcomeChooseLanguage => 'Izaberi jezik · Choose your language';

  @override
  String get welcomeNext => 'Dalje';

  @override
  String get welcomeLookTitle => 'Izaberi izgled';

  @override
  String get welcomeLookHint =>
      'Prevuci da vidiš sva tri. Uvek ga možeš promeniti u Podešavanjima.';

  @override
  String get welcomeStart => 'Kreni';

  @override
  String get welcomeSampleVenue => 'Hotel Grand';

  @override
  String get welcomeSampleCity => 'Beograd';
}
