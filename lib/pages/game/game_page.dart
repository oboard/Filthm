import 'dart:io';
import 'dart:ui';

import 'package:filthm/model/beatmap.dart';
import 'package:flutter/material.dart' hide Route;

import 'game_overlay.dart';

int state = 0;

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.beatmap});
  final BeatmapModel beatmap;
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int maxCol = 0;

  countData() {
    for (var note in widget.beatmap.noteList) {
      if (note.line > maxCol) maxCol = note.line;
    }
    print(maxCol);
  }

  @override
  void initState() {
    state = 0;
    countData();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var beatmap = widget.beatmap;
    return Material(
      type: MaterialType.transparency,
      child: Hero(
        tag: beatmap.filePath,
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
                  child: Row(
                    children: List.generate(
                      maxCol + 1,
                      (index) => Expanded(
                        child: Column(
                          children: [
                            // Text('$index'),
                            Expanded(
                              child: Container(
                                width: 4,
                                color: Colors.grey,
                              ),
                            ),
                            Listener(
                              onPointerDown: (event) {},
                              child: Container(
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
                            ),
                          ],
                        ),
                      ),
                    ),
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
