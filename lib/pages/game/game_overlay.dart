import 'package:filthm/cool_route.dart';
import 'package:filthm/hit_judge.dart';
import 'package:filthm/main.dart';
import 'package:filthm/model/beatmap.dart';
import 'package:filthm/pages/game/game_canvas.dart';
import 'package:filthm/pages/game/game_page.dart';
import 'package:filthm/widgets/button.dart';
import 'package:flutter/material.dart';

int score = 0;
double percent = 0.00;

class GameOverlay extends StatefulWidget {
  const GameOverlay({super.key, required this.beatmapModel});
  final BeatmapModel beatmapModel;
  @override
  State<GameOverlay> createState() => _GameOverlayState();
}

class _GameOverlayState extends State<GameOverlay> {
  countScore() {
    percent = (gamePlayer?.position.inMilliseconds ?? 0) /
        (gamePlayer?.duration?.inMilliseconds ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyButton.icon(
              padding: EdgeInsets.zero,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x44444444),
                ),
                child: const Icon(
                  Icons.pause,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              onPressed: () {
                state = 1;
                gamePlayer?.pause();

                setState(() {});
              },
            ),
            Text(
              '${HitJudge.result.combo} COMBO',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            Column(
              children: [
                Text(
                  score.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                ),
                Text(
                  '${percent.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: Color(0x44000000),
                    fontSize: 16,
                  ),
                )
              ],
            )
          ],
        ),
        AnimatedCrossFade(
          firstChild: Stack(),
          secondChild: Stack(
            children: [
              Container(
                color: const Color(0x44000000),
              ),
              if (state == 1)
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 32,
                    spacing: 32,
                    children: [
                      MyButton.icon(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(16),
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
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 32,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                      ),
                      MyButton.icon(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 187, 0),
                                Color.fromARGB(255, 255, 149, 0),
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
                          child: const Icon(
                            Icons.restart_alt,
                            size: 32,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(CoolRoute(
                            builder: (context) => GamePage(
                              beatmap: widget.beatmapModel,
                            ),
                          ));
                        },
                      ),
                      MyButton.icon(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 170, 156, 255),
                                Color.fromARGB(255, 215, 140, 255),
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
                          child: const Icon(
                            Icons.play_arrow_outlined,
                            size: 32,
                          ),
                        ),
                        onPressed: () {
                          state = 0;
                          gamePlayer?.play();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
          crossFadeState: CrossFadeState.values[state],
          duration: const Duration(milliseconds: 500),
        ),
        if (state == 0)
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              widthFactor: 0.8,
              child: Stack(
                children: [
                  Row(
                    children: List.generate(
                      maxCol + 1,
                      (index) => Expanded(
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (event) {
                            print('66');
                            double currentBPos =
                                getCurrentBPos(widget.beatmapModel);
                            pressing[index] = currentBPos;
                            setState(() {});
                            NoteData? closestNote =
                                getClosetNote(widget.beatmapModel, index);
                            print(closestNote?.snd);
                            if (closestNote == null) return;
                            HitJudge.judge(
                                (closestNote.from[0] - currentBPos) / 10000,
                                closestNote.snd);
                            closestNote.judged = true;
                          },
                          onPointerUp: (event) {
                            pressing[index] = 0;
                            setState(() {});
                          },
                          child: Column(
                            children: [
                              // Text('$index'),
                              Expanded(
                                child: Container(),
                              ),
                              Container(
                                height: 64,
                                width: 64,
                                // decoration: BoxDecoration(
                                //   shape: BoxShape.circle,
                                //   color: null,
                                //   // boxShadow: [
                                //   //   if (pressing[index]) ...[
                                //   //     const BoxShadow(
                                //   //       color: Colors.black,
                                //   //       blurRadius: 16,
                                //   //     ),
                                //   //   ],
                                //   // ],
                                //   // border: Border.all(
                                //   //   width: 4,
                                //   //   color: Colors.black45,
                                //   // ),
                                // ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

NoteData? getClosetNote(BeatmapModel beatmap, int index) {
  int pos1 = 0;
  double bpos = getCurrentBPos(beatmap);

  NoteData? last = beatmap.noteList[0];
  for (var note in beatmap.noteList) {
    if (pos1 == 0) {
      if (note.from[0] > bpos && note.line == index) {
        if (last != null) {
          if ((last.from[0] - bpos).abs() < (note.from[0] - bpos).abs()) {
            return last;
          }
        }
        return note;
      }
      if (note.line == index) last = note;
    }
  }
  return null;
}
