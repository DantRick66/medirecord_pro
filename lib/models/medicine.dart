import 'package:flutter/material.dart';

class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String form;
  final List<TimeOfDay> times;
  final List<String> daysOfWeek;
  final DateTime startDate;
  final bool isActive;
  final String? notes;
  final String colorHex;

  Medicine({
    this.id = '',
    required this.name,
    required this.dosage,
    required this.form,
    required this.times,
    required this.daysOfWeek,
    required this.startDate,
    this.isActive = true,
    this.notes,
    required this.colorHex,
  });

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  Medicine copyWith({String? id}) {
    return Medicine(
      id: id ?? this.id,
      name: name,
      dosage: dosage,
      form: form,
      times: times,
      daysOfWeek: daysOfWeek,
      startDate: startDate,
      isActive: isActive,
      notes: notes,
      colorHex: colorHex,
    );
  }
}
