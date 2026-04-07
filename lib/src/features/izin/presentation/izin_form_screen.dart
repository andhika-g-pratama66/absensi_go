import 'package:absensi_go/src/features/izin/models/izin_model.dart';
import 'package:absensi_go/src/features/izin/provider/izin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class IzinFormScreen extends ConsumerStatefulWidget {
  final int? izinId;

  const IzinFormScreen({super.key, this.izinId});

  @override
  ConsumerState<IzinFormScreen> createState() => _IzinFormScreenState();
}

class _IzinFormScreenState extends ConsumerState<IzinFormScreen> {
  late final TextEditingController _alasanIzinController;
  DateTime? _attendanceDate;

  @override
  void initState() {
    super.initState();
    _alasanIzinController = TextEditingController();
    _attendanceDate = DateTime.now();

    // Jika ada izinId, load data existing
    if (widget.izinId != null) {
      Future.microtask(() {
        ref.read(izinProvider.notifier).getIzinDetail(widget.izinId!);
      });
    }
  }

  @override
  void didUpdateWidget(IzinFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika data sudah loaded, populate form
    final selectedIzin = ref.watch(izinProvider).selectedIzin;
    if (selectedIzin != null && selectedIzin.id == widget.izinId) {
      _attendanceDate = selectedIzin.attendanceDate;
      _alasanIzinController.text = selectedIzin.alasanIzin ?? '';
    }
  }

  @override
  void dispose() {
    _alasanIzinController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _attendanceDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _attendanceDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    final izinModel = IzinModel(
      attendanceDate: _attendanceDate,
      status: 'izin',
      alasanIzin: _alasanIzinController.text,
    );

    try {
      if (widget.izinId == null) {
        // Create
        await ref.read(izinProvider.notifier).submitIzin(izinModel);
      } else {
        // Update
        await ref.read(izinProvider.notifier).updateIzin(widget.izinId!, izinModel);
      }

      if (!mounted) return;

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.izinId == null
              ? 'Izin berhasil diajukan'
              : 'Izin berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateForm() {
    if (_attendanceDate == null) {
      _showSnackBar('Pilih tanggal izin', Colors.red);
      return false;
    }

    if (_alasanIzinController.text.isEmpty) {
      _showSnackBar('Alasan tidak boleh kosong', Colors.red);
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(izinProvider);
    final isLoading = widget.izinId != null && state.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: Text(
          widget.izinId == null ? 'Ajukan Izin' : 'Edit Izin',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal Izin
                  const Text(
                    'Tanggal Izin',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _attendanceDate == null
                                ? 'Pilih tanggal'
                                : DateFormat('dd MMMM yyyy', 'id_ID')
                                    .format(_attendanceDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _attendanceDate == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                          Icon(Icons.calendar_today,
                              size: 20, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Alasan Izin
                  const Text(
                    'Alasan Izin',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _alasanIzinController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Jelaskan alasan izin Anda...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Color(0xFF1A1A2E), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : Text(
                              widget.izinId == null ? 'Ajukan Izin' : 'Simpan Perubahan',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: state.isSubmitting ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
