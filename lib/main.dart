import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:wrld999/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path_provider/path_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:wrld999/Helpers/config.dart';
import 'package:wrld999/Helpers/countrycodes.dart';
import 'package:wrld999/Helpers/handle_native.dart';
import 'package:wrld999/Helpers/import_export_playlist.dart';
import 'package:wrld999/Helpers/logging.dart';
import 'package:wrld999/Helpers/route_handler.dart';
import 'package:wrld999/Screens/About/about.dart';
import 'package:wrld999/Screens/Home/home.dart';
import 'package:wrld999/Screens/Library/downloads.dart';
import 'package:wrld999/Screens/Library/nowplaying.dart';
import 'package:wrld999/Screens/Library/playlists.dart';
import 'package:wrld999/Screens/Library/recent.dart';
import 'package:wrld999/Screens/Library/stats.dart';
import 'package:wrld999/Screens/Login/auth.dart';
import 'package:wrld999/Screens/Login/pref.dart';
import 'package:wrld999/Screens/Player/audioplayer.dart';
import 'package:wrld999/Screens/Settings/new_settings_page.dart';
import 'package:wrld999/Services/audio_service.dart';
import 'package:wrld999/theme/app_theme.dart';

Future<void> main() async {
  await runZonedGuarded(_appMain, (error, stack) {
    Logger.root.severe('Unhandled zone error', error, stack);
  });
}

Future<void> _appMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ytdl_hook.lua is embedded in system libmpv (mpv 0.41.0). It intercepts
  // YouTube CDN URLs and tries to run yt-dlp, which is not installed, causing
  // stream open failure. Disable it before libmpv is initialized.
  if (Platform.isLinux) {
    await _disableMpvYtdlHook();
  }
  JustAudioMediaKit.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter('wrld999');
  } else {
    await Hive.initFlutter();
  }
  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('stats');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);
  await openHiveBox('ytlinkcache', limit: true);
  if (Platform.isAndroid) {
    setOptimalDisplayMode();
  }
  await startService();
  runApp(MyApp());
}

