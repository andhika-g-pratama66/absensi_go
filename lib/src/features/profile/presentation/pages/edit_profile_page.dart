import 'dart:convert';
import 'dart:typed_data';

import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/features/auth/provider/auth_provider.dart';
import 'package:absensi_go/src/features/profile/provider/edit_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilPage extends ConsumerStatefulWidget {
  const EditProfilPage({super.key});

  @override
  ConsumerState<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends ConsumerState<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _hasInitializedFields = false;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(currentUserProvider)?.data?.user?.name ?? '',
    );
    _emailController = TextEditingController(
      text: ref.read(currentUserProvider)?.data?.user?.email ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // On save button tap
  Future<void> _onSave() async {
    final notifier = ref.read(editProfileProvider.notifier);

    // Upload photo first if user picked one
    if (ref.read(editProfileProvider).base64Image != null) {
      await notifier.uploadPhoto();
      // Stop if photo upload failed
      if (ref.read(editProfileProvider).errorMessage != null) return;
    }

    await notifier.editProfile(
      name: _nameController.text,
      email: _emailController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final user = currentUser?.data?.user;

    if (!_hasInitializedFields && user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _hasInitializedFields = true;
    }

    // React to success and error side-effects
    ref.listen<EditProfileState>(editProfileProvider, (prev, next) {
      if (next.isSuccess) {
        ref.read(editProfileProvider.notifier).resetSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Color(0xFF3B6D11),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: ${next.errorMessage}')));
        ref.read(editProfileProvider.notifier).clearError();
      }
    });

    final isLoading = ref.watch(editProfileProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        title: const Text('Edit Profil', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildAvatar(),
              const SizedBox(height: 32),
              _buildFormFields(),
              const SizedBox(height: 40),
              _buildButtons(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final editState = ref.watch(editProfileProvider);
    final base64String = editState.base64Image;

    // Safely decode the Base64 string
    Uint8List? imageBytes;
    if (base64String != null && base64String.isNotEmpty) {
      try {
        // Strip the "data:image/jpeg;base64," prefix if present
        final cleanBase64 = base64String.contains(',')
            ? base64String.split(',').last
            : base64String;

        imageBytes = base64Decode(cleanBase64);
      } catch (e) {
        // If the string is corrupted, we catch the error and fallback to initials
        debugPrint('Error decoding base64 image: $e');
        imageBytes = null;
      }
    }

    return Center(
      child: GestureDetector(
        onTap: () => ref.read(editProfileProvider.notifier).pickImage(),
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1A1A2E).withOpacity(0.1),
              // Display base64 if available, otherwise fallback to text initial
              backgroundImage: imageBytes != null
                  ? MemoryImage(imageBytes)
                  : null,
              child: imageBytes == null
                  ? Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nama Lengkap',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Email tidak valid';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(bool isLoading) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan Perubahan'),
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            'Batal',
            style: TextStyle(color: Color(0xFF1A1A2E)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
