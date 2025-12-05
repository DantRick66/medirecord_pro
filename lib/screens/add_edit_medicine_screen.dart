// lib/screens/add_edit_medicine_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  const AddEditMedicineScreen({Key? key, this.medicine}) : super(key: key);

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _dosageCtrl, _notesCtrl;

  List<TimeOfDay> _times = [];
  List<String> _days = ["Todos los días"];
  DateTime _startDate = DateTime.now();
  String _form = "Tableta";
  Color _color = Colors.blue;

  final forms = ["Tableta", "Cápsula", "Jarabe", "Inyección", "Gotas", "Crema"];
  final colors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.medicine?.name ?? '');
    _dosageCtrl = TextEditingController(text: widget.medicine?.dosage ?? '');
    _notesCtrl = TextEditingController(text: widget.medicine?.notes ?? '');

    if (widget.medicine != null) {
      _times = List.from(widget.medicine!.times);
      _days = List.from(widget.medicine!.daysOfWeek);
      _startDate = widget.medicine!.startDate;
      _form = widget.medicine!.form;
      _color = widget.medicine!.color;
    }
    if (_times.isEmpty) _times.add(const TimeOfDay(hour: 8, minute: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? "Nuevo Medicamento" : "Editar",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1A1F71),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameCtrl, "Nombre", Icons.medication),
              const SizedBox(height: 16),
              _buildTextField(
                  _dosageCtrl, "Dosis (ej: 500mg)", Icons.format_size),
              const SizedBox(height: 16),
              _buildDropdown(
                  "Forma", _form, forms, (v) => setState(() => _form = v!)),
              const SizedBox(height: 20),
              _buildTimeList(),
              const SizedBox(height: 20),
              _buildColorPicker(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1F71),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  onPressed: _save,
                  child: Text(
                      widget.medicine == null ? "Guardar" : "Actualizar",
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A1F71)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (v) => v!.isEmpty ? "Requerido" : null,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            const Icon(Icons.medication_liquid, color: Color(0xFF1A1F71)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTimeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Horarios",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        ..._times.asMap().entries.map((e) => ListTile(
              title: Text(e.value.format(context)),
              trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => _times.removeAt(e.key))),
              onTap: () async {
                final t = await showTimePicker(
                    context: context, initialTime: e.value);
                if (t != null) setState(() => _times[e.key] = t);
              },
            )),
        ElevatedButton.icon(
            onPressed: () => setState(
                () => _times.add(const TimeOfDay(hour: 12, minute: 0))),
            icon: const Icon(Icons.add),
            label: const Text("Agregar hora")),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Color",
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 15,
          children: colors
              .map((c) => GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _color == c
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 4)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      final med = Medicine(
        id: widget.medicine?.id ?? '',
        name: _nameCtrl.text,
        dosage: _dosageCtrl.text,
        form: _form,
        times: _times,
        daysOfWeek: _days,
        startDate: _startDate,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        colorHex:
            '#${_color.value.toRadixString(16).substring(2).toUpperCase()}',
      );

      final savedMed = await DatabaseHelper.instance.saveMedicine(med);

      if (widget.medicine != null) {
        await NotificationService.cancelMedicine(widget.medicine!);
      }
      await NotificationService.scheduleMedicine(savedMed);

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}
