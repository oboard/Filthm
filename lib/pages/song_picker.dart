import 'dart:convert';
import 'dart:io';

import 'package:filthm/cool_route.dart';
import 'package:filthm/main.dart';
import 'package:filthm/model/beatmap.dart';
import 'package:filthm/pages/game/game_page.dart';
import 'package:filthm/setting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/button.dart';

class SongPickerPage extends StatefulWidget {
  const SongPickerPage({super.key, required this.beatmapModel});

  final BeatmapModel beatmapModel;

  @override
  State<SongPickerPage> createState() => _SongPickerPageState();
}

class _SongPickerPageState extends State<SongPickerPage> {
  List<BeatmapModel> subList = [];
  int selectedIndex = 0, selectedJudge = 0;
  String previewImagePath = '';

  void recursionFile(String pathName) {
    Directory dir = Directory(pathName);

    if (!dir.existsSync()) {
      return;
    }

    List<FileSystemEntity> lists = dir.listSync();
    for (FileSystemEntity entity in lists) {
      if (entity is File) {
        File file = entity;
        if (file.path.endsWith('.milthm')) {
          BeatmapModel beatmapModel =
              BeatmapModel.fromJson(jsonDecode(file.readAsStringSync()));
          beatmapModel.dirPath = pathName;
          beatmapModel.filePath = file.path;
          subList.add(beatmapModel);
          setState(() {});
        }
      } else if (entity is Directory) {
        Directory subDir = entity;
        recursionFile(subDir.path);
      }
    }
  }

  @override
  void initState() {
    previewImagePath =
        '${widget.beatmapModel.dirPath}/${widget.beatmapModel.illustrationFile ?? ''}';
    recursionFile(widget.beatmapModel.dirPath);
    subList.sort((a, b) => (a.noteList.length).compareTo(b.noteList.length));
    setState(() {});
    gamePlayer
      ?..stop()
      ..setFilePath(
          '${widget.beatmapModel.dirPath}/${widget.beatmapModel.audioFile ?? ''}')
      ..setLoopMode(LoopMode.one)
      ..play();
    super.initState();
  }

  @override
  void dispose() {
    loadMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 64),
              decoration: BoxDecoration(
                borderRadius: GameSettings.borderRadius,
                color: colorScheme.background,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Hero(
                      tag: widget.beatmapModel.filePath,
                      child: ClipRRect(
                        borderRadius: GameSettings.borderRadius,
                        child: Image.file(
                          File(previewImagePath),
                          fit: BoxFit.cover,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.beatmapModel.title ?? '',
                            style: const TextStyle(fontSize: 32),
                          ),
                          Text(
                              '[曲]${widget.beatmapModel.composer} [谱]${widget.beatmapModel.beatmapper} [美]${widget.beatmapModel.illustrator}'),
                          const Text('From Re / Osu!Mania'),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: subList.length,
                              itemBuilder: (context, index) {
                                var item = subList[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: MyButton(
                                    onPressed: () {
                                      selectedIndex = index;
                                      previewImagePath =
                                          '${item.dirPath}/${item.illustrationFile ?? ''}';
                                      print(item);
                                      setState(() {});
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 16,
                                      ),
                                      decoration: (index == selectedIndex)
                                          ? BoxDecoration(
                                              borderRadius:
                                                  GameSettings.borderRadius,
                                              color:
                                                  colorScheme.primaryContainer,
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
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            )
                                          : BoxDecoration(
                                              borderRadius:
                                                  GameSettings.borderRadius,
                                              color: const Color(0x11000000),
                                            ),
                                      child: Text('${item.difficulty}'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '判定 ',
                                      style: TextStyle(
                                        color: colorScheme.onBackground
                                            .withOpacity(0.6),
                                        fontSize: 16,
                                      ),
                                    ),
                                    DropdownButton<int>(
                                      value: selectedJudge,
                                      underline: const SizedBox(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: colorScheme.onBackground),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0, child: Text('宽松')),
                                        DropdownMenuItem(
                                            value: 1, child: Text('普通')),
                                        DropdownMenuItem(
                                            value: 2, child: Text('严格')),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedJudge = value ?? 0;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                MyButton(
                                  onPressed: () {
                                    gamePlayer?.stop();
                                    Navigator.of(context).maybePop();
                                    Navigator.of(context).push(
                                      CoolRoute(
                                        builder: (context) => GamePage(
                                            beatmap: subList[selectedIndex]),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
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
                                          color: Color.fromARGB(
                                              255, 231, 222, 255),
                                          blurRadius: 10,
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.play_arrow),
                                        SizedBox(
                                          width: 16,
                                        ),
                                        Text('开始')
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            MyButton.icon(
              onPressed: () {
                gamePlayer?.stop();
                Navigator.of(context).maybePop();
              },
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
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
                      color: Color.fromARGB(255, 231, 222, 255),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
