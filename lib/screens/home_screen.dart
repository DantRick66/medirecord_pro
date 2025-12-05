// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart'; // ← ESTA LÍNEA FALTABA
import '../models/medicine.dart';
import '../widgets/medicine_card.dart';
import 'add_edit_medicine_screen.dart';
import 'medicine_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Medicine>> _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _medicinesFuture = DatabaseHelper.instance.getMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('MediRecord Pro',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: const Color(0xFF1A1F71),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1F71), Color(0xFF2E3192)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.medication_liquid,
                    size: 90, color: Colors.white),
                const SizedBox(height: 12),
                Text('Mis Medicamentos',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Nunca olvides una dosis',
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Medicine>>(
              future: _medicinesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final meds = snapshot.data ?? [];

                if (meds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medication,
                            size: 100, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        Text('Sin medicamentos',
                            style: GoogleFonts.poppins(fontSize: 20)),
                        Text('Presiona + para agregar'),
                      ],
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: meds.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: MedicineCard(
                              medicine: meds[index],
                              onDelete: () async {
                                await DatabaseHelper.instance
                                    .deleteMedicine(meds[index].id);
                                await NotificationService.cancelMedicine(
                                    meds[index]); // ← AHORA FUNCIONA
                                _refresh();
                              },
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => AddEditMedicineScreen(
                                          medicine: meds[index])),
                                );
                                _refresh();
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MedicineDetailScreen(
                                        medicine: meds[index]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1A1F71),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Agregar',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddEditMedicineScreen()));
          _refresh();
        },
      ),
    );
  }
}
