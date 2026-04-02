import 'package:absensi_go/src/core/constants/default_font.dart';
import 'package:absensi_go/src/core/constants/form_decoration.dart';
import 'package:absensi_go/src/core/utils/navigator.dart';
import 'package:absensi_go/src/data/models/auth_model.dart';
import 'package:absensi_go/src/features/auth/presentation/login_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['Laki-Laki', 'Perempuan'];
  UserModel? _user;

  bool _isLoading = true;
  bool _isObscured = true;
  bool _isObscured2 = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text('Buat Akun', style: DefaultFont.header),
                  SizedBox(height: 48),
                  Text(' Nama Lengkap', style: DefaultFont.bodyBold),
                  TextFormField(
                    controller: _nameController,
                    // validator: (value) => _validator.validateName(value),
                    decoration: formInputConstant(
                      prefixIconData: Icon(Icons.person_2_outlined),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(' Alamat Email', style: DefaultFont.bodyBold),
                  TextFormField(
                    controller: _emailController,
                    // validator: (value) => _validator.validateEmail(value),
                    decoration: formInputConstant(
                      prefixIconData: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(' Jenis Kelamin', style: DefaultFont.bodyBold),
                  DropdownButtonFormField<String>(
                    value:
                        _selectedGender, // Pastikan value diatur agar state sinkron
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                    // Mempercantik tampilan list dropdown saat terbuka
                    menuMaxHeight: 300,

                    borderRadius: BorderRadius.circular(12),

                    items: _genderOptions.map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(category),
                        ),
                      );
                    }).toList(),

                    onChanged: (newValue) {
                      setState(() => _selectedGender = newValue);
                    },

                    // Menggunakan dekorasi yang lebih custom
                    decoration: formInputConstant(),

                    // Opsional: Tambahkan validasi jika di dalam Form
                    validator: (value) =>
                        value == null ? 'Pilih jenis kelamin' : null,
                  ),
                  SizedBox(height: 20),
                  Text(' Kata Sandi', style: DefaultFont.bodyBold),
                  TextFormField(
                    controller: _passwordController,
                    // validator: (value) => _validator.validatePassword(value),
                    obscureText: _isObscured,
                    decoration: formInputConstant(
                      prefixIconData: Icon(Icons.lock_outline_rounded),
                      suffixIconData: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                        icon: _isObscured
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Konfirmasi Kata Sandi', style: DefaultFont.bodyBold),
                  TextFormField(
                    // controller: _passConfirmController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Kata Sandi tidak cocok';
                      }
                      return null;
                    },
                    obscureText: _isObscured2,
                    decoration: formInputConstant(
                      prefixIconData: Icon(Icons.lock_outline_rounded),
                      suffixIconData: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscured2 = !_isObscured2;
                          });
                        },
                        icon: _isObscured2
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Already have an account? ',
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushReplacement(LoginScreen());
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
