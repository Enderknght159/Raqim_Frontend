import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../config/app_config.dart';

/// Minimal app-level localizations. Arabic is the default (RTL).
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static AppLocalizations? ofNullable(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  bool get isArabic => locale.languageCode == 'ar';

  /// Lookup helper — returns the Arabic value by default, else English.
  String _t({required String ar, required String en}) =>
      isArabic ? ar : en;

  String get appTitle => _t(ar: 'رقيم', en: 'Raqim');
  String get loginTitle => _t(ar: 'رقيم', en: 'Raqim');
  String get username => _t(ar: 'اسم المستخدم', en: 'Username');
  String get password => _t(ar: 'كلمة المرور', en: 'Password');
  String get login => _t(ar: 'دخول', en: 'Sign in');
  String get enterUsername => _t(ar: 'أدخل اسم المستخدم', en: 'Enter username');
  String get enterPassword => _t(ar: 'أدخل كلمة المرور', en: 'Enter password');
  String get comingSoon => _t(ar: 'قريباً', en: 'Coming soon');
  String get notAllowed => _t(ar: 'غير مسموح', en: 'Not allowed');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppConfig.supportedLocales.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Returns the app-wide localization delegates (Material + custom).
List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates() {
  return const [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}