Future<void> setOptimalDisplayMode() async {
  await FlutterDisplayMode.setHighRefreshRate();
  // final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  // final DisplayMode active = await FlutterDisplayMode.active;

  // final List<DisplayMode> sameResolution = supported
  //     .where(
  //       (DisplayMode m) => m.width == active.width && m.height == active.height,
  //     )
  //     .toList()
  //   ..sort(
  //     (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
  //   );

  // final DisplayMode mostOptimalMode =
  //     sameResolution.isNotEmpty ? sameResolution.first : active;

  // await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

Future<void> _disableMpvYtdlHook() async {
  try {
    final configDir = Directory(
      '${Platform.environment['XDG_CONFIG_HOME'] ?? '${Platform.environment['HOME']}/.config'}/mpv',
    );
    await configDir.create(recursive: true);
    final configFile = File('${configDir.path}/mpv.conf');
    final existing = configFile.existsSync() ? await configFile.readAsString() : '';
    if (!existing.contains('ytdl=no')) {
      await configFile.writeAsString(
        existing.isEmpty ? 'ytdl=no\n' : '$existing\nytdl=no\n',
      );
    }
  } catch (e) {
    debugPrint('Could not disable MPV ytdl_hook: $e');
  }
}

Future<void> startService() async {
  await initializeLogging();
  await MetadataGod.initialize();
  final AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.shadow.wrld999.channel.audio',
      androidNotificationChannelName: 'wrld999',
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      androidStopForegroundOnPause: false,
      // Hive.box('settings').get('stopServiceOnPause', defaultValue: true) as bool,
      notificationColor: Colors.grey[900],
    ),
  );
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    Logger.root.severe('Failed to open $boxName Box', error, stackTrace);
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/wrld999/$boxName.hive');
      lockFile = File('$dirPath/wrld999/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  // ignore: unreachable_from_main
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  late StreamSubscription _intentDataStreamSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final Box settingsBox = Hive.box('settings');
    final String? savedLang = settingsBox.get('lang') as String?;

    if (savedLang != null && ConstantCodes.languageCodes.containsKey(savedLang)) {
      _locale = Locale(ConstantCodes.languageCodes[savedLang]!);
    } else {
      final Locale systemLocale =
          WidgetsBinding.instance.platformDispatcher.locale;
      final String systemLangCode = systemLocale.languageCode;
      final String systemCountryCode = systemLocale.countryCode ?? '';

      if (systemCountryCode.toUpperCase() == 'KZ') {
        _locale = const Locale('ru');
        settingsBox.put('lang', 'Russian');
      } else if (ConstantCodes.languageCodes.values.contains(systemLangCode)) {
        _locale = Locale(systemLangCode);
      } else {
        _locale = const Locale('en');
      }
    }

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });

    if (Platform.isAndroid || Platform.isIOS) {
      void handleSharedFiles(List<SharedMediaFile> value) {
        for (final file in value) {
          if (file.type == SharedMediaType.text ||
              file.type == SharedMediaType.url) {
            Logger.root.info('Received intent text/url: ${file.path}');
            handleSharedText(file.path, navigatorKey);
          } else if (file.path.endsWith('.json')) {
            final List playlistNames = Hive.box('settings')
                    .get('playlistNames')
                    ?.toList() as List? ??
                ['Favorite Songs'];
            importFilePlaylist(
              null,
              playlistNames,
              path: file.path,
              pickFile: false,
            ).then(
              (value) => navigatorKey.currentState?.pushNamed('/playlists'),
            );
          }
        }
      }

      // For sharing coming from outside the app while the app is in the memory
      _intentDataStreamSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> value) {
          if (value.isNotEmpty) handleSharedFiles(value);
        },
        onError: (err) {
          Logger.root.severe('ERROR in getDataStream', err);
        },
      );

      // For sharing coming from outside the app while the app is closed
      ReceiveSharingIntent.instance
          .getInitialMedia()
          .then((List<SharedMediaFile> value) {
        if (value.isNotEmpty) handleSharedFiles(value);
      });
    }
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Widget initialFuntion() {
    return Hive.box('settings').get('userId') != null
        ? HomePage()
        : AuthScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: AppTheme.themeMode == ThemeMode.system
            ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                ? Brightness.light
                : Brightness.dark
            : AppTheme.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
        systemNavigationBarIconBrightness:
            AppTheme.themeMode == ThemeMode.system
                ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                    ? Brightness.light
                    : Brightness.dark
                : AppTheme.themeMode == ThemeMode.dark
                    ? Brightness.light
                    : Brightness.dark,
      ),
      child: MaterialApp(
        title: 'wrld999',
        restorationScopeId: 'wrld999',
        debugShowCheckedModeBanner: false,
        themeMode: AppTheme.themeMode,
        theme: AppTheme.lightTheme(
          context: context,
        ),
        darkTheme: AppTheme.darkTheme(
          context: context,
        ),
        locale: _locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: ConstantCodes.languageCodes.entries
            .map((languageCode) => Locale(languageCode.value, ''))
            .toList(),
        routes: {
          '/': (context) => initialFuntion(),
          '/pref': (context) => const PrefScreen(),
          '/setting': (context) => const NewSettingsPage(),
          '/about': (context) => AboutScreen(),
          '/playlists': (context) => PlaylistScreen(),
          '/nowplaying': (context) => NowPlaying(),
          '/recent': (context) => RecentlyPlayed(),
          '/downloads': (context) => const Downloads(),
          '/stats': (context) => const Stats(),
        },
        navigatorKey: navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          if (settings.name == '/player') {
            return PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => const PlayScreen(),
            );
          }
          return HandleRoute.handleRoute(settings.name);
        },
      ),
    );
  }
}
