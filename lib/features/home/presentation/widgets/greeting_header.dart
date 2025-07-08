// features/home/presentation/widgets/greeting_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runinsight/features/user/presentation/bloc/user_bloc.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserBloc()..add(const LoadCurrentUser()),
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          print('🎯 GreetingHeader - Estado actual: $state');

          String displayName = 'Usuario';

          if (state is UserLoaded) {
            // Usar específicamente el campo username de la base de datos
            final username = state.userData['username'];

            // Usar el username, si no está disponible usar 'Usuario'
            displayName = username ?? 'Usuario';

            print('✅ Username encontrado en BD: $displayName');
            print('✅ Datos completos del usuario: ${state.userData}');
            print('🔍 Campo username de la BD: $username');
            print('🎯 Mostrando en Home: "Hola, $displayName 👋"');
          } else if (state is UserError) {
            displayName = 'Usuario';
            print('❌ Error en GreetingHeader: ${state.message}');
          } else if (state is UserLoading) {
            print('⏳ Cargando datos del usuario...');
          } else if (state is UserInitial) {
            print('🔄 Estado inicial - esperando datos...');
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Hola, ',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6A00), // Naranja de la app
                      ),
                    ),
                    const Text(
                      ' 👋',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
