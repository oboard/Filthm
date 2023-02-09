import 'dart:convert';
import 'dart:io';

import 'package:animated_background/animated_background.dart';
import 'package:filthm/effect/rain_behavior.dart';
import 'package:filthm/loader/directory_create.dart';
import 'package:filthm/loader/path.dart';
import 'package:filthm/model/beatmap.dart' hide LineDirection;
import 'package:filthm/setting.dart';
import 'package:filthm/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'loader/picker.dart';

AudioPlayer? gamePlayer;

void main() {
  runApp(const Game());
}

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filthm',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

var menu = [
  Icons.music_note,
  Icons.cloud,
  Icons.edit_document,
  Icons.settings,
];

int pageIndex = 0;
List<BeatmapModel> songList = [BeatmapModel()];

class _HomeState extends State<Home> with TickerProviderStateMixin {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      //默认隐藏，若从边缘滑动会显示，过会儿会自动隐藏（安卓，iOS）
      SystemUiMode.immersiveSticky,
    );
    // 强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    gameLoad();
    super.initState();
  }

  var loaded = false;

  String gamePath = '';

  void recursionFile(String pathName) {
    Directory dir = Directory(pathName);

    if (!dir.existsSync()) {
      return;
    }

    List<FileSystemEntity> lists = dir.listSync();
    for (FileSystemEntity entity in lists) {
      if (entity is File) {
        File file = entity;
        if (file.path.endsWith('milthm')) {
          BeatmapModel beatmapModel =
              BeatmapModel.fromJson(jsonDecode(file.readAsStringSync()));
          beatmapModel.dirPath = pathName;
          beatmapModel.filePath = file.path;
          songList.add(beatmapModel);
          setState(() {});
        }
        print(file.path);
      } else if (entity is Directory) {
        Directory subDir = entity;
        recursionFile(subDir.path);
      }
    }
  }

  Future<void> gameLoad() async {
    await checkAndCreateImportDictory();
    gamePath = await getGamePath();

    songList.clear();
    recursionFile(gamePath);
    songList.add(BeatmapModel());

    if (!Platform.isMacOS) {
      gamePlayer = AudioPlayer();
      //发出提示音
      gamePlayer
        ?..setUrl('asset:///sounds/SongSelect.mp3')
        ..setLoopMode(LoopMode.one)
        ..play();
    }

    loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (!loaded) gameLoad();
        },
        child: Stack(
          children: [
            SizedBox.fromSize(
              size: size,
              child: const Image(
                image: AssetImage('images/songselect3.png'),
                fit: BoxFit.cover,
              ),
            ),
            AnimatedBackground(
              behaviour: RainBehavior(direction: LineDirection.Ttb),
              vsync: this,
              child: const SizedBox(),
            ),
            Row(
              children: [
                SizedBox(
                  width: 128,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Column(
                      children: [
                        for (IconData item in menu)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: MyButton.icon(
                              padding: EdgeInsets.zero,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: (pageIndex != menu.indexOf(item))
                                    ? null
                                    : const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xffe8effd),
                                            Color(0xffede8fc),
                                          ],
                                          begin: Alignment(0, 0),
                                          end: Alignment(1, 1),
                                        ),
                                        boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(
                                                  255, 231, 222, 255),
                                              blurRadius: 10,
                                            )
                                          ]),
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Icon(
                                    item,
                                    size: 32,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                pageIndex = menu.indexOf(item);
                                setState(() {});
                              },
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Image(
                        image: AssetImage('images/decoration_line.png'),
                        fit: BoxFit.contain,
                      ),
                      ListView.builder(
                        itemCount: songList.length,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        itemBuilder: (context, index) {
                          BeatmapModel beatmapModel = songList[index];
                          if (index == songList.length - 1) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 32,
                              ),
                              child: MyButton(
                                onPressed: () {
                                  pickSongFile().then((value) => gameLoad());
                                },
                                child: Container(
                                  height: size.height / 2,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 32,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: GameSettings.borderRadius,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xffe8effd),
                                          Color(0xffede8fc),
                                        ],
                                        begin: Alignment(0, 0),
                                        end: Alignment(1, 1),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x22000000),
                                          blurRadius: 20,
                                        )
                                      ]),
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Icon(
                                            Icons.star,
                                            size: 128,
                                          )
                                        ],
                                      ),
                                      const Expanded(
                                        child: Center(
                                          child: Text(
                                            '触摸此处/拖入\n导入谱面',
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Color(0xff75777e),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: const [
                                          Icon(
                                            Icons.star_purple500,
                                            size: 128,
                                            color: Color.fromARGB(100, 0, 0, 0),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Container(
                                height: size.height / 2,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 32,
                                ),
                                child: MyButton(
                                  onPressed: () => openSongMenu(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: GameSettings.borderRadius,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x22000000),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: GameSettings.borderRadius,
                                      child: Stack(
                                        children: [
                                          // Text(
                                          //     '${beatmapModel.dirPath}/${beatmapModel.illustrationFile ?? ''}'),
                                          Image.file(
                                            File(
                                                '${beatmapModel.dirPath}/${beatmapModel.illustrationFile ?? ''}'),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                          Column(
                                            children: [],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 64,
                                  right: 64,
                                  bottom: 16,
                                ),
                                child: Row(children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          beatmapModel.title ?? '',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          beatmapModel.beatmapper ?? '',
                                          style: const TextStyle(
                                              color: Color(0x66000000)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    beatmapModel.bpmList.length.toString(),
                                    style: const TextStyle(
                                        fontSize: 32, color: Color(0x66000000)),
                                  ),
                                ]),
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(0, size.height / 5),
                    child: const Image(
                      image: AssetImage('images/person.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  openSongMenu() {}
}
