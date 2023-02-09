import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> checkAndCreateImportDictory() async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  if (!Directory('$appDocPath/milthm').existsSync()) {
    await Directory('$appDocPath/milthm').create();
  }
  if (!Directory('$appDocPath/milthm/imports').existsSync()) {
    await Directory('$appDocPath/milthm/imports').create();
  }
}
