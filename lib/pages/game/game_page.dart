import 'dart:io';
import 'dart:ui';

import 'package:filthm/main.dart';
import 'package:filthm/model/beatmap.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:just_audio/just_audio.dart';

import 'game_canvas.dart';
import 'game_overlay.dart';

int state = 0;
int startTime = 0;
int maxCol = 0;
List<double> xs = [];
List<double> pressing = [];

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.beatmap});
  final BeatmapModel beatmap;
  @override
  State<GamePage> createState() => _GamePageState();
}

int getCurrentTime() {
  return DateTime.now().millisecondsSinceEpoch;
}

class _GamePageState extends State<GamePage> {
  countData() {
    maxCol = 0;
    forceStop = false;
    startTime = getCurrentTime();
    for (var note in widget.beatmap.noteList) {
      if (note.line > maxCol) maxCol = note.line;
    }
    pressing = List.generate(maxCol + 1, (index) => 0);
    print(maxCol);
  }

  refresh() {
    Future.delayed(const Duration(milliseconds: 5)).then((value) {
      if (forceStop) return;
      if (mounted && state == 0) setState(() {});
      refresh();
    });
  }

  @override
  void initState() {
    state = 0;
    countData();
    gamePlayer
      ?..stop()
      ..setFilePath(
          '${widget.beatmap.dirPath}/${widget.beatmap.audioFile ?? ''}')
      ..setLoopMode(LoopMode.off)
      ..play();

    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    var beatmap = widget.beatmap;
    return WillPopScope(
      onWillPop: () async {
        forceStop = true;
        gamePlayer?.stop();
        return true;
        // return false;
      },
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Image.file(
              File('${beatmap.dirPath}/${beatmap.illustrationFile ?? ''}'),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
                color:
                    Theme.of(context).colorScheme.background.withOpacity(0.8)),
            Align(
              alignment: Alignment.topCenter,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: FractionallySizedBox(
                  heightFactor: 0.9,
                  widthFactor: 0.8,
                  child: Stack(
                    children: [
                      Row(
                        children: List.generate(
                          maxCol + 1,
                          (index) => Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Column(
                                  children: [
                                    // Text('$index'),
                                    Expanded(
                                      child: Container(
                                        width: 4,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Container(
                                      height: 64,
                                      width: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          width: 4,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (pressing[index] != 0)
                                  Container(
                                    width: 64,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(64),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color.fromARGB(56, 164, 108, 255),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                      GameCanvas(
                        beatmap: beatmap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GameOverlay(
              beatmapModel: widget.beatmap,
            ),
          ],
        ),
      ),
    );
  }
}
