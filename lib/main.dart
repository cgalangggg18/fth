import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:farmm/localization/app_localizations.dart';
import 'package:farmm/providers/locale_provider.dart';
import 'package:farmm/providers/user_provider.dart';
import 'package:farmm/providers/farmer_registration_provider.dart';
import 'package:farmm/providers/logistics_registration_provider.dart';
import 'package:farmm/providers/bulk_buyer_registration_provider.dart';
import 'package:farmm/screens/language_selection_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FarmerRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => LogisticsRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => BulkBuyerRegistrationProvider()),
      ],
      child: const AgriGrowApp(),
    ),
  );
}

class AgriGrowApp extends StatelessWidget {
  const AgriGrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'AgriGrow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fil'),
        Locale('pam'),
      ],
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        const FallbackMaterialLocalizationsDelegate(),
        const FallbackWidgetsLocalizationsDelegate(),
        const FallbackCupertinoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LanguageSelectionScreen(),
    );
  }
}

class FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'pam';
  @override
  Future<MaterialLocalizations> load(Locale locale) => GlobalMaterialLocalizations.delegate.load(const Locale('fil'));
  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const FallbackWidgetsLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'pam';
  @override
  Future<WidgetsLocalizations> load(Locale locale) => GlobalWidgetsLocalizations.delegate.load(const Locale('fil'));
  @override
  bool shouldReload(FallbackWidgetsLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'pam';
  @override
  Future<CupertinoLocalizations> load(Locale locale) => GlobalCupertinoLocalizations.delegate.load(const Locale('fil'));
  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
