import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MyDb {
  late Database db;

  Future open() async {
    // Get a location using getDatabasesPath
    final databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'kittyburger.db');

    //join is from path package
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table

      await db.execute("CREATE TABLE IF NOT EXISTS tb_users(" +
          "user_name VARCHAR (100)" +
          ")");
    });
  }
}
