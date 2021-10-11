import 'dart:ui';
import 'package:iot_starter_kit_app/generated/locale_base.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Code by **ch3ckmat3** (sci.news@orison.biz)
/// 1. Setup app's locale list in the [_languages] HashMap
/// 2. Add file names in the `pubspec.yaml`'s assets section:
/// ```
/// assets:
///     - locales/
/// ```
/// 3. Install VS Code extension '`apin.flutter-internationalize` from
/// https://marketplace.visualstudio.com/items?itemName=apin.flutter-internationalize
/// to manage, import and export translations and generate code in the
/// `/lib/generated` folder
/// 4. Import `/lib/generated/locale_base.dart` file here
/// 5. Get a reference to the current language dictionary in your code using
/// following call, usually in the `build` methods:
/// ```dart
/// final lang = Localizations.of<LocaleBase>(context, LocaleBase);
/// ```
/// ... or load language directly on demand:
/// ```dart
/// final lang = LocaleBase();
/// lang.load('locales/en_US.json').then((v) {
///   print(lang.HomeScreen.greeting);
/// }
/// ```
/// 6. Now use like this:
/// ```dart
/// Text(lang.HomeScreen.greeting);
/// // output "Welcome!"
/// // the  `lang.HomeScreen.user_greeting` is set as "Welcome {}!"
/// Text(LocaleDelegate.render(lang.HomeScreen.user_greeting, args: ["John"],));
/// // output "Welcome John!"
/// ```
/// 7. Check [LocaleDelegate.render()] method on template translations
class LocaleDelegate extends LocalizationsDelegate<LocaleBase> {
  LocaleDelegate();

  // using emoji flags in Local Names
  static final Map<String, Language> _languages = {
    'en-US': new Language(
      localeKey: 'en-US',
      name: 'English',
      localName: '🇺🇸 English',
      languageCode: 'en',
      countryCode: 'US',
      translationFilePath: 'locales/en-US.json',
      flagFilePath: '🇺🇸',
    ),
    'es-AR': Language(
      localeKey: 'es-AR',
      name: 'Spanish',
      localName: '🇦🇷 Español',
      languageCode: 'es',
      countryCode: 'AR',
      translationFilePath: 'locales/es-AR.json',
      flagFilePath: '🇦🇷',
    ),
    'en': Language(
      localeKey: 'en',
      name: 'English',
      localName: '🇬🇧 English',
      languageCode: 'en',
      countryCode: '',
      translationFilePath: 'locales/en.json',
      flagFilePath: '🇬🇧',
    ),
    'de': Language(
      localeKey: 'de',
      name: 'German',
      localName: '🇩🇪 Deutsch',
      languageCode: 'de',
      countryCode: '',
      translationFilePath: 'locales/de.json',
      flagFilePath: '🇩🇪',
    ),
    'es': Language(
      localeKey: 'es',
      name: 'Spanish',
      localName: '🇪🇸 Español',
      languageCode: 'es',
      countryCode: '',
      translationFilePath: 'locales/es.json',
      flagFilePath: '🇪🇸',
    ),
    'fr': Language(
      localeKey: 'fr',
      name: 'French',
      localName: '🇫🇷 Français',
      languageCode: 'fr',
      countryCode: '',
      translationFilePath: 'locales/fr.json',
      flagFilePath: '🇫🇷',
    ),
    'ar': Language(
      localeKey: 'ar',
      name: 'Arabic',
      localName: '🇸🇦 العربية',
      languageCode: 'ar',
      countryCode: '',
      translationFilePath: 'locales/ar.json',
      flagFilePath: '🇸🇦',
    ),
    'ur': Language(
      localeKey: 'ur',
      name: 'Urdu',
      localName: '🇵🇰 اردو',
      languageCode: 'ur',
      countryCode: '',
      translationFilePath: 'locales/ur.json',
      flagFilePath: '🇵🇰',
    ),
  };

  @override
  bool isSupported(Locale locale) {
    var result = getSupportedLocales().firstWhere((thisLocale) {
      return (thisLocale.languageCode == locale.languageCode);
    }, orElse: () => null);
    return result != null;
  }

  @override
  Future<LocaleBase> load(Locale locale) async {
    var defaultLang = 'en-US';
    if (isSupported(locale)) {
      defaultLang = locale.languageCode;
      if (locale.countryCode.length > 0) {
        defaultLang += "-" + locale.countryCode;
      }
    }
    final localeBase = LocaleBase();
    // await localeBase.load(idMap[defaultLang]);
    await localeBase.load(_languages[defaultLang].translationFilePath);
    return localeBase;
  }

  @override
  bool shouldReload(LocaleDelegate old) => false;

  /// for MaterialApp widget parameters
  static Iterable<LocalizationsDelegate<dynamic>> getLocalizationsDelegates() {
    return [
      LocaleDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
  }

  /// for MaterialApp widget parameters
  static Iterable<Locale> getSupportedLocales() {
    return _languages.values.map((language) {
      return language.locale;
    }).toList(growable: false);
  }

  /// get the device locale.
  /// revert to 'en-US' if device locale is not supported
  static Locale getDeviceLocale() {
    var deviceLocale = window.locale;
    var defaultLang = 'en-US';

    var searchSupportedLocale = getSupportedLocales().firstWhere((thisLocale) {
      return (thisLocale.languageCode == deviceLocale.languageCode);
    }, orElse: () => null);

    if (searchSupportedLocale != null) {
      return searchSupportedLocale;
    } else {
      return _languages[defaultLang].locale;
    }
  }

  /// get the list of languages setup in this app
  static List<Language> getLanguagesList() {
    return _languages.values.toList(growable: false);
  }

  /// get the Hashmap of [_languages] setup in this app
  static Map<String, Language> getLanguagesMap() {
    return _languages;
  }

  /// get [Language] by localekey, which is the key
  /// in [_languages] HashMap
  static Language getLanguageByLocaleKey(String localeKey) {
    return _languages[localeKey];
  }

  /// get [Language] by localName
  static Language getLanguageByLocalName(String localName) {
    Language language;
    if (localName != null) {
      language = getLanguagesList().firstWhere((lang) {
        return localName == lang.localName;
      });
    }

    return language;
  }

  /// renders a template like "Name is {} and age is {}" for given arguments
  /// * taken from easy_localization package
  /// * source: https://pub.dev/packages/easy_localization
  static String render(String template, {List<String> args}) {
    if (template == null) return '';

    String result = template;
    if (args != null) {
      args.forEach((String str) {
        result = result.replaceFirst(RegExp(r'{}'), str);
      });
    } else {
      result = template.replaceAll('{}', '');
    }
    return result;
  }
}

/// Class to hold language data to be used by Locale system
/// as well as the UI
class Language {
  @required
  String localeKey;
  String name;
  String localName;
  String languageCode;
  String countryCode;
  String translationFilePath;
  String flagFilePath;

  Language({
    @required this.localeKey,
    @required this.name,
    @required this.localName,
    @required this.languageCode,
    @required this.countryCode,
    @required this.translationFilePath,
    this.flagFilePath,
  });

  Locale get locale {
    return Locale(languageCode, countryCode);
  }
}
