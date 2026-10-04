import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// No description provided for @homeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào!'**
  String get homeTitle;

  /// No description provided for @homeDescription.
  ///
  /// In vi, this message translates to:
  /// **'Dán link Shopee để tạo link hoàn tiền và nhận lại một phần giá trị đơn hàng nhé.'**
  String get homeDescription;

  /// No description provided for @linkCardTitle.
  ///
  /// In vi, this message translates to:
  /// **'Dán link Shopee'**
  String get linkCardTitle;

  /// No description provided for @linkCardHint.
  ///
  /// In vi, this message translates to:
  /// **'Dán link sản phẩm để tạo link hoàn tiền'**
  String get linkCardHint;

  /// No description provided for @createCashbackLink.
  ///
  /// In vi, this message translates to:
  /// **'Tạo link hoàn tiền'**
  String get createCashbackLink;

  /// No description provided for @creatingCashbackLink.
  ///
  /// In vi, this message translates to:
  /// **'Đang tạo link...'**
  String get creatingCashbackLink;

  /// No description provided for @linkTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo link mua sắm'**
  String get linkTitle;

  /// No description provided for @linkLabel.
  ///
  /// In vi, this message translates to:
  /// **'Link sản phẩm Shopee'**
  String get linkLabel;

  /// No description provided for @linkPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Dán link Shopee vào đây'**
  String get linkPlaceholder;

  /// No description provided for @pasteLink.
  ///
  /// In vi, this message translates to:
  /// **'Dán link từ bộ nhớ tạm'**
  String get pasteLink;

  /// No description provided for @clearLink.
  ///
  /// In vi, this message translates to:
  /// **'Xóa link'**
  String get clearLink;

  /// No description provided for @linkSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tạo link mua sắm thành công'**
  String get linkSuccess;

  /// No description provided for @shopeeOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hỗ trợ link Shopee hợp lệ'**
  String get shopeeOnly;

  /// No description provided for @estimatedCashback.
  ///
  /// In vi, this message translates to:
  /// **'Tiền hoàn ước tính'**
  String get estimatedCashback;

  /// No description provided for @estimateUnavailable.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ước tính tiền hoàn'**
  String get estimateUnavailable;

  /// No description provided for @estimateNote.
  ///
  /// In vi, this message translates to:
  /// **'Số thực nhận có thể thay đổi sau khi Shopee xác nhận và đối soát đơn hàng.'**
  String get estimateNote;

  /// No description provided for @helpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cách nhận tiền hoàn'**
  String get helpTitle;

  /// No description provided for @helpStepOne.
  ///
  /// In vi, this message translates to:
  /// **'Nếu sản phẩm đã có trong giỏ, hãy xóa sản phẩm đó.'**
  String get helpStepOne;

  /// No description provided for @helpStepTwo.
  ///
  /// In vi, this message translates to:
  /// **'Tạo link tại Piggy Back và nhấn “Mua ngay”.'**
  String get helpStepTwo;

  /// No description provided for @helpStepThree.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sản phẩm vào giỏ và đặt hàng qua link vừa mở.'**
  String get helpStepThree;

  /// No description provided for @helpNote.
  ///
  /// In vi, this message translates to:
  /// **'Tiền hoàn phụ thuộc vào trạng thái đơn hàng và kết quả đối soát của Shopee.'**
  String get helpNote;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng'**
  String get navOrders;

  /// No description provided for @navWallet.
  ///
  /// In vi, this message translates to:
  /// **'Ví'**
  String get navWallet;

  /// No description provided for @navAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get navAccount;

  /// No description provided for @walletAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể rút'**
  String get walletAvailable;

  /// No description provided for @walletPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ xác nhận'**
  String get walletPending;

  /// No description provided for @walletReserved.
  ///
  /// In vi, this message translates to:
  /// **'Đang giữ để rút'**
  String get walletReserved;

  /// No description provided for @withdraw.
  ///
  /// In vi, this message translates to:
  /// **'Rút tiền'**
  String get withdraw;

  /// No description provided for @recentOrders.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng gần đây'**
  String get recentOrders;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// No description provided for @creditedToWallet.
  ///
  /// In vi, this message translates to:
  /// **'Đã ghi nhận vào ví'**
  String get creditedToWallet;

  /// No description provided for @walletReady.
  ///
  /// In vi, this message translates to:
  /// **'Tiền hoàn đã được ghi nhận vào ví'**
  String get walletReady;

  /// No description provided for @awaitingWallet.
  ///
  /// In vi, this message translates to:
  /// **'Chờ hoàn tất đối soát'**
  String get awaitingWallet;
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
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
