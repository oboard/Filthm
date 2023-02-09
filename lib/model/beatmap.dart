import 'dart:convert';
import 'dart:io';

import 'package:filthm/utils/luid_util.dart';
import 'dart:math' as math;

class BPMData {
  double from = 0, to = 0;
  double bpm = 60;
}

class NoteData {
  int line = 0;
  List<int> from = [], to = [];
  int bpm = 60;
  double get fromBeat {
    return from[0] + from[1] * 1.0 / from[2];
  }

  double get toBeat {
    return to[0] + to[1] * 1.0 / to[2];
  }
}

enum LineDirection {
  left,
  right,
  up,
  down,
}

class LineData {
  LineDirection? direction;
  double? flowSpeed;
}

enum PerformanceOperation {
  move,
  rotate,
  transparent,
  changeDirection,
  changeKey,
  flowSpeed,
}

enum PerformanceEaseType {
  linear,
  bezierEaseIn,
  bezierEaseOut,
  bezierEase,
  parabolicEase,
}

class PerformanceData {
  double? from, to;
  int? line, note;
  PerformanceOperation? operation;
  String? value;
  PerformanceEaseType? ease;
}

class BeatmapModel {
  String? title;
  String? composer;
  String? illustrator;
  String? beatmapper;
  String? beatmapUID = Luid().v1();
  String? difficulty;
  double? difficultyValue;
  String? audioFile;
  String? illustrationFile;
  String? source;
  String? gameSource;
  double? previewTime = -1;
  double? songLength = 0;

  List<BPMData> bpmList = [];

  List<NoteData> noteList = [];

  List<LineData> lineList = [];

  List<PerformanceData> performanceList = <PerformanceData>[];

  BeatmapModel({
    this.title,
    this.composer,
    this.illustrator,
    this.beatmapper,
    this.beatmapUID,
    this.difficulty,
    this.difficultyValue,
    this.audioFile,
    this.illustrationFile,
    this.source,
    this.gameSource,
    this.previewTime,
    this.songLength,
  });

  void export(String path) {
    File file = File(path);
    file.writeAsString(jsonEncode(toJson()));
  }

  int determineBPM(double time) {
    if (bpmList.length == 1) {
      return 0;
    } else {
      return bpmList.indexWhere((x) => x.from <= time && x.to >= time);
    }
  }

  List<int> convertByBPM(double time, int beat) {
    BPMData bpmData = bpmList[determineBPM(time)];
    double beatTime = 60 / (bpmData.bpm);
    int basebeat = (time - (bpmData.from) / beatTime).round();
    return [
      basebeat,
      ((time - (bpmData.from) - basebeat * beatTime) / (beatTime / beat))
          .round(),
      beat
    ];
  }

  List<double> toRealTime(NoteData note) {
    return [
      bpmList[note.bpm].from + note.fromBeat * (60.0 / bpmList[note.bpm].bpm),
      bpmList[note.bpm].from + note.toBeat * (60 / bpmList[note.bpm].bpm)
    ];
  }

  static BeatmapModel read(String path) {
    return BeatmapModel.fromJson(jsonDecode(File(path).readAsStringSync()));
  }

  double bezierCubic(double t, double a, double b, double c, double d) {
    return (a * math.pow(1 - t, 3)) +
        (3 * b * t * math.pow(1 - t, 2)) +
        (3 * c * (1 - t) * math.pow(t, 2)) +
        (d * math.pow(t, 3));
  }

  BeatmapModel.fromJson(Map<String, dynamic>? json) {
    title = json?['title'];
    composer = json?['composer'];
    illustrator = json?['illustrator'];
    beatmapper = json?['beatmapper'];
    beatmapUID = json?['beatmapUID'];
    difficulty = json?['difficulty'];
    difficultyValue = json?['difficultyValue'];
    audioFile = json?['audioFile'];
    illustrationFile = json?['illustrationFile'];
    source = json?['source'];
    gameSource = json?['gameSource'];
    previewTime = json?['previewTime'];
    songLength = json?['songLength'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['composer'] = composer;
    data['illustrator'] = illustrator;
    data['beatmapper'] = beatmapper;
    data['beatmapUID'] = beatmapUID;
    data['difficulty'] = difficulty;
    data['difficultyValue'] = difficultyValue;
    data['audioFile'] = audioFile;
    data['illustrationFile'] = illustrationFile;
    data['source'] = source;
    data['gameSource'] = gameSource;
    data['previewTime'] = previewTime;
    data['songLength'] = songLength;
    return data;
  }
}
