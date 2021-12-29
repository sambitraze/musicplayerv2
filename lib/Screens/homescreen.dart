import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:musicplayerv2/CustomWidgets/gradient_containers.dart';
import 'package:musicplayerv2/CustomWidgets/miniplayer.dart';
import 'package:musicplayerv2/Models/audiobooks.dart';
import 'package:musicplayerv2/Screens/player/audioplayer.dart';
import 'package:musicplayerv2/Services/audiobook_service.dart';

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

  List<AudioBook> audioBooks = [];
  bool loading = false;

  initSub() async {
    setState(() {
      loading = true;
    });
    audioBooks = await AudioBookService.getAudioBooks();
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
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
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GradientContainer(
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: audioBooks.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  opaque: false, // set to false
                                  pageBuilder: (_, __, ___) => PlayScreen(
                                    songsList: audioBooks
                                        .map((e) => {
                                              "id": e.audiolists.first.id,
                                              "album": e.name,
                                              "artist": e.reader.name,
                                              "title": e.audiolists.length
                                                  .toString(),
                                              "image": AudioBookService
                                                      .baseImageUrl +
                                                  e.cover,
                                              "genre": "English",
                                              "language": "English",
                                              "url": AudioBookService.baseImageUrl +
                                                  e.audiolists.first.file,
                                              "year":
                                                  e.dateCreated.year.toString(),
                                                  "duration": e.audiolists.first.hour * 3600 + e.audiolists.first.minutes*60  + e.audiolists.first.seconds,
                                              "release_date":
                                                  e.dateCreated.toString(),
                                              "subtitle": e.category,
                                              "album_id": e.id,
                                              "has_lyrics": false,
                                              "320kbps": false,
                                            })
                                        .toList(),
                                    index: 0,
                                    offline: false,
                                    fromDownloads: false,
                                    fromMiniplayer: false,
                                    recommend: false,
                                  ),
                                ),
                              );
                            },
                            title: Text(audioBooks[index].name),
                            subtitle: Text(audioBooks[index].description),
                          );
                        },
                      ),
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
