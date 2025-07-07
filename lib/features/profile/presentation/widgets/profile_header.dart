// features/profile/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color(0xFFFF6A00),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
