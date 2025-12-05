import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final dbPath = await databaseFactory.getDatabasesPath();
      final path = join(dbPath, 'medirecord.db');
      _database = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ),
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'medirecord.db');
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }

    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medicines (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        form TEXT NOT NULL,
        times TEXT NOT NULL,
        daysOfWeek TEXT NOT NULL,
        startDate TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        colorHex TEXT NOT NULL
      )
    ''');
  }

  Future<Medicine> saveMedicine(Medicine medicine) async {
    final db = await instance.database;
    final id = medicine.id.isEmpty ? const Uuid().v4() : medicine.id;

    await db.insert(
      'medicines',
      {
        'id': id,
        'name': medicine.name,
        'dosage': medicine.dosage,
        'form': medicine.form,
        'times': medicine.times.map((t) => '${t.hour}:${t.minute}').join(','),
        'daysOfWeek': medicine.daysOfWeek.join(','),
        'startDate': medicine.startDate.toIso8601String(),
        'isActive': medicine.isActive ? 1 : 0,
        'notes': medicine.notes,
        'colorHex': medicine.colorHex,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return medicine.copyWith(id: id);
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await instance.database;
    final maps =
        await db.query('medicines', where: 'isActive = ?', whereArgs: [1]);

    return maps
        .map((map) => Medicine(
              id: map['id'] as String,
              name: map['name'] as String,
              dosage: map['dosage'] as String,
              form: map['form'] as String,
              times: (map['times'] as String)
                  .split(',')
                  .map((t) => TimeOfDay(
                        hour: int.parse(t.split(':')[0]),
                        minute: int.parse(t.split(':')[1]),
                      ))
                  .toList(),
              daysOfWeek: (map['daysOfWeek'] as String).split(','),
              startDate: DateTime.parse(map['startDate'] as String),
              isActive: (map['isActive'] as int) == 1,
              notes: map['notes'] as String?,
              colorHex: map['colorHex'] as String,
            ))
        .toList();
  }

  Future<void> deleteMedicine(String id) async {
    final db = await instance.database;
    await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
  }
}
