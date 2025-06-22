// features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/core/widgets/gradient_button.dart';

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
  final _genderController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _birthDate;

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
    _genderController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  double get _formProgress {
    int filled = 0;
    const total = 9; // Total de campos a considerar
    if (_nameController.text.isNotEmpty) filled++;
    if (_emailController.text.isNotEmpty) filled++;
    if (_usernameController.text.isNotEmpty) filled++;
    if (_birthDate != null) filled++;
    if (_genderController.text.isNotEmpty) filled++;
    if (_passwordController.text.isNotEmpty) filled++;
    if (_confirmPasswordController.text.isNotEmpty) filled++;
    if (_weightController.text.isNotEmpty) filled++;
    if (_heightController.text.isNotEmpty) filled++;
    return filled / total;
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
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _formProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Color(0xFFFF6A00)),
                    ),
                  ),
                ),
                _buildTextField(
                    controller: _nameController,
                    hintText: 'Nombre completo',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Campo requerido'
                        : null),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _emailController,
                    hintText: 'Correo',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Campo requerido';
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
                      if (value == null || value.isEmpty)
                        return 'Campo requerido';
                      if (value.contains(' ')) return 'No puede contener espacios';
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildBirthDateField(),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _genderController,
                    hintText: 'Género',
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Campo requerido';
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
                            if (value == null || value.isEmpty)
                              return 'Requerido';
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
                            if (value == null || value.isEmpty)
                              return 'Requerido';
                            if (int.tryParse(value) == null) {
                              return 'Solo números';
                            }
                            return null;
                          }),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                GradientButton(
                    onPressed: _validate,
                    text: 'Crear Cuenta',
                    width: double.infinity),
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

  Widget _buildBirthDateField() {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime(now.year - 18),
          firstDate: DateTime(1900),
          lastDate: now,
          helpText: 'Selecciona tu fecha de nacimiento',
        );
        if (picked != null) {
          setState(() => _birthDate = picked);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: _birthDate == null
                ? ''
                : '${_birthDate!.day.toString().padLeft(2, '0')}/'
                  '${_birthDate!.month.toString().padLeft(2, '0')}/'
                  '${_birthDate!.year}',
          ),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1C1C2E),
            hintText: 'Fecha de nacimiento',
            hintStyle: const TextStyle(color: Colors.white54),
            errorStyle: const TextStyle(color: Colors.redAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (_) =>
              _birthDate == null ? 'Campo requerido' : null,
        ),
      ),
    );
  }
}
