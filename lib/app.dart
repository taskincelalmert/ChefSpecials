import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';

class ChefSpecialsApp extends StatefulWidget {
  const ChefSpecialsApp({super.key});

  @override
  State<ChefSpecialsApp> createState() => _ChefSpecialsAppState();
}

class _ChefSpecialsAppState extends State<ChefSpecialsApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen(_handleIncomingLink);
  }

  void _handleIncomingLink(Uri uri) {
    String? recipeId;

    if (uri.scheme == 'https') {
      final segs = uri.pathSegments;
      if (segs.length >= 2 && segs[0] == 'recipe') recipeId = segs[1];
    } else if (uri.scheme == 'chefspecials') {
      // chefspecials://recipe/ID → host=recipe, pathSegments=[ID]
      final segs = uri.pathSegments;
      if (uri.host == 'recipe' && segs.isNotEmpty) recipeId = segs[0];
    }

    if (recipeId != null) {
      // Home'a gidip sonra tarifi push'la — böylece back butonu her zaman çalışır
      router.go('/home');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        router.push('/recipe/$recipeId');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'ChefSpecials',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      highContrastTheme: AppTheme.highContrastLightTheme,
      highContrastDarkTheme: AppTheme.highContrastDarkTheme,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final scale = mq.textScaler.scale(1.0).clamp(0.8, 1.3);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
      routerConfig: router,
    );
  }
}
