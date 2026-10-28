import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

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
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'VanMitra'**
  String get appTitle;

  /// No description provided for @motto.
  ///
  /// In en, this message translates to:
  /// **'Trade resources. Create livelihoods.'**
  String get motto;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN (6 digits) *'**
  String get pinLabel;

  /// No description provided for @pinHint.
  ///
  /// In en, this message translates to:
  /// **'6-digit PIN'**
  String get pinHint;

  /// No description provided for @pinInvalid.
  ///
  /// In en, this message translates to:
  /// **'The PIN must be exactly 6 digits.'**
  String get pinInvalid;

  /// No description provided for @livelihood.
  ///
  /// In en, this message translates to:
  /// **'Livelihood'**
  String get livelihood;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search forest resources, honey, bamboo...'**
  String get searchHint;

  /// No description provided for @addListing.
  ///
  /// In en, this message translates to:
  /// **'Add Listing'**
  String get addListing;

  /// No description provided for @requestToBuy.
  ///
  /// In en, this message translates to:
  /// **'Request to Buy'**
  String get requestToBuy;

  /// No description provided for @offerBarter.
  ///
  /// In en, this message translates to:
  /// **'Offer Barter'**
  String get offerBarter;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verificationPending;

  /// No description provided for @demoData.
  ///
  /// In en, this message translates to:
  /// **'Demo Data'**
  String get demoData;

  /// No description provided for @bulkNotice.
  ///
  /// In en, this message translates to:
  /// **'Orders of 50 units or more require sustainable purpose reason.'**
  String get bulkNotice;

  /// No description provided for @helpline.
  ///
  /// In en, this message translates to:
  /// **'Forest Rights Act 2006 · Privacy Policy'**
  String get helpline;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @syncStatus.
  ///
  /// In en, this message translates to:
  /// **'100% Synced · Offline Ready'**
  String get syncStatus;

  /// No description provided for @forestProduceAndTrade.
  ///
  /// In en, this message translates to:
  /// **'Forest Produce & Trade'**
  String get forestProduceAndTrade;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @activeListingsStat.
  ///
  /// In en, this message translates to:
  /// **'Active Listings'**
  String get activeListingsStat;

  /// No description provided for @newRequestsStat.
  ///
  /// In en, this message translates to:
  /// **'New Requests'**
  String get newRequestsStat;

  /// No description provided for @ordersStat.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersStat;

  /// No description provided for @totalEarningsStat.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarningsStat;

  /// No description provided for @addNewListing.
  ///
  /// In en, this message translates to:
  /// **'+ Add New Listing'**
  String get addNewListing;

  /// No description provided for @gsManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Gram Sabha Produce Management'**
  String get gsManagementTitle;

  /// No description provided for @myListingsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'My Forest Listings'**
  String get myListingsCardTitle;

  /// No description provided for @myListingsCardSub.
  ///
  /// In en, this message translates to:
  /// **'registered products'**
  String get myListingsCardSub;

  /// No description provided for @requestsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Buyer Requests & Inquiries'**
  String get requestsCardTitle;

  /// No description provided for @requestsCardSub.
  ///
  /// In en, this message translates to:
  /// **'pending requests'**
  String get requestsCardSub;

  /// No description provided for @ordersCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Direct Buyer Orders'**
  String get ordersCardTitle;

  /// No description provided for @ordersCardSub.
  ///
  /// In en, this message translates to:
  /// **'orders in fulfillment'**
  String get ordersCardSub;

  /// No description provided for @helpCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & FRA 2006 Rules'**
  String get helpCardTitle;

  /// No description provided for @helpCardSub.
  ///
  /// In en, this message translates to:
  /// **'Forest Rights Act guidelines & helpline'**
  String get helpCardSub;

  /// No description provided for @activeBadge.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeBadge;

  /// No description provided for @pendingBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingBadge;

  /// No description provided for @inProgressBadge.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressBadge;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @gramSabhaRole.
  ///
  /// In en, this message translates to:
  /// **'GRAM SABHA'**
  String get gramSabhaRole;
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
