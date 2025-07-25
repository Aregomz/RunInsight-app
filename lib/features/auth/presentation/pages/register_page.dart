// features/auth/presentation/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:runinsight/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:runinsight/features/auth/presentation/widgets/gradient_button.dart';

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
  final _experienceController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  DateTime? _birthDate;

  // Listas para los dropdowns
  final List<Map<String, dynamic>> _experienceLevels = [
    {'id': 1, 'name': 'Principiante'},
    {'id': 2, 'name': 'Intermedio'},
    {'id': 3, 'name': 'Avanzado'},
    {'id': 4, 'name': 'Experto'},
    {'id': 5, 'name': 'Maestro'},
  ];

  final List<Map<String, dynamic>> _genderOptions = [
    {'id': 1, 'gender': 'Masculino'},
    {'id': 2, 'gender': 'Femenino'},
    {'id': 3, 'gender': 'No binario'},
    {'id': 4, 'gender': 'Otro'},
    {'id': 5, 'gender': 'Prefiero no decirlo'},
  ];

  @override
  void initState() {
    super.initState();
    // Agregar listeners a todos los controladores
    _nameController.addListener(_updateProgress);
    _emailController.addListener(_updateProgress);
    _usernameController.addListener(_updateProgress);
    _genderController.addListener(_updateProgress);
    _experienceController.addListener(_updateProgress);
    _passwordController.addListener(_updateProgress);
    _confirmPasswordController.addListener(_updateProgress);
    _weightController.addListener(_updateProgress);
    _heightController.addListener(_updateProgress);
  }

  void _updateProgress() {
    setState(() {
      // Esto forzará la reconstrucción del widget y actualizará la barra de progreso
    });
  }

  void _validate() {
    if (_formKey.currentState!.validate()) {
      final age = _birthDate != null
          ? (DateTime.now().difference(_birthDate!).inDays / 365)
              .floor()
              .toString()
          : '';

      context.read<AuthBloc>().add(RegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            username: _usernameController.text.trim(),
            password: _passwordController.text,
            gender: _genderController.text.trim(),
            age: age,
            weight: _weightController.text,
            height: _heightController.text,
          ));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _genderController.dispose();
    _experienceController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  double get _formProgress {
    int filled = 0;
    const total = 10; // Aumentado a 10 para incluir experiencia
    if (_nameController.text.isNotEmpty) filled++;
    if (_emailController.text.isNotEmpty) filled++;
    if (_usernameController.text.isNotEmpty) filled++;
    if (_birthDate != null) filled++;
    if (_genderController.text.isNotEmpty) filled++;
    if (_experienceController.text.isNotEmpty) filled++;
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
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
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
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
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
                      if (value == null || value.isEmpty) {
                        return 'Campo requerido';
                      }
                      if (value.contains(' ')) {
                        return 'No puede contener espacios';
                      }
                      return null;
                    }),
                const SizedBox(height: 16),
                _buildBirthDateField(),
                const SizedBox(height: 16),
                _buildDropdownField(
                  controller: _genderController,
                  hintText: 'Selecciona con el que te identificas',
                  items: _genderOptions.map((option) => 
                    DropdownMenuItem<String>(value: option['gender'].toString(), child: Text(option['gender']))
                  ).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  controller: _experienceController,
                  hintText: 'Nivel de experiencia',
                  items: _experienceLevels.map((option) => 
                    DropdownMenuItem<String>(value: option['name'].toString(), child: Text(option['name']))
                  ).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Campo requerido';
                    }
                    return null;
                  },
                ),
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
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
                            if (!RegExp(r'^\d+(\.\d{1,2})?$')
                                .hasMatch(value)) {
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
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
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
                  onPressed: () {
                    if (GoRouter.of(context).canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  child: const Text('Volver', style: TextStyle(color: Colors.white70)),
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
          setState(() {
            _birthDate = picked;
            _updateProgress(); // Actualizar progreso cuando se selecciona fecha
          });
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

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String hintText,
    required List<DropdownMenuItem<String>> items,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      items: items,
      onChanged: (value) {
        setState(() {
          controller.text = value ?? '';
          _updateProgress();
        });
      },
      validator: validator,
      dropdownColor: const Color(0xFF1C1C2E),
      style: const TextStyle(color: Colors.white),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
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
}
