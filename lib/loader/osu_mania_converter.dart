import 'dart:io';

import 'package:filthm/model/beatmap.dart';

class OsuManiaConverter {
  static bool convert(String path, String file, {double flowSpeed = 9.0}) {
    List<String> data = File(file).readAsStringSync().split(RegExp(r'\n|\r'));
    bool start = false;

    BeatmapModel model = BeatmapModel()
      ..difficultyValue = -1
      ..illustrator = "Unknown"
      ..gameSource = "Osu!Mania"
      ..songLength = -1;

    bool readBg = false;
    int lineCount = 4;
    for (String line in data) {
      if (line == "[HitObjects]") {
        break;
      }

      if (line.startsWith("TitleUnicode:")) {
        model.title = line.split(':')[1];
      }

      if (line.startsWith("ArtistUnicode:")) {
        model.composer = line.split(':')[1];
      }

      if (line.startsWith("Creator:")) {
        model.beatmapper = line.split(':')[1];
      }

      if (line.startsWith("Source:")) {
        model.source = line.split(':')[1];
      }

      if (line.startsWith("Version:")) {
        model.difficulty = line.split(':')[1];
      }

      if (line.startsWith("AudioFilename:")) {
        model.audioFile = line.split(':')[1].trim();
      }

      if (line.startsWith("BeatmapID:")) {
        model.beatmapUID = "Osu!Mania-${line.split(':')[1]}";
      }

      if (line.startsWith("PreviewTime:")) {
        model.previewTime =
            (int.tryParse(line.split(':')[1].trim()) ?? 1) / 1000;
      }

      if (line.startsWith("CircleSize")) {
        lineCount = int.tryParse(line.split(':')[1].trim()) ?? 0;
      }

      if (line == "[Events]") {
        readBg = true;
        continue;
      }

      if (!line.startsWith("//") && readBg && !line.startsWith("Video")) {
        readBg = false;
        model.illustrationFile = line.split('"')[1];
      }

      if (line.startsWith("Mode:")) {
        if (line.split(':')[1].trim() != "3") {
          return false;
        }
      }
    }

    model.bpmList.add(BPMData()
      ..bpm = 600.0
      ..from = 0
      ..to = 0);

    for (int i = 0; i < lineCount; i++) {
      model.lineList.add(LineData()
        ..direction = LineDirection.up
        ..flowSpeed = flowSpeed);
    }

    List<int> xs = [];
    for (String line in data) {
      if (start) {
        List<String> t = line.split(',');
        if (t.length == 6) {
          int l = int.tryParse(t[0]) ?? 0;
          if (!xs.contains(l)) {
            xs.add(l);
          }
        } else {
          continue;
        }
      }
      if (line == "[HitObjects]") start = true;
    }
    xs.sort((x, y) => x.compareTo(y));
    start = false;

    for (String line in data) {
      if (start) {
        List<String> t = line.split(',');
        double from = double.tryParse(t[2]) ?? 1 / 1000, to;
        if (t.length == 6) {
          int l = xs.indexWhere((x) => x == int.tryParse(t[0]));
          to = double.tryParse(t[5].split(':')[0]) ?? 0 / 1000;
          if (to == 0 || to <= from) {
            to = from;
          }
          model.noteList.add(NoteData()
            ..bpm = 0
            ..line = l
            ..from = model.convertByBPM(from, 100)
            ..to = model.convertByBPM(to, 100));
        } else {
          continue;
        }
      }
      if (line == "[HitObjects]") start = true;
    }

    model.export(path);

    return true;
  }
}
