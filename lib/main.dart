import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicplayerv2/CustomWidgets/gradient_containers.dart';
import 'package:musicplayerv2/CustomWidgets/miniplayer.dart';
import 'package:musicplayerv2/Helpers/config.dart';
import 'package:musicplayerv2/Helpers/handle_native.dart';
import 'package:musicplayerv2/Services/audio_service.dart';
import 'package:musicplayerv2/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'Screens/player/audioplayer.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("[Firebase Messaging] Background message data: ${message.data}");
  print(
      "[Firebase Messaging] Background message title: ${message.notification!.title}");
  print(
      "[Firebase Messaging] Background message body: ${message.notification!.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  await Hive.initFlutter();
  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);
  if (Platform.isAndroid) {
    setOptimalDisplayMode();
  }
  await startService();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(const MyApp());
}

Future<void> startService() async {
  final AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.example.musicplayerv2.channel.audio',
      androidNotificationChannelName: 'musicplayerv2',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      // androidStopForegroundOnPause: Hive.box('settings')
      // .get('stopServiceOnPause', defaultValue: true) as bool,
      notificationColor: Colors.grey[900],
    ),
  );
  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

Future<void> setOptimalDisplayMode() async {
  final List<DisplayMode> supported = await FlutterDisplayMode.supported;
  final DisplayMode active = await FlutterDisplayMode.active;

  final List<DisplayMode> sameResolution = supported
      .where(
        (DisplayMode m) => m.width == active.width && m.height == active.height,
      )
      .toList()
    ..sort(
      (DisplayMode a, DisplayMode b) => b.refreshRate.compareTo(a.refreshRate),
    );

  final DisplayMode mostOptimalMode =
      sameResolution.isNotEmpty ? sameResolution.first : active;

  await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');
  // This widget is the root of your application.
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callIntent();

    _locale = Locale('en');

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });
    final String lang =
        Hive.box('settings').get('lang', defaultValue: 'English') as String;
  }

  Future<void> callIntent() async {
    await NativeMethod.handleIntent();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.themeMode == ThemeMode.dark
            ? Colors.black38
            : Colors.white,
        statusBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'musicplayerv2',
      restorationScopeId: 'musicplayerv2',
      debugShowCheckedModeBanner: false,
      themeMode: AppTheme.themeMode,
      theme: AppTheme.lightTheme(
        context: context,
      ),
      locale: _locale,
      darkTheme: AppTheme.darkTheme(
        context: context,
      ),
      home: const MyHomePage(),
    );
  }
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    final File dbFile = File('$dirPath/$boxName.hive');
    final File lockFile = File('$dirPath/$boxName.lock');
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initSub();
  }

  initSub() async {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        setState(() {
          data = "";
          data += "body: ${message.notification!.body}\n";
          data += "title: ${message.notification!.title}\n";
          data += "data: ${message.data}\n";
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notification_important_rounded, size: 64),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  message.notification!.title.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  message.notification!.body.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String data = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Text(data),
              ),
              const MiniPlayer(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String? token = await FirebaseMessaging.instance.getToken();
          print('token: $token');
          FirebaseMessaging.instance.subscribeToTopic('test');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
