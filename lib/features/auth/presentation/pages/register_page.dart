// features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  void _validate() {
    if (_formKey.currentState!.validate()) {
      // TODO: Procesar registro
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050510),
              Color(0xFF0A0A20),
              Color(0xFF0C0C27),
              Color(0xFF0C0C27),
              Color(0xFF0C0C27),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: kToolbarHeight + 40),
                const Text(
                  'Crear Cuenta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                    controller: _nameController,
                    hintText: 'Nombre completo',
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _emailController,
                    hintText: 'Correo',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      if (!value.contains('@') || !value.contains('.com')) {
                        return 'Correo inválido';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _usernameController,
                    hintText: 'Nombre de usuario',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      if (value.contains(' ')) return 'No puede contener espacios';
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _ageController,
                    hintText: 'Edad',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      if (int.tryParse(value) == null) return 'Solo números';
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _genderController,
                    hintText: 'Género',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';
                      final g = value.toLowerCase();
                      if (g != 'hombre' &&
                          g != 'mujer' &&
                          g != 'prefiero no responder') {
                        return 'Debe ser: hombre, mujer o prefiero no responder';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _passwordController,
                    hintText: 'Contraseña',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirmar contraseña',
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'No coinciden';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                          controller: _weightController,
                          hintText: 'Peso (kg)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requerido';
                            if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
                              return 'Formato inválido (ej. 70.0)';
                            }
                            return null;
                          }),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                          controller: _heightController,
                          hintText: 'Altura (cm)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requerido';
                            if (int.tryParse(value) == null) {
                              return 'Solo números';
                            }
                            return null;
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildGradientButton(onPressed: _validate, text: 'Crear Cuenta'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver',
                      style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1C1C2E),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        errorStyle: const TextStyle(color: Colors.redAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      {required VoidCallback onPressed, required String text}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6A00), Color(0xFFFF3C4A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
