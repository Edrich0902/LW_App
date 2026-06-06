import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_af.dart';
import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('af'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In af, this message translates to:
  /// **'Lewende Woord Paarl'**
  String get appTitle;

  /// No description provided for @commonLoad.
  ///
  /// In af, this message translates to:
  /// **'Laai'**
  String get commonLoad;

  /// No description provided for @commonRetry.
  ///
  /// In af, this message translates to:
  /// **'Probeer Weer'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In af, this message translates to:
  /// **'Kanselleer'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In af, this message translates to:
  /// **'Bevestig'**
  String get commonConfirm;

  /// No description provided for @commonNext.
  ///
  /// In af, this message translates to:
  /// **'Volgende'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In af, this message translates to:
  /// **'Terug'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In af, this message translates to:
  /// **'Maak toe'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In af, this message translates to:
  /// **'Stoor'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In af, this message translates to:
  /// **'Verwyder'**
  String get commonDelete;

  /// No description provided for @commonContinue.
  ///
  /// In af, this message translates to:
  /// **'Gaan voort'**
  String get commonContinue;

  /// No description provided for @commonShare.
  ///
  /// In af, this message translates to:
  /// **'Deel'**
  String get commonShare;

  /// No description provided for @genericErrorTitle.
  ///
  /// In af, this message translates to:
  /// **'Oeps! Iets het fout gegaan.'**
  String get genericErrorTitle;

  /// No description provided for @genericEmptyState.
  ///
  /// In af, this message translates to:
  /// **'Geen inhoud om te wys nie'**
  String get genericEmptyState;

  /// No description provided for @navHome.
  ///
  /// In af, this message translates to:
  /// **'Tuis'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In af, this message translates to:
  /// **'Kalender'**
  String get navCalendar;

  /// No description provided for @navBible.
  ///
  /// In af, this message translates to:
  /// **'Bybel'**
  String get navBible;

  /// No description provided for @navMoreInfo.
  ///
  /// In af, this message translates to:
  /// **'Meer Oor Ons'**
  String get navMoreInfo;

  /// No description provided for @navConnect.
  ///
  /// In af, this message translates to:
  /// **'Skakel In'**
  String get navConnect;

  /// No description provided for @moreInfoMission.
  ///
  /// In af, this message translates to:
  /// **'Ons Misie'**
  String get moreInfoMission;

  /// No description provided for @moreInfoVision.
  ///
  /// In af, this message translates to:
  /// **'Ons Visie'**
  String get moreInfoVision;

  /// No description provided for @moreInfoTeam.
  ///
  /// In af, this message translates to:
  /// **'Ons Span'**
  String get moreInfoTeam;

  /// No description provided for @splashWelcome.
  ///
  /// In af, this message translates to:
  /// **'Welkom'**
  String get splashWelcome;

  /// No description provided for @settingsTitle.
  ///
  /// In af, this message translates to:
  /// **'Instellings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In af, this message translates to:
  /// **'Voorkoms'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In af, this message translates to:
  /// **'Taal'**
  String get settingsLanguageSection;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In af, this message translates to:
  /// **'Stelsel'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In af, this message translates to:
  /// **'Lig'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In af, this message translates to:
  /// **'Donker'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageAfrikaans.
  ///
  /// In af, this message translates to:
  /// **'Afrikaans'**
  String get settingsLanguageAfrikaans;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In af, this message translates to:
  /// **'Engels'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In af, this message translates to:
  /// **'Kies jou voorkeurtaal vir die toepassing.'**
  String get settingsLanguageDescription;

  /// No description provided for @authWelcomeBack.
  ///
  /// In af, this message translates to:
  /// **'Welkom Terug'**
  String get authWelcomeBack;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Teken in om voort te gaan'**
  String get authSignInSubtitle;

  /// No description provided for @authSignIn.
  ///
  /// In af, this message translates to:
  /// **'Teken In'**
  String get authSignIn;

  /// No description provided for @authEmail.
  ///
  /// In af, this message translates to:
  /// **'E-pos'**
  String get authEmail;

  /// No description provided for @authEmailAddress.
  ///
  /// In af, this message translates to:
  /// **'E-pos adres'**
  String get authEmailAddress;

  /// No description provided for @authPassword.
  ///
  /// In af, this message translates to:
  /// **'Wagwoord'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In af, this message translates to:
  /// **'Wagwoord vergeet?'**
  String get authForgotPassword;

  /// No description provided for @authNoAccountRegister.
  ///
  /// In af, this message translates to:
  /// **'Het jy nie \'n rekening nie? Registreer hier'**
  String get authNoAccountRegister;

  /// No description provided for @authOpenResetPageFailed.
  ///
  /// In af, this message translates to:
  /// **'Kon nie die herstelbladsy oopmaak nie.'**
  String get authOpenResetPageFailed;

  /// No description provided for @authSignInFailed.
  ///
  /// In af, this message translates to:
  /// **'Intekening het misluk. Kontroleer asseblief jou besonderhede.'**
  String get authSignInFailed;

  /// No description provided for @authSignInSuccess.
  ///
  /// In af, this message translates to:
  /// **'Intekening suksesvol'**
  String get authSignInSuccess;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In af, this message translates to:
  /// **'Wagwoord Vergeet'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Stel jou wagwoord terug'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordDescription.
  ///
  /// In af, this message translates to:
  /// **'Voer jou geregistreerde e-posadres in en ons sal vir jou \'n skakel stuur om jou wagwoord terug te stel.'**
  String get authForgotPasswordDescription;

  /// No description provided for @authBackToSignInTooltip.
  ///
  /// In af, this message translates to:
  /// **'Terug na Intekening'**
  String get authBackToSignInTooltip;

  /// No description provided for @authSendResetLink.
  ///
  /// In af, this message translates to:
  /// **'Stuur Terugstel Skakel'**
  String get authSendResetLink;

  /// No description provided for @authSendResetLinkFailed.
  ///
  /// In af, this message translates to:
  /// **'Kon nie terugstelskakel stuur nie. Kontroleer asseblief jou e-pos.'**
  String get authSendResetLinkFailed;

  /// No description provided for @authSendResetLinkSuccess.
  ///
  /// In af, this message translates to:
  /// **'Terugstelskakel is na jou e-pos gestuur.'**
  String get authSendResetLinkSuccess;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In af, this message translates to:
  /// **'Nuwe Wagwoord'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Stel jou nuwe wagwoord in'**
  String get authResetPasswordSubtitle;

  /// No description provided for @authConfirmPassword.
  ///
  /// In af, this message translates to:
  /// **'Bevestig Wagwoord'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In af, this message translates to:
  /// **'Bevestig Nuwe Wagwoord'**
  String get authConfirmNewPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In af, this message translates to:
  /// **'Stel Wagwoord Terug'**
  String get authResetPassword;

  /// No description provided for @authResetPasswordFailed.
  ///
  /// In af, this message translates to:
  /// **'Kon nie jou wagwoord terugstel nie. Probeer asseblief weer.'**
  String get authResetPasswordFailed;

  /// No description provided for @authResetPasswordSuccess.
  ///
  /// In af, this message translates to:
  /// **'Jou wagwoord is suksesvol verander!'**
  String get authResetPasswordSuccess;

  /// No description provided for @authCreateAccount.
  ///
  /// In af, this message translates to:
  /// **'Skep Rekening'**
  String get authCreateAccount;

  /// No description provided for @authRegistrationSuccess.
  ///
  /// In af, this message translates to:
  /// **'Registrasie suksesvol'**
  String get authRegistrationSuccess;

  /// No description provided for @authRegistrationFailed.
  ///
  /// In af, this message translates to:
  /// **'Registrasie het misluk. Probeer asseblief weer.'**
  String get authRegistrationFailed;

  /// No description provided for @authRegister.
  ///
  /// In af, this message translates to:
  /// **'Registreer'**
  String get authRegister;

  /// No description provided for @authExistingAccountSignIn.
  ///
  /// In af, this message translates to:
  /// **'Het jy reeds \'n rekening? Teken hier in'**
  String get authExistingAccountSignIn;

  /// No description provided for @authProfilePhotoRequired.
  ///
  /// In af, this message translates to:
  /// **'Kies asseblief \'n profiel foto'**
  String get authProfilePhotoRequired;

  /// No description provided for @authStepOneTitle.
  ///
  /// In af, this message translates to:
  /// **'Skep Rekening'**
  String get authStepOneTitle;

  /// No description provided for @authStepTwoTitle.
  ///
  /// In af, this message translates to:
  /// **'Jou Besonderhede'**
  String get authStepTwoTitle;

  /// No description provided for @authStepThreeTitle.
  ///
  /// In af, this message translates to:
  /// **'Profiel Foto'**
  String get authStepThreeTitle;

  /// No description provided for @authStepOneSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Stap 1 van 3: Toegang'**
  String get authStepOneSubtitle;

  /// No description provided for @authStepTwoSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Stap 2 van 3: Persoonlik'**
  String get authStepTwoSubtitle;

  /// No description provided for @authStepThreeSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Stap 3 van 3: Identiteit'**
  String get authStepThreeSubtitle;

  /// No description provided for @authPreviousStepTooltip.
  ///
  /// In af, this message translates to:
  /// **'Vorige Stap'**
  String get authPreviousStepTooltip;

  /// No description provided for @authFirstName.
  ///
  /// In af, this message translates to:
  /// **'Voornaam'**
  String get authFirstName;

  /// No description provided for @authLastName.
  ///
  /// In af, this message translates to:
  /// **'Van'**
  String get authLastName;

  /// No description provided for @authChooseProfilePhotoDescription.
  ///
  /// In af, this message translates to:
  /// **'Kies \'n foto sodat ons jou kan herken'**
  String get authChooseProfilePhotoDescription;

  /// No description provided for @authGallery.
  ///
  /// In af, this message translates to:
  /// **'Galery'**
  String get authGallery;

  /// No description provided for @authCamera.
  ///
  /// In af, this message translates to:
  /// **'Kamera'**
  String get authCamera;

  /// No description provided for @authConfirmEmailTitle.
  ///
  /// In af, this message translates to:
  /// **'Bevestig jou E-pos'**
  String get authConfirmEmailTitle;

  /// No description provided for @authConfirmEmailSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Ons het vir jou \'n e-pos gestuur'**
  String get authConfirmEmailSubtitle;

  /// No description provided for @authConfirmEmailDescription.
  ///
  /// In af, this message translates to:
  /// **'Dankie vir jou registrasie! Ons het \'n bevestigings-e-pos gestuur na:'**
  String get authConfirmEmailDescription;

  /// No description provided for @authConfirmEmailInstructions.
  ///
  /// In af, this message translates to:
  /// **'Kliek asseblief op die skakel in die e-pos om jou rekening te aktiveer. Daarna kan jy inteken.'**
  String get authConfirmEmailInstructions;

  /// No description provided for @authGoToSignIn.
  ///
  /// In af, this message translates to:
  /// **'Gaan na Intekenskerm'**
  String get authGoToSignIn;

  /// No description provided for @validationEmailRequired.
  ///
  /// In af, this message translates to:
  /// **'E-pos is verpligtend'**
  String get validationEmailRequired;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In af, this message translates to:
  /// **'Wagwoord is verpligtend'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In af, this message translates to:
  /// **'Wagwoord moet ten minste 6 karakters wees'**
  String get validationPasswordMinLength;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In af, this message translates to:
  /// **'Bevestig asseblief jou wagwoord'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordsMismatch.
  ///
  /// In af, this message translates to:
  /// **'Wagwoorde stem nie ooreen nie'**
  String get validationPasswordsMismatch;

  /// No description provided for @validationFirstNameRequired.
  ///
  /// In af, this message translates to:
  /// **'Voornaam is verpligtend'**
  String get validationFirstNameRequired;

  /// No description provided for @validationLastNameRequired.
  ///
  /// In af, this message translates to:
  /// **'Van is verpligtend'**
  String get validationLastNameRequired;

  /// No description provided for @profileTitle.
  ///
  /// In af, this message translates to:
  /// **'Profiel'**
  String get profileTitle;

  /// No description provided for @profileLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai profiel...'**
  String get profileLoading;

  /// No description provided for @profileLoadError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie profiel laai nie.'**
  String get profileLoadError;

  /// No description provided for @profileDefaultName.
  ///
  /// In af, this message translates to:
  /// **'Gebruiker'**
  String get profileDefaultName;

  /// No description provided for @profileMyProfile.
  ///
  /// In af, this message translates to:
  /// **'My Profiel'**
  String get profileMyProfile;

  /// No description provided for @profileMyNotes.
  ///
  /// In af, this message translates to:
  /// **'My Notas'**
  String get profileMyNotes;

  /// No description provided for @profileMyPrayerRequests.
  ///
  /// In af, this message translates to:
  /// **'My Gebedsversoeke'**
  String get profileMyPrayerRequests;

  /// No description provided for @profileMyGroups.
  ///
  /// In af, this message translates to:
  /// **'My Groepe'**
  String get profileMyGroups;

  /// No description provided for @profileFeedbackReports.
  ///
  /// In af, this message translates to:
  /// **'Terugvoer & Verslae'**
  String get profileFeedbackReports;

  /// No description provided for @profileSettings.
  ///
  /// In af, this message translates to:
  /// **'Instellings'**
  String get profileSettings;

  /// No description provided for @profileSignOut.
  ///
  /// In af, this message translates to:
  /// **'Teken Uit'**
  String get profileSignOut;

  /// No description provided for @profileSignOutConfirmTitle.
  ///
  /// In af, this message translates to:
  /// **'Teken Uit'**
  String get profileSignOutConfirmTitle;

  /// No description provided for @profileSignOutConfirmBody.
  ///
  /// In af, this message translates to:
  /// **'Is u seker u wil uitteken?'**
  String get profileSignOutConfirmBody;

  /// No description provided for @profileSignOutFailed.
  ///
  /// In af, this message translates to:
  /// **'Fout, kon nie uitteken nie'**
  String get profileSignOutFailed;

  /// No description provided for @connectHeroTag.
  ///
  /// In af, this message translates to:
  /// **'SKAKEL IN'**
  String get connectHeroTag;

  /// No description provided for @connectHeroTitle.
  ///
  /// In af, this message translates to:
  /// **'Word deel van ons familie'**
  String get connectHeroTitle;

  /// No description provided for @connectGroupsTitle.
  ///
  /// In af, this message translates to:
  /// **'Konneksie Groepe'**
  String get connectGroupsTitle;

  /// No description provided for @serveGroupsTitle.
  ///
  /// In af, this message translates to:
  /// **'Kom Dien'**
  String get serveGroupsTitle;

  /// No description provided for @connectGroupsLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Konneksie Groepe'**
  String get connectGroupsLoading;

  /// No description provided for @connectGroupsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Konneksie Groepe'**
  String get connectGroupsEmpty;

  /// No description provided for @serveGroupsLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Kom Dien Groepe'**
  String get serveGroupsLoading;

  /// No description provided for @serveGroupsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Kom Dien Groepe'**
  String get serveGroupsEmpty;

  /// No description provided for @groupDescriptionTitle.
  ///
  /// In af, this message translates to:
  /// **'Beskrywing'**
  String get groupDescriptionTitle;

  /// No description provided for @groupOpenMaps.
  ///
  /// In af, this message translates to:
  /// **'Maak Oop In Maps'**
  String get groupOpenMaps;

  /// No description provided for @groupJoinWhatsapp.
  ///
  /// In af, this message translates to:
  /// **'Sluit aan op WhatsApp'**
  String get groupJoinWhatsapp;

  /// No description provided for @groupOpenWhatsappFailed.
  ///
  /// In af, this message translates to:
  /// **'Kon nie WhatsApp oopmaak nie. Maak seker die app is geïnstalleer.'**
  String get groupOpenWhatsappFailed;

  /// No description provided for @groupOpenWhatsappError.
  ///
  /// In af, this message translates to:
  /// **'Fout met die oopmaak van WhatsApp.'**
  String get groupOpenWhatsappError;

  /// No description provided for @groupLeadersCount.
  ///
  /// In af, this message translates to:
  /// **'{count} leiers'**
  String groupLeadersCount(Object count);

  /// No description provided for @groupMembersCount.
  ///
  /// In af, this message translates to:
  /// **'{count} lede'**
  String groupMembersCount(Object count);

  /// No description provided for @groupPendingCount.
  ///
  /// In af, this message translates to:
  /// **'{count} hangend'**
  String groupPendingCount(Object count);

  /// No description provided for @groupLeaderBadge.
  ///
  /// In af, this message translates to:
  /// **'Leier'**
  String get groupLeaderBadge;

  /// No description provided for @groupMembershipPending.
  ///
  /// In af, this message translates to:
  /// **'Versoek Hangend'**
  String get groupMembershipPending;

  /// No description provided for @groupMembershipActive.
  ///
  /// In af, this message translates to:
  /// **'Lid'**
  String get groupMembershipActive;

  /// No description provided for @groupMembershipDeclined.
  ///
  /// In af, this message translates to:
  /// **'Afgekeur'**
  String get groupMembershipDeclined;

  /// No description provided for @groupMembershipLeft.
  ///
  /// In af, this message translates to:
  /// **'Verlaat'**
  String get groupMembershipLeft;

  /// No description provided for @groupActionRequestSent.
  ///
  /// In af, this message translates to:
  /// **'Versoek gestuur.'**
  String get groupActionRequestSent;

  /// No description provided for @groupActionRequestCancelled.
  ///
  /// In af, this message translates to:
  /// **'Versoek gekanselleer.'**
  String get groupActionRequestCancelled;

  /// No description provided for @groupActionLeft.
  ///
  /// In af, this message translates to:
  /// **'Jy het die groep verlaat.'**
  String get groupActionLeft;

  /// No description provided for @groupActionApproved.
  ///
  /// In af, this message translates to:
  /// **'Versoek goedgekeur.'**
  String get groupActionApproved;

  /// No description provided for @groupActionDeclined.
  ///
  /// In af, this message translates to:
  /// **'Versoek afgekeur.'**
  String get groupActionDeclined;

  /// No description provided for @groupActionMemberRemoved.
  ///
  /// In af, this message translates to:
  /// **'Lid verwyder.'**
  String get groupActionMemberRemoved;

  /// No description provided for @groupActionUpdated.
  ///
  /// In af, this message translates to:
  /// **'Groep opgedateer.'**
  String get groupActionUpdated;

  /// No description provided for @groupActionPostShared.
  ///
  /// In af, this message translates to:
  /// **'Plasing gedeel.'**
  String get groupActionPostShared;

  /// No description provided for @groupActionPostUpdated.
  ///
  /// In af, this message translates to:
  /// **'Plasing opgedateer.'**
  String get groupActionPostUpdated;

  /// No description provided for @groupActionPostDeleted.
  ///
  /// In af, this message translates to:
  /// **'Plasing verwyder.'**
  String get groupActionPostDeleted;

  /// No description provided for @groupActionPostUnpinned.
  ///
  /// In af, this message translates to:
  /// **'Plasing onthef.'**
  String get groupActionPostUnpinned;

  /// No description provided for @groupActionPostPinned.
  ///
  /// In af, this message translates to:
  /// **'Plasing vasgespeld.'**
  String get groupActionPostPinned;

  /// No description provided for @groupFeedTitle.
  ///
  /// In af, this message translates to:
  /// **'Groepfeed'**
  String get groupFeedTitle;

  /// No description provided for @groupFeedLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai groepfeed...'**
  String get groupFeedLoading;

  /// No description provided for @groupFeedGroupNotFound.
  ///
  /// In af, this message translates to:
  /// **'Geen groep gevind nie'**
  String get groupFeedGroupNotFound;

  /// No description provided for @groupFeedDeletePostTitle.
  ///
  /// In af, this message translates to:
  /// **'Verwyder plasing'**
  String get groupFeedDeletePostTitle;

  /// No description provided for @groupFeedDeletePostBody.
  ///
  /// In af, this message translates to:
  /// **'Is jy seker jy wil {title} verwyder?'**
  String groupFeedDeletePostBody(Object title);

  /// No description provided for @groupFeedPostCount.
  ///
  /// In af, this message translates to:
  /// **'{count} plasings'**
  String groupFeedPostCount(Object count);

  /// No description provided for @groupFeedPinned.
  ///
  /// In af, this message translates to:
  /// **'Vasgespeld'**
  String get groupFeedPinned;

  /// No description provided for @groupFeedUnpin.
  ///
  /// In af, this message translates to:
  /// **'Onthef'**
  String get groupFeedUnpin;

  /// No description provided for @groupFeedPin.
  ///
  /// In af, this message translates to:
  /// **'Speld'**
  String get groupFeedPin;

  /// No description provided for @groupFeedThisPost.
  ///
  /// In af, this message translates to:
  /// **'hierdie plasing'**
  String get groupFeedThisPost;

  /// No description provided for @groupDetailTitle.
  ///
  /// In af, this message translates to:
  /// **'Groep'**
  String get groupDetailTitle;

  /// No description provided for @groupDetailOpenFeedTooltip.
  ///
  /// In af, this message translates to:
  /// **'Open groepfeed'**
  String get groupDetailOpenFeedTooltip;

  /// No description provided for @groupDetailEditTooltip.
  ///
  /// In af, this message translates to:
  /// **'Wysig groep'**
  String get groupDetailEditTooltip;

  /// No description provided for @groupDetailLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai groep...'**
  String get groupDetailLoading;

  /// No description provided for @groupDetailPendingRequestsTitle.
  ///
  /// In af, this message translates to:
  /// **'Hangende Versoeke'**
  String get groupDetailPendingRequestsTitle;

  /// No description provided for @groupDetailPendingRequestsSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Keur nuwe aansluitings goed of af.'**
  String get groupDetailPendingRequestsSubtitle;

  /// No description provided for @groupDetailPendingRequestsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen hangende versoeke nie'**
  String get groupDetailPendingRequestsEmpty;

  /// No description provided for @groupDetailDecline.
  ///
  /// In af, this message translates to:
  /// **'Keur Af'**
  String get groupDetailDecline;

  /// No description provided for @groupDetailApprove.
  ///
  /// In af, this message translates to:
  /// **'Keur Goed'**
  String get groupDetailApprove;

  /// No description provided for @groupDetailActiveMembersTitle.
  ///
  /// In af, this message translates to:
  /// **'Aktiewe Lede'**
  String get groupDetailActiveMembersTitle;

  /// No description provided for @groupDetailActiveMembersSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Verwyder lede indien nodig.'**
  String get groupDetailActiveMembersSubtitle;

  /// No description provided for @groupDetailActiveMembersEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen aktiewe lede nie'**
  String get groupDetailActiveMembersEmpty;

  /// No description provided for @groupDetailLeaveTitle.
  ///
  /// In af, this message translates to:
  /// **'Verlaat groep'**
  String get groupDetailLeaveTitle;

  /// No description provided for @groupDetailLeaveBody.
  ///
  /// In af, this message translates to:
  /// **'Is jy seker jy wil hierdie groep verlaat?'**
  String get groupDetailLeaveBody;

  /// No description provided for @groupDetailLeaveButton.
  ///
  /// In af, this message translates to:
  /// **'Verlaat'**
  String get groupDetailLeaveButton;

  /// No description provided for @groupDetailRemoveMemberTitle.
  ///
  /// In af, this message translates to:
  /// **'Verwyder lid'**
  String get groupDetailRemoveMemberTitle;

  /// No description provided for @groupDetailRemoveMemberBody.
  ///
  /// In af, this message translates to:
  /// **'Is jy seker jy wil {name} uit hierdie groep verwyder?'**
  String groupDetailRemoveMemberBody(Object name);

  /// No description provided for @groupDetailWhatsappUnavailable.
  ///
  /// In af, this message translates to:
  /// **'WhatsApp-skakel is nog nie beskikbaar vir hierdie groep nie.'**
  String get groupDetailWhatsappUnavailable;

  /// No description provided for @groupDetailLeadersLabel.
  ///
  /// In af, this message translates to:
  /// **'Leiers'**
  String get groupDetailLeadersLabel;

  /// No description provided for @groupDetailMembersLabel.
  ///
  /// In af, this message translates to:
  /// **'Lede'**
  String get groupDetailMembersLabel;

  /// No description provided for @groupDetailPendingLabel.
  ///
  /// In af, this message translates to:
  /// **'Hangend'**
  String get groupDetailPendingLabel;

  /// No description provided for @groupDetailActionsTitle.
  ///
  /// In af, this message translates to:
  /// **'Aksies'**
  String get groupDetailActionsTitle;

  /// No description provided for @groupDetailOpenWhatsappGroup.
  ///
  /// In af, this message translates to:
  /// **'Open WhatsApp Groep'**
  String get groupDetailOpenWhatsappGroup;

  /// No description provided for @groupDetailCancelRequest.
  ///
  /// In af, this message translates to:
  /// **'Kanselleer Versoek'**
  String get groupDetailCancelRequest;

  /// No description provided for @groupDetailLeaveGroup.
  ///
  /// In af, this message translates to:
  /// **'Verlaat Groep'**
  String get groupDetailLeaveGroup;

  /// No description provided for @groupDetailRequestJoin.
  ///
  /// In af, this message translates to:
  /// **'Versoek Om Aan Te Sluit'**
  String get groupDetailRequestJoin;

  /// No description provided for @groupDetailLeaderDescription.
  ///
  /// In af, this message translates to:
  /// **'Jy bestuur hierdie groep as leier. Lede en versoeke verskyn hieronder.'**
  String get groupDetailLeaderDescription;

  /// No description provided for @groupDetailPendingDescription.
  ///
  /// In af, this message translates to:
  /// **'Jou versoek is gestuur en wag vir goedkeuring.'**
  String get groupDetailPendingDescription;

  /// No description provided for @groupDetailMemberDescription.
  ///
  /// In af, this message translates to:
  /// **'Jy is reeds deel van hierdie groep.'**
  String get groupDetailMemberDescription;

  /// No description provided for @groupDetailJoinDescription.
  ///
  /// In af, this message translates to:
  /// **'Sluit by hierdie groep aan om toegang tot die WhatsApp-skakel en groepdeelname te kry.'**
  String get groupDetailJoinDescription;

  /// No description provided for @groupDetailLeaderCanPost.
  ///
  /// In af, this message translates to:
  /// **'Leier kan plaas'**
  String get groupDetailLeaderCanPost;

  /// No description provided for @groupDetailFeedDescription.
  ///
  /// In af, this message translates to:
  /// **'Maak die feed volskerm oop vir opdaterings, reaksies en beter interaksie.'**
  String get groupDetailFeedDescription;

  /// No description provided for @groupDetailOpenFeed.
  ///
  /// In af, this message translates to:
  /// **'Open Feed'**
  String get groupDetailOpenFeed;

  /// No description provided for @groupDetailRequestDate.
  ///
  /// In af, this message translates to:
  /// **'Versoek {date}'**
  String groupDetailRequestDate(Object date);

  /// No description provided for @groupDetailEditTitle.
  ///
  /// In af, this message translates to:
  /// **'Wysig Groep'**
  String get groupDetailEditTitle;

  /// No description provided for @groupDetailEditSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Werk net die lidgerigte groepinligting op.'**
  String get groupDetailEditSubtitle;

  /// No description provided for @groupDetailChooseNewBanner.
  ///
  /// In af, this message translates to:
  /// **'Kies Nuwe Banier'**
  String get groupDetailChooseNewBanner;

  /// No description provided for @groupDetailDescriptionRequired.
  ///
  /// In af, this message translates to:
  /// **'Beskrywing word benodig'**
  String get groupDetailDescriptionRequired;

  /// No description provided for @groupDetailWhatsappLink.
  ///
  /// In af, this message translates to:
  /// **'WhatsApp Skakel'**
  String get groupDetailWhatsappLink;

  /// No description provided for @groupDetailLocation.
  ///
  /// In af, this message translates to:
  /// **'Ligging'**
  String get groupDetailLocation;

  /// No description provided for @groupDetailSaveChanges.
  ///
  /// In af, this message translates to:
  /// **'Stoor Veranderinge'**
  String get groupDetailSaveChanges;

  /// No description provided for @groupDetailBannerUploadError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie banier oplaai nie.'**
  String get groupDetailBannerUploadError;

  /// No description provided for @groupDetailPublic.
  ///
  /// In af, this message translates to:
  /// **'Publiek'**
  String get groupDetailPublic;

  /// No description provided for @myGroupsTitle.
  ///
  /// In af, this message translates to:
  /// **'My Groepe'**
  String get myGroupsTitle;

  /// No description provided for @myGroupsLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai my groepe...'**
  String get myGroupsLoading;

  /// No description provided for @myGroupsLoadError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie my groepe laai nie.'**
  String get myGroupsLoadError;

  /// No description provided for @myGroupsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Jy het nog geen groepe nie'**
  String get myGroupsEmpty;

  /// No description provided for @myGroupsActiveSectionTitle.
  ///
  /// In af, this message translates to:
  /// **'Aktiewe Groepe'**
  String get myGroupsActiveSectionTitle;

  /// No description provided for @myGroupsActiveSectionSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Groepe waarvan jy tans deel is.'**
  String get myGroupsActiveSectionSubtitle;

  /// No description provided for @myGroupsPendingSectionTitle.
  ///
  /// In af, this message translates to:
  /// **'Hangende Versoeke'**
  String get myGroupsPendingSectionTitle;

  /// No description provided for @myGroupsPendingSectionSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Aansluitings wat nog op goedkeuring wag.'**
  String get myGroupsPendingSectionSubtitle;

  /// No description provided for @notesTitle.
  ///
  /// In af, this message translates to:
  /// **'Notas'**
  String get notesTitle;

  /// No description provided for @notesSearchHint.
  ///
  /// In af, this message translates to:
  /// **'Soek notas...'**
  String get notesSearchHint;

  /// No description provided for @notesEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen notas gevind nie'**
  String get notesEmpty;

  /// No description provided for @notesDeleteSuccess.
  ///
  /// In af, this message translates to:
  /// **'Nota verwyder'**
  String get notesDeleteSuccess;

  /// No description provided for @notesDeleteTitle.
  ///
  /// In af, this message translates to:
  /// **'Verwyder Nota'**
  String get notesDeleteTitle;

  /// No description provided for @notesDeleteBody.
  ///
  /// In af, this message translates to:
  /// **'Is jy seker jy wil hierdie nota verwyder?'**
  String get notesDeleteBody;

  /// No description provided for @notesCreateTitle.
  ///
  /// In af, this message translates to:
  /// **'Skep Nota'**
  String get notesCreateTitle;

  /// No description provided for @notesEditTitle.
  ///
  /// In af, this message translates to:
  /// **'Wysig Nota'**
  String get notesEditTitle;

  /// No description provided for @notesTitleHint.
  ///
  /// In af, this message translates to:
  /// **'Titel'**
  String get notesTitleHint;

  /// No description provided for @notesBodyPlaceholder.
  ///
  /// In af, this message translates to:
  /// **'Skryf jou nota hier...'**
  String get notesBodyPlaceholder;

  /// No description provided for @notesGenericError.
  ///
  /// In af, this message translates to:
  /// **'Iets het fout gegaan'**
  String get notesGenericError;

  /// No description provided for @profileEditTitle.
  ///
  /// In af, this message translates to:
  /// **'Wysig Profiel'**
  String get profileEditTitle;

  /// No description provided for @profileEditSuccess.
  ///
  /// In af, this message translates to:
  /// **'Profiel opgedateer'**
  String get profileEditSuccess;

  /// No description provided for @profileEditPhotoSuccess.
  ///
  /// In af, this message translates to:
  /// **'Profielfoto opgedateer'**
  String get profileEditPhotoSuccess;

  /// No description provided for @profileEditNameRequired.
  ///
  /// In af, this message translates to:
  /// **'Naam word benodig'**
  String get profileEditNameRequired;

  /// No description provided for @profileEditLastNameRequired.
  ///
  /// In af, this message translates to:
  /// **'Van word benodig'**
  String get profileEditLastNameRequired;

  /// No description provided for @profileEditAddress.
  ///
  /// In af, this message translates to:
  /// **'Adres'**
  String get profileEditAddress;

  /// No description provided for @profileEditIsBaptized.
  ///
  /// In af, this message translates to:
  /// **'Is jy gedoop?'**
  String get profileEditIsBaptized;

  /// No description provided for @profileEditIsMember.
  ///
  /// In af, this message translates to:
  /// **'Is jy n lidmaat?'**
  String get profileEditIsMember;

  /// No description provided for @profileEditUpdateButton.
  ///
  /// In af, this message translates to:
  /// **'Opdateer Profiel'**
  String get profileEditUpdateButton;

  /// No description provided for @feedbackTitle.
  ///
  /// In af, this message translates to:
  /// **'Terugvoer & Verslae'**
  String get feedbackTitle;

  /// No description provided for @feedbackLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai terugvoer...'**
  String get feedbackLoading;

  /// No description provided for @feedbackSubmitTooltip.
  ///
  /// In af, this message translates to:
  /// **'Stuur terugvoer'**
  String get feedbackSubmitTooltip;

  /// No description provided for @feedbackSubmitSuccess.
  ///
  /// In af, this message translates to:
  /// **'Terugvoer suksesvol gestuur!'**
  String get feedbackSubmitSuccess;

  /// No description provided for @feedbackFilterAll.
  ///
  /// In af, this message translates to:
  /// **'Alles'**
  String get feedbackFilterAll;

  /// No description provided for @feedbackEmptyFiltered.
  ///
  /// In af, this message translates to:
  /// **'Geen terugvoer gevind vir hierdie filter nie.'**
  String get feedbackEmptyFiltered;

  /// No description provided for @feedbackSubmitTitle.
  ///
  /// In af, this message translates to:
  /// **'Stuur Terugvoer'**
  String get feedbackSubmitTitle;

  /// No description provided for @feedbackCategoryLabel.
  ///
  /// In af, this message translates to:
  /// **'Kategorie'**
  String get feedbackCategoryLabel;

  /// No description provided for @feedbackTitleLabel.
  ///
  /// In af, this message translates to:
  /// **'Titel'**
  String get feedbackTitleLabel;

  /// No description provided for @feedbackTitleHint.
  ///
  /// In af, this message translates to:
  /// **'Kort opsomming van jou terugvoer'**
  String get feedbackTitleHint;

  /// No description provided for @feedbackBodyLabel.
  ///
  /// In af, this message translates to:
  /// **'Beskrywing'**
  String get feedbackBodyLabel;

  /// No description provided for @feedbackBodyHint.
  ///
  /// In af, this message translates to:
  /// **'Beskryf die probleem of voorstel in detail'**
  String get feedbackBodyHint;

  /// No description provided for @feedbackSubmitButton.
  ///
  /// In af, this message translates to:
  /// **'Stuur Terugvoer'**
  String get feedbackSubmitButton;

  /// No description provided for @feedbackCategoryRequired.
  ///
  /// In af, this message translates to:
  /// **'Kies asseblief \'n kategorie.'**
  String get feedbackCategoryRequired;

  /// No description provided for @feedbackTitleRequired.
  ///
  /// In af, this message translates to:
  /// **'Voer asseblief \'n titel in.'**
  String get feedbackTitleRequired;

  /// No description provided for @feedbackBodyRequired.
  ///
  /// In af, this message translates to:
  /// **'Voer asseblief \'n beskrywing in.'**
  String get feedbackBodyRequired;

  /// No description provided for @feedbackAuthRequired.
  ///
  /// In af, this message translates to:
  /// **'Jy moet ingeteken wees om terugvoer te stuur.'**
  String get feedbackAuthRequired;

  /// No description provided for @feedbackCategoryBugReport.
  ///
  /// In af, this message translates to:
  /// **'Fout / Probleem'**
  String get feedbackCategoryBugReport;

  /// No description provided for @feedbackCategoryFeatureRequest.
  ///
  /// In af, this message translates to:
  /// **'Nuwe Funksie'**
  String get feedbackCategoryFeatureRequest;

  /// No description provided for @feedbackCategoryImprovement.
  ///
  /// In af, this message translates to:
  /// **'Verbetering'**
  String get feedbackCategoryImprovement;

  /// No description provided for @feedbackCategoryOther.
  ///
  /// In af, this message translates to:
  /// **'Ander'**
  String get feedbackCategoryOther;

  /// No description provided for @feedbackStatusOpen.
  ///
  /// In af, this message translates to:
  /// **'Oop'**
  String get feedbackStatusOpen;

  /// No description provided for @feedbackStatusUnderReview.
  ///
  /// In af, this message translates to:
  /// **'Onder Oorsig'**
  String get feedbackStatusUnderReview;

  /// No description provided for @feedbackStatusPlanned.
  ///
  /// In af, this message translates to:
  /// **'Beplan'**
  String get feedbackStatusPlanned;

  /// No description provided for @feedbackStatusResolved.
  ///
  /// In af, this message translates to:
  /// **'Opgelos'**
  String get feedbackStatusResolved;

  /// No description provided for @feedbackStatusClosed.
  ///
  /// In af, this message translates to:
  /// **'Gesluit'**
  String get feedbackStatusClosed;

  /// No description provided for @announcementsTitle.
  ///
  /// In af, this message translates to:
  /// **'Aankondigings'**
  String get announcementsTitle;

  /// No description provided for @announcementsLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Aankondigings'**
  String get announcementsLoading;

  /// No description provided for @announcementsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Aankondigings'**
  String get announcementsEmpty;

  /// No description provided for @calendarLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Kalender'**
  String get calendarLoading;

  /// No description provided for @calendarEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Kalender Items'**
  String get calendarEmpty;

  /// No description provided for @coursesLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Kursusse'**
  String get coursesLoading;

  /// No description provided for @coursesEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Kursusse'**
  String get coursesEmpty;

  /// No description provided for @courseStartDate.
  ///
  /// In af, this message translates to:
  /// **'Begin Datum'**
  String get courseStartDate;

  /// No description provided for @courseEndDate.
  ///
  /// In af, this message translates to:
  /// **'Eind Datum'**
  String get courseEndDate;

  /// No description provided for @courseTime.
  ///
  /// In af, this message translates to:
  /// **'Tyd'**
  String get courseTime;

  /// No description provided for @courseDescription.
  ///
  /// In af, this message translates to:
  /// **'Beskrywing'**
  String get courseDescription;

  /// No description provided for @commonAddToCalendar.
  ///
  /// In af, this message translates to:
  /// **'Voeg by Kalender'**
  String get commonAddToCalendar;

  /// No description provided for @upcomingEventsLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Opkomende Gebeure'**
  String get upcomingEventsLoading;

  /// No description provided for @upcomingEventsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Opkomende Gebeure'**
  String get upcomingEventsEmpty;

  /// No description provided for @upcomingEventsAttendingCount.
  ///
  /// In af, this message translates to:
  /// **'{count} kom'**
  String upcomingEventsAttendingCount(Object count);

  /// No description provided for @upcomingEventsInterestedCount.
  ///
  /// In af, this message translates to:
  /// **'{count} stel belang'**
  String upcomingEventsInterestedCount(Object count);

  /// No description provided for @sermonsTitle.
  ///
  /// In af, this message translates to:
  /// **'Preke'**
  String get sermonsTitle;

  /// No description provided for @sermonsLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Preke'**
  String get sermonsLoading;

  /// No description provided for @sermonsSearchHint.
  ///
  /// In af, this message translates to:
  /// **'Soek preke...'**
  String get sermonsSearchHint;

  /// No description provided for @sermonsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Preke Beskikbaar'**
  String get sermonsEmpty;

  /// No description provided for @sermonDetailTitle.
  ///
  /// In af, this message translates to:
  /// **'Preek Besonderhede'**
  String get sermonDetailTitle;

  /// No description provided for @sermonNoDescription.
  ///
  /// In af, this message translates to:
  /// **'Geen beskrywing beskikbaar nie.'**
  String get sermonNoDescription;

  /// No description provided for @sermonWatchOnYoutube.
  ///
  /// In af, this message translates to:
  /// **'Kyk op YouTube'**
  String get sermonWatchOnYoutube;

  /// No description provided for @sermonVideoInfo.
  ///
  /// In af, this message translates to:
  /// **'Video Inligting'**
  String get sermonVideoInfo;

  /// No description provided for @sermonProviderLabel.
  ///
  /// In af, this message translates to:
  /// **'Verskaffer'**
  String get sermonProviderLabel;

  /// No description provided for @sermonLinkLabel.
  ///
  /// In af, this message translates to:
  /// **'Skakel'**
  String get sermonLinkLabel;

  /// No description provided for @socialMediaLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Volg Ons'**
  String get socialMediaLoading;

  /// No description provided for @socialMediaEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen Volg Ons Skakels'**
  String get socialMediaEmpty;

  /// No description provided for @commonYou.
  ///
  /// In af, this message translates to:
  /// **'Jy'**
  String get commonYou;

  /// No description provided for @groupPostEditTitle.
  ///
  /// In af, this message translates to:
  /// **'Wysig Plasing'**
  String get groupPostEditTitle;

  /// No description provided for @groupPostNewTitle.
  ///
  /// In af, this message translates to:
  /// **'Nuwe Plasing'**
  String get groupPostNewTitle;

  /// No description provided for @groupPostPublish.
  ///
  /// In af, this message translates to:
  /// **'Plaas'**
  String get groupPostPublish;

  /// No description provided for @groupPostTitleOptional.
  ///
  /// In af, this message translates to:
  /// **'Titel (opsioneel)'**
  String get groupPostTitleOptional;

  /// No description provided for @groupPostBodyPlaceholder.
  ///
  /// In af, this message translates to:
  /// **'Skryf jou plasing hier...'**
  String get groupPostBodyPlaceholder;

  /// No description provided for @groupPostBodyRequired.
  ///
  /// In af, this message translates to:
  /// **'Skryf eers iets vir die plasing.'**
  String get groupPostBodyRequired;

  /// No description provided for @groupReactionAmen.
  ///
  /// In af, this message translates to:
  /// **'Amen'**
  String get groupReactionAmen;

  /// No description provided for @groupReactionPrayer.
  ///
  /// In af, this message translates to:
  /// **'Gebed'**
  String get groupReactionPrayer;

  /// No description provided for @groupReactionHeart.
  ///
  /// In af, this message translates to:
  /// **'Hart'**
  String get groupReactionHeart;

  /// No description provided for @pastoralBlogTitle.
  ///
  /// In af, this message translates to:
  /// **'Blog'**
  String get pastoralBlogTitle;

  /// No description provided for @pastoralBlogLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai blog...'**
  String get pastoralBlogLoading;

  /// No description provided for @pastoralBlogLoadError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie blog laai nie.'**
  String get pastoralBlogLoadError;

  /// No description provided for @pastoralBlogEmpty.
  ///
  /// In af, this message translates to:
  /// **'Geen blogplasings beskikbaar nie.'**
  String get pastoralBlogEmpty;

  /// No description provided for @pastoralBlogReadMore.
  ///
  /// In af, this message translates to:
  /// **'Lees meer'**
  String get pastoralBlogReadMore;

  /// No description provided for @pastoralBlogPostLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai pos...'**
  String get pastoralBlogPostLoading;

  /// No description provided for @pastoralBlogPostNotFound.
  ///
  /// In af, this message translates to:
  /// **'Pos nie gevind nie.'**
  String get pastoralBlogPostNotFound;

  /// No description provided for @pastoralBlogReact.
  ///
  /// In af, this message translates to:
  /// **'Reageer'**
  String get pastoralBlogReact;

  /// No description provided for @pastoralReactionAmen.
  ///
  /// In af, this message translates to:
  /// **'Amen'**
  String get pastoralReactionAmen;

  /// No description provided for @pastoralReactionPrayer.
  ///
  /// In af, this message translates to:
  /// **'Gebed'**
  String get pastoralReactionPrayer;

  /// No description provided for @pastoralReactionHeart.
  ///
  /// In af, this message translates to:
  /// **'Hart'**
  String get pastoralReactionHeart;

  /// No description provided for @bibleCompareTranslationsTitle.
  ///
  /// In af, this message translates to:
  /// **'Vergelyk vertalings'**
  String get bibleCompareTranslationsTitle;

  /// No description provided for @bibleSearchTranslationHint.
  ///
  /// In af, this message translates to:
  /// **'Soek vertaling...'**
  String get bibleSearchTranslationHint;

  /// No description provided for @bibleNoTranslationsFound.
  ///
  /// In af, this message translates to:
  /// **'Geen vertalings gevind nie'**
  String get bibleNoTranslationsFound;

  /// No description provided for @bibleCompareLoadFailed.
  ///
  /// In af, this message translates to:
  /// **'Kon nie laai nie'**
  String get bibleCompareLoadFailed;

  /// No description provided for @bibleNoteTitle.
  ///
  /// In af, this message translates to:
  /// **'Bybelnota'**
  String get bibleNoteTitle;

  /// No description provided for @bibleNoteDescription.
  ///
  /// In af, this message translates to:
  /// **'Skryf \'n persoonlike nota vir {book} {chapter}:{verses}'**
  String bibleNoteDescription(Object book, Object chapter, Object verses);

  /// No description provided for @bibleNoteSaved.
  ///
  /// In af, this message translates to:
  /// **'Nota suksesvol gestoor'**
  String get bibleNoteSaved;

  /// No description provided for @bibleSharedViaApp.
  ///
  /// In af, this message translates to:
  /// **'Gedeel via LW App'**
  String get bibleSharedViaApp;

  /// No description provided for @bibleVerseCopied.
  ///
  /// In af, this message translates to:
  /// **'Vers gekopieër na klembord'**
  String get bibleVerseCopied;

  /// No description provided for @bibleSavedVersesTooltip.
  ///
  /// In af, this message translates to:
  /// **'Gestoorde Verse'**
  String get bibleSavedVersesTooltip;

  /// No description provided for @bibleLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Bybel'**
  String get bibleLoading;

  /// No description provided for @bibleChooseTranslation.
  ///
  /// In af, this message translates to:
  /// **'Kies Vertaling'**
  String get bibleChooseTranslation;

  /// No description provided for @bibleChapterParseError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie hoofstuk-inhoud ontleed nie.'**
  String get bibleChapterParseError;

  /// No description provided for @bibleProvidedByYouVersion.
  ///
  /// In af, this message translates to:
  /// **'Verskaf deur YouVersion'**
  String get bibleProvidedByYouVersion;

  /// No description provided for @bibleVersesSelected.
  ///
  /// In af, this message translates to:
  /// **'{count} vers(e) gekies'**
  String bibleVersesSelected(Object count);

  /// No description provided for @bibleBookmarkUpdated.
  ///
  /// In af, this message translates to:
  /// **'Boekmerk opgedateer'**
  String get bibleBookmarkUpdated;

  /// No description provided for @bibleImageLabel.
  ///
  /// In af, this message translates to:
  /// **'Beeld'**
  String get bibleImageLabel;

  /// No description provided for @bibleCompareLabel.
  ///
  /// In af, this message translates to:
  /// **'Vergelyk'**
  String get bibleCompareLabel;

  /// No description provided for @bibleTranslationTab.
  ///
  /// In af, this message translates to:
  /// **'Vertaling'**
  String get bibleTranslationTab;

  /// No description provided for @bibleBookTab.
  ///
  /// In af, this message translates to:
  /// **'Boek'**
  String get bibleBookTab;

  /// No description provided for @bibleChapterTab.
  ///
  /// In af, this message translates to:
  /// **'Hoofstuk'**
  String get bibleChapterTab;

  /// No description provided for @bibleSearchBookHint.
  ///
  /// In af, this message translates to:
  /// **'Soek boek...'**
  String get bibleSearchBookHint;

  /// No description provided for @bibleNavigateTo.
  ///
  /// In af, this message translates to:
  /// **'Navigeer na {book} {chapter}'**
  String bibleNavigateTo(Object book, Object chapter);

  /// No description provided for @bibleBookUnavailable.
  ///
  /// In af, this message translates to:
  /// **'Boek nie beskikbaar in huidige vertaling nie.'**
  String get bibleBookUnavailable;

  /// No description provided for @savedVersesItemUpdated.
  ///
  /// In af, this message translates to:
  /// **'Item suksesvol opgedateer'**
  String get savedVersesItemUpdated;

  /// No description provided for @savedVersesUpdateError.
  ///
  /// In af, this message translates to:
  /// **'Fout met opdatering: {error}'**
  String savedVersesUpdateError(Object error);

  /// No description provided for @savedVersesEditBibleNote.
  ///
  /// In af, this message translates to:
  /// **'Wysig Bybelnota'**
  String get savedVersesEditBibleNote;

  /// No description provided for @savedVersesNoteUpdated.
  ///
  /// In af, this message translates to:
  /// **'Nota opgedateer'**
  String get savedVersesNoteUpdated;

  /// No description provided for @savedVersesNoteSaveError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie nota stoor nie'**
  String get savedVersesNoteSaveError;

  /// No description provided for @savedVersesMyBibleNote.
  ///
  /// In af, this message translates to:
  /// **'My Bybelnota vir'**
  String get savedVersesMyBibleNote;

  /// No description provided for @savedVersesNoteCopied.
  ///
  /// In af, this message translates to:
  /// **'Nota gekopieër na klembord'**
  String get savedVersesNoteCopied;

  /// No description provided for @savedVersesTitle.
  ///
  /// In af, this message translates to:
  /// **'Bybel Argief'**
  String get savedVersesTitle;

  /// No description provided for @savedVersesSavedTab.
  ///
  /// In af, this message translates to:
  /// **'Bewaarde Verse'**
  String get savedVersesSavedTab;

  /// No description provided for @savedVersesMyNotesTab.
  ///
  /// In af, this message translates to:
  /// **'My Notas'**
  String get savedVersesMyNotesTab;

  /// No description provided for @savedVersesLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai argief...'**
  String get savedVersesLoading;

  /// No description provided for @savedVersesEmpty.
  ///
  /// In af, this message translates to:
  /// **'Jy het nog geen verse gestoor of verlig nie.'**
  String get savedVersesEmpty;

  /// No description provided for @savedVersesTapToView.
  ///
  /// In af, this message translates to:
  /// **'Tik om in Bybel te sien...'**
  String get savedVersesTapToView;

  /// No description provided for @savedVersesRemoveBookmark.
  ///
  /// In af, this message translates to:
  /// **'Verwyder Boekmerk'**
  String get savedVersesRemoveBookmark;

  /// No description provided for @savedVersesNotesEmpty.
  ///
  /// In af, this message translates to:
  /// **'Jy het nog geen persoonlike Bybelnotas bygevoeg nie.'**
  String get savedVersesNotesEmpty;

  /// No description provided for @savedVersesShareNote.
  ///
  /// In af, this message translates to:
  /// **'Deel Nota'**
  String get savedVersesShareNote;

  /// No description provided for @savedVersesEditNote.
  ///
  /// In af, this message translates to:
  /// **'Wysig Nota'**
  String get savedVersesEditNote;

  /// No description provided for @savedVersesDeleteNote.
  ///
  /// In af, this message translates to:
  /// **'Verwyder Nota'**
  String get savedVersesDeleteNote;

  /// No description provided for @bibleCreateImage.
  ///
  /// In af, this message translates to:
  /// **'Skep beeld'**
  String get bibleCreateImage;

  /// No description provided for @bibleImageFormat.
  ///
  /// In af, this message translates to:
  /// **'Formaat'**
  String get bibleImageFormat;

  /// No description provided for @bibleImageTextSize.
  ///
  /// In af, this message translates to:
  /// **'Teksgrootte'**
  String get bibleImageTextSize;

  /// No description provided for @bibleImageAlignment.
  ///
  /// In af, this message translates to:
  /// **'Belyning'**
  String get bibleImageAlignment;

  /// No description provided for @bibleImageOverlay.
  ///
  /// In af, this message translates to:
  /// **'Oorlaag'**
  String get bibleImageOverlay;

  /// No description provided for @bibleImageLightText.
  ///
  /// In af, this message translates to:
  /// **'Ligte teks'**
  String get bibleImageLightText;

  /// No description provided for @bibleImageDownload.
  ///
  /// In af, this message translates to:
  /// **'Laai af'**
  String get bibleImageDownload;

  /// No description provided for @bibleImageCreating.
  ///
  /// In af, this message translates to:
  /// **'Skep...'**
  String get bibleImageCreating;

  /// No description provided for @bibleImageSaved.
  ///
  /// In af, this message translates to:
  /// **'Beeld is in jou galery gestoor'**
  String get bibleImageSaved;

  /// No description provided for @bibleImageSaveError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie die beeld in jou galery stoor nie'**
  String get bibleImageSaveError;

  /// No description provided for @myPrayerRequestsEmptyForStatus.
  ///
  /// In af, this message translates to:
  /// **'Geen gebedsversoeke vir hierdie status nie.'**
  String get myPrayerRequestsEmptyForStatus;

  /// No description provided for @visitorWelcomeTitle.
  ///
  /// In af, this message translates to:
  /// **'Welkom!'**
  String get visitorWelcomeTitle;

  /// No description provided for @visitorUpcomingEventsTitle.
  ///
  /// In af, this message translates to:
  /// **'Opkomende Gebeure'**
  String get visitorUpcomingEventsTitle;

  /// No description provided for @visitorWelcomeHeadline.
  ///
  /// In af, this message translates to:
  /// **'Welkom by Lewende Woord Paarl!'**
  String get visitorWelcomeHeadline;

  /// No description provided for @visitorWelcomeBody.
  ///
  /// In af, this message translates to:
  /// **'Ons is opgewonde om jou hier te hê. Hier is \'n paar vinnige skakels en inligting om jou te help inskakel.'**
  String get visitorWelcomeBody;

  /// No description provided for @visitorSundayServices.
  ///
  /// In af, this message translates to:
  /// **'Sondag Dienste'**
  String get visitorSundayServices;

  /// No description provided for @visitorMorningService.
  ///
  /// In af, this message translates to:
  /// **'Oggend Diens'**
  String get visitorMorningService;

  /// No description provided for @visitorEveningService.
  ///
  /// In af, this message translates to:
  /// **'Aand Diens'**
  String get visitorEveningService;

  /// No description provided for @visitorFindUs.
  ///
  /// In af, this message translates to:
  /// **'Vind Ons'**
  String get visitorFindUs;

  /// No description provided for @visitorContactUs.
  ///
  /// In af, this message translates to:
  /// **'Kontak Ons'**
  String get visitorContactUs;

  /// No description provided for @visitorMoreAboutUs.
  ///
  /// In af, this message translates to:
  /// **'Meer Oor Ons'**
  String get visitorMoreAboutUs;

  /// No description provided for @visitorNoUpcomingEvents.
  ///
  /// In af, this message translates to:
  /// **'Geen opkomende gebeure tans nie.'**
  String get visitorNoUpcomingEvents;

  /// No description provided for @visitorUpcomingEventsError.
  ///
  /// In af, this message translates to:
  /// **'Kon nie gebeure laai nie.'**
  String get visitorUpcomingEventsError;

  /// No description provided for @tithesTitle.
  ///
  /// In af, this message translates to:
  /// **'Tiendes & Offergawes'**
  String get tithesTitle;

  /// No description provided for @tithesLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai Tiendes & Offergawes'**
  String get tithesLoading;

  /// No description provided for @tithesEmpty.
  ///
  /// In af, this message translates to:
  /// **'Tiendes & Offergawes inligting word binnekort opgedateer.'**
  String get tithesEmpty;

  /// No description provided for @tithesHeroTitle.
  ///
  /// In af, this message translates to:
  /// **'Gee met \'n Blye Hart'**
  String get tithesHeroTitle;

  /// No description provided for @tithesVerse.
  ///
  /// In af, this message translates to:
  /// **'Elkeen moet gee soos hy hom in sy hart voorgeneem het, nie met teensin of uit dwang nie, want God het \'n blymoedige gewer lief.\n— 2 Korintiërs 9:7'**
  String get tithesVerse;

  /// No description provided for @tithesBankDetails.
  ///
  /// In af, this message translates to:
  /// **'Bankbesonderhede (EFT)'**
  String get tithesBankDetails;

  /// No description provided for @tithesBankLabel.
  ///
  /// In af, this message translates to:
  /// **'Bank'**
  String get tithesBankLabel;

  /// No description provided for @tithesAccountNameLabel.
  ///
  /// In af, this message translates to:
  /// **'Rekeningnaam'**
  String get tithesAccountNameLabel;

  /// No description provided for @tithesAccountNumberLabel.
  ///
  /// In af, this message translates to:
  /// **'Rekeningnommer'**
  String get tithesAccountNumberLabel;

  /// No description provided for @tithesBranchCodeLabel.
  ///
  /// In af, this message translates to:
  /// **'Takkode'**
  String get tithesBranchCodeLabel;

  /// No description provided for @tithesReferenceLabel.
  ///
  /// In af, this message translates to:
  /// **'Verwysing'**
  String get tithesReferenceLabel;

  /// No description provided for @tithesScanWithSnapScan.
  ///
  /// In af, this message translates to:
  /// **'Skandeer met SnapScan'**
  String get tithesScanWithSnapScan;

  /// No description provided for @tithesScanDescription.
  ///
  /// In af, this message translates to:
  /// **'Maak jou SnapScan of Zapper toep oop en skandeer hierdie kode om vinnig en veilig te gee.'**
  String get tithesScanDescription;

  /// No description provided for @tithesCopied.
  ///
  /// In af, this message translates to:
  /// **'{label} gekopieer na knipbord'**
  String tithesCopied(Object label);

  /// No description provided for @tithesCopyTooltip.
  ///
  /// In af, this message translates to:
  /// **'Kopieer {label}'**
  String tithesCopyTooltip(Object label);

  /// No description provided for @upcomingEventDate.
  ///
  /// In af, this message translates to:
  /// **'Datum'**
  String get upcomingEventDate;

  /// No description provided for @upcomingEventAreYouGoing.
  ///
  /// In af, this message translates to:
  /// **'Gaan jy?'**
  String get upcomingEventAreYouGoing;

  /// No description provided for @upcomingEventSoldOut.
  ///
  /// In af, this message translates to:
  /// **'Vol Bespreek'**
  String get upcomingEventSoldOut;

  /// No description provided for @upcomingEventCapacity.
  ///
  /// In af, this message translates to:
  /// **'{attending} / {capacity} plekke bespreek'**
  String upcomingEventCapacity(Object attending, Object capacity);

  /// No description provided for @groupMembershipStatusPending.
  ///
  /// In af, this message translates to:
  /// **'Hangend'**
  String get groupMembershipStatusPending;

  /// No description provided for @groupMembershipStatusActive.
  ///
  /// In af, this message translates to:
  /// **'Aktief'**
  String get groupMembershipStatusActive;

  /// No description provided for @groupMembershipStatusDeclined.
  ///
  /// In af, this message translates to:
  /// **'Afgekeur'**
  String get groupMembershipStatusDeclined;

  /// No description provided for @groupMembershipStatusLeft.
  ///
  /// In af, this message translates to:
  /// **'Verlaat'**
  String get groupMembershipStatusLeft;

  /// No description provided for @groupMembershipStatusRemoved.
  ///
  /// In af, this message translates to:
  /// **'Verwyder'**
  String get groupMembershipStatusRemoved;

  /// No description provided for @prayerRequestsTitle.
  ///
  /// In af, this message translates to:
  /// **'Gebedsversoeke'**
  String get prayerRequestsTitle;

  /// No description provided for @prayerRequestsLoading.
  ///
  /// In af, this message translates to:
  /// **'Laai gebedsversoeke...'**
  String get prayerRequestsLoading;

  /// No description provided for @prayerRequestsNew.
  ///
  /// In af, this message translates to:
  /// **'Nuwe versoek'**
  String get prayerRequestsNew;

  /// No description provided for @prayerRequestsCreateTitle.
  ///
  /// In af, this message translates to:
  /// **'Stuur \'n gebedsversoek'**
  String get prayerRequestsCreateTitle;

  /// No description provided for @prayerRequestsBodyLabel.
  ///
  /// In af, this message translates to:
  /// **'Gebedsversoek'**
  String get prayerRequestsBodyLabel;

  /// No description provided for @prayerRequestsBodyRequired.
  ///
  /// In af, this message translates to:
  /// **'Voer asseblief \'n gebedsversoek in.'**
  String get prayerRequestsBodyRequired;

  /// No description provided for @prayerRequestsAnonymousTitle.
  ///
  /// In af, this message translates to:
  /// **'Plaas as anoniem'**
  String get prayerRequestsAnonymousTitle;

  /// No description provided for @prayerRequestsAnonymousSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Wanneer hierdie versoek goedgekeur word, sal dit as \"Anoniem\" wys.'**
  String get prayerRequestsAnonymousSubtitle;

  /// No description provided for @prayerRequestsPrivateTitle.
  ///
  /// In af, this message translates to:
  /// **'Hou privaat'**
  String get prayerRequestsPrivateTitle;

  /// No description provided for @prayerRequestsPrivateSubtitle.
  ///
  /// In af, this message translates to:
  /// **'Slegs kerkleierskap sal hierdie versoek kan sien.'**
  String get prayerRequestsPrivateSubtitle;

  /// No description provided for @prayerRequestsSubmitButton.
  ///
  /// In af, this message translates to:
  /// **'Stuur versoek'**
  String get prayerRequestsSubmitButton;

  /// No description provided for @prayerRequestsSubmitSuccess.
  ///
  /// In af, this message translates to:
  /// **'Gebedsversoek gestuur. Dit wag nou vir goedkeuring.'**
  String get prayerRequestsSubmitSuccess;

  /// No description provided for @prayerRequestsEmpty.
  ///
  /// In af, this message translates to:
  /// **'Daar is nog geen oop gebedsversoeke nie.'**
  String get prayerRequestsEmpty;

  /// No description provided for @prayerAnonymousName.
  ///
  /// In af, this message translates to:
  /// **'Anoniem'**
  String get prayerAnonymousName;

  /// No description provided for @prayerModerationNote.
  ///
  /// In af, this message translates to:
  /// **'Nota: {note}'**
  String prayerModerationNote(Object note);

  /// No description provided for @prayerReactionLabel.
  ///
  /// In af, this message translates to:
  /// **'Ek bid vir jou ({count})'**
  String prayerReactionLabel(Object count);

  /// No description provided for @prayerResolveAction.
  ///
  /// In af, this message translates to:
  /// **'Merk as afgehandel'**
  String get prayerResolveAction;

  /// No description provided for @prayerCategoryHealing.
  ///
  /// In af, this message translates to:
  /// **'Genesing'**
  String get prayerCategoryHealing;

  /// No description provided for @prayerCategoryFamily.
  ///
  /// In af, this message translates to:
  /// **'Familie'**
  String get prayerCategoryFamily;

  /// No description provided for @prayerCategoryProvision.
  ///
  /// In af, this message translates to:
  /// **'Voorsiening'**
  String get prayerCategoryProvision;

  /// No description provided for @prayerCategoryGuidance.
  ///
  /// In af, this message translates to:
  /// **'Leiding'**
  String get prayerCategoryGuidance;

  /// No description provided for @prayerCategorySpiritualGrowth.
  ///
  /// In af, this message translates to:
  /// **'Geestelike Groei'**
  String get prayerCategorySpiritualGrowth;

  /// No description provided for @prayerCategoryThanksgiving.
  ///
  /// In af, this message translates to:
  /// **'Danksegging'**
  String get prayerCategoryThanksgiving;

  /// No description provided for @prayerCategoryOther.
  ///
  /// In af, this message translates to:
  /// **'Ander'**
  String get prayerCategoryOther;

  /// No description provided for @prayerStatusPending.
  ///
  /// In af, this message translates to:
  /// **'Wag vir goedkeuring'**
  String get prayerStatusPending;

  /// No description provided for @prayerStatusApproved.
  ///
  /// In af, this message translates to:
  /// **'Goedgekeur'**
  String get prayerStatusApproved;

  /// No description provided for @prayerStatusRejected.
  ///
  /// In af, this message translates to:
  /// **'Afgekeur'**
  String get prayerStatusRejected;

  /// No description provided for @prayerStatusResolved.
  ///
  /// In af, this message translates to:
  /// **'Afgehandel'**
  String get prayerStatusResolved;

  /// No description provided for @dashboardMorningGreeting.
  ///
  /// In af, this message translates to:
  /// **'Goeie More'**
  String get dashboardMorningGreeting;

  /// No description provided for @dashboardAfternoonGreeting.
  ///
  /// In af, this message translates to:
  /// **'Goeie Middag'**
  String get dashboardAfternoonGreeting;

  /// No description provided for @dashboardEveningGreeting.
  ///
  /// In af, this message translates to:
  /// **'Goeie Naand'**
  String get dashboardEveningGreeting;

  /// No description provided for @dashboardNightGreeting.
  ///
  /// In af, this message translates to:
  /// **'Goeie Nag'**
  String get dashboardNightGreeting;

  /// No description provided for @dashboardChurchName.
  ///
  /// In af, this message translates to:
  /// **'Lewende Woord Paarl'**
  String get dashboardChurchName;

  /// No description provided for @dashboardUpcomingEvents.
  ///
  /// In af, this message translates to:
  /// **'Opkomende Gebeure'**
  String get dashboardUpcomingEvents;

  /// No description provided for @dashboardTithesOfferings.
  ///
  /// In af, this message translates to:
  /// **'Tiendes & Offergawes'**
  String get dashboardTithesOfferings;

  /// No description provided for @dashboardFirstTimeVisitor.
  ///
  /// In af, this message translates to:
  /// **'Eerste Keer Besoeker'**
  String get dashboardFirstTimeVisitor;

  /// No description provided for @dashboardFollowUs.
  ///
  /// In af, this message translates to:
  /// **'Volg Ons'**
  String get dashboardFollowUs;

  /// No description provided for @dashboardCourses.
  ///
  /// In af, this message translates to:
  /// **'Kursusse'**
  String get dashboardCourses;

  /// No description provided for @dashboardPrayerRequests.
  ///
  /// In af, this message translates to:
  /// **'Gebedsversoeke'**
  String get dashboardPrayerRequests;

  /// No description provided for @dashboardBlog.
  ///
  /// In af, this message translates to:
  /// **'Blog'**
  String get dashboardBlog;
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
      <String>['af', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'af':
      return AppLocalizationsAf();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
