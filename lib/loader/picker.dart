import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:filthm/loader/directory_create.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/luid_util.dart';
import 'osu_mania_converter.dart';

Future<void> pickSongFile() async {
  await checkAndCreateImportDictory();

  const XTypeGroup typeGroup = XTypeGroup(
    label: 'songs',
    extensions: <String>['osz', 'mcz'], // 支持的文件
  );

  XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
  // 从磁盘读取Zip文件。
  Uint8List? bytes = await file?.readAsBytes();
  if (bytes == null) {
    return;
  } else {
    await archiveToImports(bytes);
  }
}

Future<void> archiveToImports(bytes) async {
  String id = Luid().v1();
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  // 解码Zip文件
  Archive archive = ZipDecoder().decodeBytes(bytes);
// 将Zip存档的内容解压缩到磁盘。
  for (ArchiveFile file in archive) {
    if (file.isFile) {
      List<int> data = file.content;
      File('$appDocPath/milthm/imports/$id/${file.name}')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
      if (file.name.toLowerCase().endsWith(".osu")) {
        String mode = File('$appDocPath/milthm/imports/$id/${file.name}')
            .readAsStringSync()
            .split("[General]")[1]
            .split("[Editor]")[0]
            .split("Mode:")[1]
            .split('\n')[0]
            .toString()
            .replaceAll("\r", "")
            .trim();
        if (mode == "3") {
          // Osu!Mania
          await importOsuMania('$appDocPath/milthm/imports/$id');
          break;
        }
      } else if (file.name.toLowerCase().endsWith(".milthm")) {
        break;
      }
    } else {
      await Directory('$appDocPath/milthm/imports/$id/${file.name}')
          .create(recursive: true);
    }
  }
}

Future<void> importOsuMania(String path) async {
  for (var f in Directory(path).listSync()) {
    if (f.path.toLowerCase().endsWith(".osu")) {
      await OsuManiaConverter.convert(path, f.path);
      await File(f.path).delete();
    }
  }
}
