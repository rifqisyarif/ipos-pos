import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'IPOT POS'**
  String get appTitle;

  /// No description provided for @scanQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrTitle;

  /// No description provided for @scanQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point camera at the table QR code'**
  String get scanQrSubtitle;

  /// No description provided for @torch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get torch;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;

  /// No description provided for @useDemoTable.
  ///
  /// In en, this message translates to:
  /// **'Use Demo Table (T001)'**
  String get useDemoTable;

  /// No description provided for @invalidQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get invalidQrTitle;

  /// No description provided for @invalidQrDesc.
  ///
  /// In en, this message translates to:
  /// **'Please scan a valid restaurant table QR code.'**
  String get invalidQrDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @searchMenu.
  ///
  /// In en, this message translates to:
  /// **'Search menu...'**
  String get searchMenu;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItems;

  /// No description provided for @loadingMenu.
  ///
  /// In en, this message translates to:
  /// **'Loading menu...'**
  String get loadingMenu;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View Cart'**
  String get viewCart;

  /// No description provided for @itemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item Not Found'**
  String get itemNotFound;

  /// No description provided for @customizationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Customizations available'**
  String get customizationsAvailable;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @myCart.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get myCart;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clearCart;

  /// No description provided for @clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from cart?'**
  String get clearCartConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax (10%)'**
  String get tax;

  /// No description provided for @taxDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculated at checkout'**
  String get taxDesc;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @browseMenuAdd.
  ///
  /// In en, this message translates to:
  /// **'Browse the menu and add some items!'**
  String get browseMenuAdd;

  /// No description provided for @browseMenu.
  ///
  /// In en, this message translates to:
  /// **'Browse Menu'**
  String get browseMenu;

  /// No description provided for @orderStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatusTitle;

  /// No description provided for @orderMore.
  ///
  /// In en, this message translates to:
  /// **'Order More'**
  String get orderMore;

  /// No description provided for @orderReceivedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your order has been received!'**
  String get orderReceivedDesc;

  /// No description provided for @orderConfirmedDesc.
  ///
  /// In en, this message translates to:
  /// **'Great! Your order is confirmed.'**
  String get orderConfirmedDesc;

  /// No description provided for @orderPreparingDesc.
  ///
  /// In en, this message translates to:
  /// **'Our chefs are preparing your food 🍳'**
  String get orderPreparingDesc;

  /// No description provided for @orderReadyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your order is ready! 🎉'**
  String get orderReadyDesc;

  /// No description provided for @orderServedDesc.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your meal! 😋'**
  String get orderServedDesc;

  /// No description provided for @trackingOrder.
  ///
  /// In en, this message translates to:
  /// **'Tracking your order...'**
  String get trackingOrder;

  /// No description provided for @orderConfirmedMsg.
  ///
  /// In en, this message translates to:
  /// **'Order Confirmed!'**
  String get orderConfirmedMsg;

  /// No description provided for @autoUpdating.
  ///
  /// In en, this message translates to:
  /// **'Auto-updating every 8 s'**
  String get autoUpdating;

  /// No description provided for @noActiveOrderQueued.
  ///
  /// In en, this message translates to:
  /// **'No active order — see queued orders below'**
  String get noActiveOrderQueued;

  /// No description provided for @noActiveOrder.
  ///
  /// In en, this message translates to:
  /// **'No active order yet'**
  String get noActiveOrder;

  /// No description provided for @ordersInQueue.
  ///
  /// In en, this message translates to:
  /// **'{count} order(s) in queue'**
  String ordersInQueue(int count);

  /// No description provided for @retryAll.
  ///
  /// In en, this message translates to:
  /// **'Retry All'**
  String get retryAll;

  /// No description provided for @willRetryWhenOnline.
  ///
  /// In en, this message translates to:
  /// **'Will retry when online'**
  String get willRetryWhenOnline;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offline;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get backOnline;

  /// No description provided for @requiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredLabel;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalLabel;

  /// No description provided for @upToN.
  ///
  /// In en, this message translates to:
  /// **'Up to {max}'**
  String upToN(int max);

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special instructions (optional)'**
  String get specialInstructions;

  /// No description provided for @addToCartPrice.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart — {price}'**
  String addToCartPrice(String price);

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @orderReceivedState.
  ///
  /// In en, this message translates to:
  /// **'Order\nReceived'**
  String get orderReceivedState;

  /// No description provided for @orderConfirmedState.
  ///
  /// In en, this message translates to:
  /// **'Order\nConfirmed'**
  String get orderConfirmedState;

  /// No description provided for @beingPreparedState.
  ///
  /// In en, this message translates to:
  /// **'Being\nPrepared'**
  String get beingPreparedState;

  /// No description provided for @readyToServeState.
  ///
  /// In en, this message translates to:
  /// **'Ready\nto Serve'**
  String get readyToServeState;

  /// No description provided for @servedState.
  ///
  /// In en, this message translates to:
  /// **'Served!'**
  String get servedState;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
