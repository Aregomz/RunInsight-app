// features/profile/presentation/pages/profile_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/profile_edit_bloc.dart';
import '../../../../core/di/dependency_injection.dart';

class ProfileEditPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> currentUserData;

  const ProfileEditPage({
    super.key,
    required this.userId,
    required this.currentUserData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileEditBloc(
        updateProfileUseCase: DependencyInjection.getUpdateProfileUseCase(),
      ),
      child: ProfileEditView(
        userId: userId,
        currentUserData: currentUserData,
      ),
    );
  }
}

class ProfileEditView extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> currentUserData;

  const ProfileEditView({
    super.key,
    required this.userId,
    required this.currentUserData,
  });

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedExperience = 'Principiante';

  final List<String> _experienceLevels = [
    'Principiante',
    'Intermedio',
    'Avanzado',
    'Experto',
  ];

  @override
  void initState() {
    super.initState();
    print('Debug: ProfileEditView initState');
    print('Debug: userId = ${widget.userId}');
    print('Debug: currentUserData = ${widget.currentUserData}');
    
    // Obtener datos actuales del usuario
    final stats = widget.currentUserData['stats'] ?? {};
    print('Debug: stats = $stats');
    
    _weightController.text = (stats['weight'] ?? 0.0).toString();
    _heightController.text = (stats['height'] ?? 0).toString();
    _selectedExperience = stats['experience'] ?? 'Principiante';
    
    print('Debug: weight = ${_weightController.text}');
    print('Debug: height = ${_heightController.text}');
    print('Debug: experience = $_selectedExperience');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              title: const Text(
                'Editar Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  if (GoRouter.of(context).canPop()) {
                    context.pop();
                  } else {
                    context.go('/profile');
                  }
                },
              ),
            ),
            Expanded(
              child: BlocListener<ProfileEditBloc, ProfileEditState>(
                listener: (context, state) {
                  if (state is ProfileEditSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perfil actualizado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.pop();
                  } else if (state is ProfileEditError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Espacio mínimo para evitar overflow
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
                        // Header con icono
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6A00),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Información Personal',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Actualiza tus datos personales',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Campo de peso
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Peso (kg)',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.monitor_weight_outlined,
                                color: Color(0xFFFF6A00),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFFF6A00), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF181B23),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu peso';
                              }
                              final weight = double.tryParse(value);
                              if (weight == null || weight <= 0) {
                                return 'Por favor ingresa un peso válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Campo de altura
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Altura (cm)',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.height_outlined,
                                color: Color(0xFFFF6A00),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFFFF6A00), width: 2),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF181B23),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu altura';
                              }
                              final height = int.tryParse(value);
                              if (height == null || height <= 0) {
                                return 'Por favor ingresa una altura válida';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Selector de experiencia
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up_outlined,
                              color: Color(0xFFFF6A00),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Nivel de experiencia',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF181B23),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedExperience,
                              dropdownColor: const Color(0xFF181B23),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFFF6A00)),
                              items: _experienceLevels.map((String level) {
                                return DropdownMenuItem<String>(
                                  value: level,
                                  child: Text(level),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedExperience = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        const SizedBox(height: 40),
                        // Botón de guardar
                        BlocBuilder<ProfileEditBloc, ProfileEditState>(
                          builder: (context, state) {
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6A00).withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: state is ProfileEditLoading
                                    ? null
                                    : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6A00),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 0,
                                ),
                                child: state is ProfileEditLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.save_outlined,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Guardar Cambios',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                        // Espacio extra al final para evitar overflow con teclado
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final weight = double.parse(_weightController.text);
      final height = int.parse(_heightController.text);
      
      context.read<ProfileEditBloc>().add(
        UpdateProfileEvent(
          userId: widget.userId,
          weight: weight,
          height: height,
          experience: _selectedExperience,
        ),
      );
    }
  }
} 