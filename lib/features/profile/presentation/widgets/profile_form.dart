// features/profile/presentation/widgets/profile_form.dart
import 'package:flutter/material.dart';

class ProfileForm extends StatefulWidget {
  final String initialUsername;
  final String initialGender;
  final String initialWeight;
  final String initialHeight;

  const ProfileForm({
    super.key,
    required this.initialUsername,
    required this.initialGender,
    required this.initialWeight,
    required this.initialHeight,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _genderController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _genderController = TextEditingController(text: widget.initialGender);
    _weightController = TextEditingController(text: widget.initialWeight);
    _heightController = TextEditingController(text: widget.initialHeight);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _genderController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Enviar evento al bloc para guardar cambios
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Nombre de usuario'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo requerido';
              if (value.contains(' ')) return 'No puede tener espacios';
              return null;
            },
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _genderController,
            decoration: const InputDecoration(labelText: 'Género'),
            validator: (value) {
              final validOptions = ['hombre', 'mujer', 'prefiero no responder'];
              if (value == null || value.isEmpty) return 'Campo requerido';
              if (!validOptions.contains(value.toLowerCase())) {
                return 'Debe ser: hombre, mujer o prefiero no responder';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Peso (kg)'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo requerido';
              if (!RegExp(r'^\d+(\.\d{1,2})?\$').hasMatch(value)) {
                return 'Formato inválido (ej. 70.0)';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _heightController,
            decoration: const InputDecoration(labelText: 'Altura (cm)'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo requerido';
              if (int.tryParse(value) == null || value.length > 3) {
                return 'Debe ser un número de hasta 3 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6A00),
            ),
            child: const Text('Guardar cambios'),
          )
        ],
      ),
    );
  }
}
