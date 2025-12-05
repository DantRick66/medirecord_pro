import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/medicine.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({Key? key, required this.medicine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(medicine.name,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor:
            Color(int.parse(medicine.colorHex.replaceFirst('#', '0xFF'))),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard('Información General', [
              _buildRow('Dosis', medicine.dosage),
              _buildRow('Forma', medicine.form),
              _buildRow('Notas', medicine.notes ?? 'Ninguna'),
            ]),
            const SizedBox(height: 20),
            _buildCard('Horarios y Frecuencia', [
              _buildRow('Horarios',
                  medicine.times.map((t) => t.format(context)).join(', ')),
              _buildRow('Días', medicine.daysOfWeek.join(', ')),
              _buildRow('Inicio',
                  medicine.startDate.toLocal().toString().split(' ')[0]),
            ]),
            const SizedBox(height: 20),
            _buildCard('Estadísticas (Dashboard)', [
              _buildRow('Dosis programadas', '120 (este mes)'),
              _buildRow('Adherencia', '85% (basado en logs)'),
              _buildRow('Próxima dosis', 'Hoy a las 18:00'),
              _buildRow('Dosis tomadas', '102 / 120'),
              _buildProgressBar('Adherencia', 0.85, Colors.green),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          color: color,
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text('${(value * 100).toInt()}%', style: GoogleFonts.poppins()),
      ],
    );
  }
}
