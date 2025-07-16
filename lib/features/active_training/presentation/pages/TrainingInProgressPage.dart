import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/active_training_bloc.dart';
import '../bloc/active_training_event.dart';
import '../bloc/active_training_state.dart';
import '../../domain/usecases/save_active_training.dart';
import '../../data/repositories/active_training_repository_impl.dart';
import '../../data/datasources/active_training_remote_datasource.dart';
import '../widgets/TrainingMetricsCard.dart';
import '../widgets/timer_widget.dart';
import '../widgets/weather_widget.dart';
import '../widgets/movement_alert_widget.dart';
import '../widgets/finish_training_button.dart';
import '../widgets/share_training_button.dart';
import 'package:go_router/go_router.dart';
import 'package:pedometer/pedometer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runinsight/features/home/data/datasources/weather_remote_datasource.dart';
import 'package:runinsight/features/home/data/models/weather_response_model.dart';
import 'package:flutter/scheduler.dart' show Ticker, TickerProviderStateMixin;
import '../../data/services/training_data_service.dart';
import '../../data/services/training_state_service.dart';
import 'package:provider/provider.dart';
import '../../../ranking/presentation/bloc/ranking_bloc.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../../user/data/services/user_service.dart';

class TrainingInProgressPage extends StatefulWidget {
  const TrainingInProgressPage({super.key});

  @override
  State<TrainingInProgressPage> createState() => _TrainingInProgressPageState();
}

class _TrainingInProgressPageState extends State<TrainingInProgressPage>
    with TickerProviderStateMixin {
  late ActiveTrainingBloc _bloc;
  late final TextEditingController _notesController;
  String? _selectedTrainingType;
  String? _selectedTerrainType;
  bool _showFinishForm = false;
  bool _trainingStarted = false;

  // Sensores
  Stream<StepCount>? _stepCountStream;
  Stream<Position>? _positionStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<Position>? _positionSubscription;
  int _initialSteps = 0;
  int _currentSteps = 0;
  double _distanceKm = 0.0;
  double _lastLatitude = 0.0;
  double _lastLongitude = 0.0;
  double _totalDistanceMeters = 0.0;
  double _altitude = 0.0;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  late Ticker _ticker;
  String _weatherDescription = 'Cargando...';
  WeatherRemoteDatasource? _weatherDatasource;
  bool _isDisposed = false;
  Timer? _uiUpdateTimer;
  Timer? _gpsRestartTimer;
  int _gpsRestartCount = 0;

  static const List<String> trainingTypes = [
    'Easy Run',
    'Hard Run',
    'Intervalos',
    'Tempo Run',
    'Recuperación',
    'Long Run',
    'Técnica de Carrera',
    'Subidas',
    'Fartlek',
    'Descanso Activo',
  ];
  static const List<String> terrainTypes = [
    'Asfalto',
    'Tierra',
    'Césped',
    'Arena',
    'Pista (Tartán)',
    'Sendero',
    'Montaña',
    'Cemento',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = ActiveTrainingBloc(
      saveActiveTraining: SaveActiveTraining(
        ActiveTrainingRepositoryImpl(
          remoteDatasource: ActiveTrainingRemoteDatasourceImpl(),
        ),
      ),
    );
    _notesController = TextEditingController();
    _weatherDatasource = WeatherRemoteDatasource();
    _ticker = createTicker(_onTick);
    // No iniciar sensores ni timer hasta que el usuario presione 'Iniciar entrenamiento'
  }

  void _onTick(Duration elapsed) {
    if (!_isDisposed && mounted) {
      setState(() {
        _elapsed = elapsed;

        // Fallback: si no hay movimiento GPS después de 2 minutos, simular distancia mínima
        if (_trainingStarted &&
            _totalDistanceMeters == 0.0 &&
            elapsed.inMinutes >= 2) {
          // Simular una caminata muy lenta (1 km/h) si no hay movimiento detectado
          _distanceKm = (elapsed.inMinutes * 1.0) / 60.0;
          _totalDistanceMeters = _distanceKm * 1000.0;
          print(
            '🔄 Fallback: Simulando distancia mínima de ${_distanceKm.toStringAsFixed(3)}km',
          );

          // Actualizar el bloc con datos de fallback
          try {
            _bloc.add(
              UpdateTrainingData(
                timeMinutes: elapsed.inMinutes,
                distanceKm: _distanceKm,
                rhythm: _distanceKm > 0 ? elapsed.inMinutes / _distanceKm : 0.0,
                altitude: _altitude,
                weather: _weatherDescription,
              ),
            );
          } catch (e) {
            print('⚠️ Error actualizando datos de fallback: $e');
          }
        }
      });
    }
  }

  void _updateUI() {
    // Debounce para evitar demasiadas actualizaciones de UI
    _uiUpdateTimer?.cancel();
    _uiUpdateTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isDisposed && mounted) {
        setState(() {
          // Actualizar solo los valores que han cambiado
        });
      }
    });
  }

  void _startTraining() {
    if (_isDisposed) return;

    setState(() {
      _trainingStarted = true;
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
    });

    // Activar el estado global del entrenamiento
    final trainingState = Provider.of<TrainingStateService>(
      context,
      listen: false,
    );
    trainingState.startTraining();

    _bloc.add(StartTraining());
    _initSensors();
    _ticker.start();
  }

  void _finishTraining() {
    if (_isDisposed) return;

    _ticker.stop();
    _stopSensors();
    setState(() {
      _showFinishForm = true;
    });
  }

  void _cancelTraining() {
    if (_isDisposed) return;

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Cancelar entrenamiento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            '¿Estás seguro de que quieres cancelar el entrenamiento? Se perderán todos los datos registrados.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Color(0xFFFF6A00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmCancelTraining();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmCancelTraining() {
    if (_isDisposed) return;

    // Detener sensores y timer
    _ticker.stop();
    _stopSensors();

    // Desactivar el estado global del entrenamiento
    try {
      final trainingState = Provider.of<TrainingStateService>(
        context,
        listen: false,
      );
      trainingState.stopTraining();
    } catch (e) {
      // Ignorar errores si el provider no está disponible
    }

    // Resetear estado
    setState(() {
      _trainingStarted = false;
      _showFinishForm = false;
      _elapsed = Duration.zero;
      _currentSteps = 0;
      _initialSteps = 0;
      _distanceKm = 0.0;
      _totalDistanceMeters = 0.0;
      _altitude = 0.0;
      _lastLatitude = 0.0;
      _lastLongitude = 0.0;
      _startTime = null;
    });

    // Mostrar mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entrenamiento cancelado'),
        backgroundColor: Colors.orange,
      ),
    );

    // Navegar al home después de cancelar
    if (mounted) {
      context.go('/home');
    }
  }

  void _stopSensors() {
    try {
      _stepCountSubscription?.cancel();
      _positionSubscription?.cancel();
      _gpsRestartTimer?.cancel();
      _stepCountSubscription = null;
      _positionSubscription = null;
      _gpsRestartTimer = null;
      print('📍 Sensores detenidos correctamente');
    } catch (e) {
      print('⚠️ Error al detener sensores: $e');
    }
  }

  void _restartGPS() {
    if (_isDisposed || !mounted) return;

    _gpsRestartCount++;
    print('🔄 Reiniciando GPS (intento $_gpsRestartCount)...');

    try {
      _positionSubscription?.cancel();
      _positionSubscription = null;

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 3,
          timeLimit: Duration(seconds: 300),
        ),
      );
      _positionSubscription = _positionStream?.listen(
        _onPosition,
        onError: (error) {
          print('⚠️ Error en GPS después del reinicio: $error');
          // Programar otro reinicio si es necesario
          if (_gpsRestartCount < 3) {
            _gpsRestartTimer = Timer(const Duration(seconds: 30), _restartGPS);
          }
        },
      );
      print('📍 GPS reiniciado correctamente');
    } catch (e) {
      print('⚠️ Error al reiniciar GPS: $e');
    }
  }

  void _initSensors() async {
    try {
      print('📍 Inicializando sensores de forma segura...');

      // Solicitar permisos de ubicación
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('⚠️ Permisos de ubicación denegados, usando modo básico');
        setState(() {
          _weatherDescription = 'Soleado';
        });
        return;
      }

      // Inicializar podómetro de forma segura
      try {
        print('👟 Intentando inicializar podómetro...');
        _stepCountStream = Pedometer.stepCountStream;
        _stepCountSubscription = _stepCountStream?.listen(
          _onStepCount,
          onError: (error) {
            print('⚠️ Error en podómetro: $error');
            print('⚠️ El dispositivo puede no tener sensor de pasos');
          },
        );
        print('👟 Podómetro inicializado correctamente');
      } catch (e) {
        print('⚠️ No se pudo inicializar podómetro: $e');
        print(
          '⚠️ El dispositivo puede no tener sensor de pasos o permisos insuficientes',
        );
      }

      // Configurar GPS con mejor precisión y filtros
      try {
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy:
                LocationAccuracy.medium, // Menos agresivo pero más estable
            distanceFilter: 3, // Actualizar cada 3 metros
            timeLimit: Duration(seconds: 300), // 5 minutos de timeout
          ),
        );
        _positionSubscription = _positionStream?.listen(
          _onPosition,
          onError: (error) {
            print('⚠️ Error en GPS: $error');
          },
        );
        print('📍 GPS inicializado');
      } catch (e) {
        print('⚠️ No se pudo inicializar GPS: $e');
      }

      setState(() {
        _weatherDescription = 'Cargando...';
      });

      print('📍 Sensores inicializados de forma segura');
    } catch (e) {
      print('❌ Error al inicializar sensores: $e');
      setState(() {
        _weatherDescription = 'Soleado';
      });
    }
  }

  void _onStepCount(StepCount event) {
    if (_isDisposed || !mounted) return;

    try {
      print('👟 Evento de pasos recibido: ${event.steps} pasos totales');

      if (_initialSteps == 0) {
        _initialSteps = event.steps;
        print('👟 Pasos iniciales establecidos: $_initialSteps');
      }

      final newSteps = event.steps - _initialSteps;
      print('👟 Cálculo: ${event.steps} - $_initialSteps = $newSteps pasos');

      if (newSteps != _currentSteps && newSteps >= 0) {
        setState(() {
          _currentSteps = newSteps;
        });
        print('👟 Pasos actuales actualizados: $_currentSteps');
      } else {
        print('👟 No se actualizaron los pasos (sin cambios o negativos)');
      }
    } catch (e) {
      print('⚠️ Error procesando pasos: $e');
    }
  }

  void _onPosition(Position position) async {
    if (_isDisposed || !mounted) return;

    try {
      print(
        '📍 Nueva posición: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      );
      print('📍 Precisión: ${position.accuracy.toStringAsFixed(1)} metros');
      print('📍 Velocidad: ${position.speed.toStringAsFixed(2)} m/s');

      // Solo procesar si la precisión es aceptable (menos de 50 metros de error)
      if (position.accuracy > 50) {
        print(
          '⚠️ Precisión GPS muy baja: ${position.accuracy.toStringAsFixed(1)}m, ignorando posición',
        );
        return;
      }

      // Procesar movimiento incluso si está quieto (para capturar la posición inicial)
      // Solo rechazar si está completamente quieto por mucho tiempo
      if (position.speed < 0.1) {
        // Muy poca velocidad
        print('⚠️ Muy poca velocidad: ${position.speed.toStringAsFixed(2)}m/s');
        // No retornar, permitir procesar la posición inicial
      }

      if (_lastLatitude != 0.0 && _lastLongitude != 0.0) {
        final double distance = Geolocator.distanceBetween(
          _lastLatitude,
          _lastLongitude,
          position.latitude,
          position.longitude,
        );

        // Solo agregar distancia si es razonable (no más de 200 metros por actualización)
        if (distance > 0 && distance < 200) {
          _totalDistanceMeters += distance;
          print(
            '📏 Distancia agregada: ${distance.toStringAsFixed(2)}m, Total: ${_totalDistanceMeters.toStringAsFixed(2)}m',
          );
        } else if (distance >= 200) {
          print(
            '⚠️ Distancia sospechosa: ${distance.toStringAsFixed(2)}m, ignorando',
          );
        }
      } else {
        print('📍 Primera posición registrada');
      }

      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;
      _altitude = position.altitude;
      _distanceKm = _totalDistanceMeters / 1000.0;

      // Reiniciar contador de timeout del GPS
      _gpsRestartTimer?.cancel();
      _gpsRestartTimer = Timer(const Duration(seconds: 180), () {
        print('⏰ GPS timeout detectado, reiniciando...');
        _restartGPS();
      });

      print('📊 Estado actual:');
      print(
        '   Distancia total: ${_totalDistanceMeters.toStringAsFixed(2)}m (${_distanceKm.toStringAsFixed(3)}km)',
      );
      print('   Altitud: ${_altitude.toStringAsFixed(1)}m');
      print(
        '   Última posición: ${_lastLatitude.toStringAsFixed(6)}, ${_lastLongitude.toStringAsFixed(6)}',
      );

      // Actualizar clima solo ocasionalmente para no sobrecargar la API
      if (_weatherDatasource != null &&
          (_distanceKm < 0.05 || _totalDistanceMeters % 1000 < 50)) {
        try {
          final weather = await _weatherDatasource!.fetchWeatherData(
            position.latitude,
            position.longitude,
          );
          if (!_isDisposed && mounted) {
            setState(() {
              _weatherDescription = weather.data.first.weather.description;
            });
          }
        } catch (e) {
          if (!_isDisposed && mounted) {
            setState(() {
              _weatherDescription = 'No disponible';
            });
          }
        }
      }

      // Solo actualizar UI si hay cambios significativos
      if (!_isDisposed && mounted) {
        // Usar un debounce para evitar demasiadas actualizaciones
        _updateUI();
      }

      // Solo actualizar el bloc si hay cambios significativos
      try {
        final int timeMinutes = _startTime != null ? _elapsed.inMinutes : 0;
        final double rhythm = _distanceKm > 0 ? timeMinutes / _distanceKm : 0.0;

        _bloc.add(
          UpdateTrainingData(
            timeMinutes: timeMinutes,
            distanceKm: _distanceKm,
            rhythm: rhythm,
            altitude: _altitude,
            weather: _weatherDescription,
          ),
        );
      } catch (e) {
        print('⚠️ Error actualizando datos del entrenamiento: $e');
      }
    } catch (e) {
      print('⚠️ Error procesando posición GPS: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopSensors();
    _uiUpdateTimer?.cancel();
    _notesController.dispose();
    _ticker.dispose();
    _bloc.close();

    try {
      final trainingState = Provider.of<TrainingStateService>(
        context,
        listen: false,
      );
      trainingState.stopTraining();
    } catch (e) {
      // Si el provider ya no existe, ignora el error
      debugPrint(
        '⚠️ TrainingStateService ya no está disponible en dispose: $e',
      );
    }

    super.dispose();
  }

  void _onSaveTraining() {
    if (_isDisposed) return;

    if (_selectedTrainingType == null || _selectedTerrainType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona tipo de entrenamiento y terreno'),
        ),
      );
      return;
    }

    // Calcular el tiempo real en minutos
    final realTimeMinutes = _elapsed.inMinutes;

    // Validar que haya datos válidos
    if (realTimeMinutes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El entrenamiento debe durar al menos 1 minuto'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_distanceKm == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se detectó movimiento. Asegúrate de mover el dispositivo',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _bloc.add(
      FinishTraining(
        trainingType: _selectedTrainingType!,
        terrainType: _selectedTerrainType!,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        realTimeMinutes: realTimeMinutes,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Map<String, dynamic> _buildTrainingData() {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return {
      'time_minutes': _elapsed.inMinutes.toString(),
      'distance_km': _distanceKm.toString(),
      'rhythm':
          (_distanceKm > 0 ? _elapsed.inMinutes / _distanceKm : 0.0).toString(),
      'altitude': _altitude.toString(),
      'trainingType': _selectedTrainingType ?? 'Carrera',
      'terrainType': _selectedTerrainType ?? 'Pavimento',
      'weather': _weatherDescription,
      'notes': _notesController.text,
      'date': dateStr,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ActiveTrainingBloc, ActiveTrainingState>(
        listener: (context, state) {
          if (state is ActiveTrainingSuccess) {
            // Desactivar el estado global del entrenamiento
            final trainingState = Provider.of<TrainingStateService>(
              context,
              listen: false,
            );
            trainingState.stopTraining();

            // Guardar los datos del entrenamiento en el servicio
            final trainingData = {
              'time_minutes': state.timeMinutes.toString(),
              'distance_km': state.distanceKm.toString(),
              'rhythm': state.rhythm.toString(),
              'altitude': state.altitude.toString(),
              'trainingType': state.trainingType,
              'terrainType': state.terrainType,
              'weather': state.weather,
              'notes': state.notes ?? '',
              'date': state.date,
            };
            TrainingDataService.setLastTrainingData(trainingData);

            // --- RECARGA DE DATOS EN OTRAS TABS ---
            final userId = UserService.getUserId()?.toString() ?? '1';
            context.read<RankingBloc>().add(LoadRankingRequested(userId));
            final userIdInt = UserService.getUserId() ?? 1;
            context.read<HomeBloc>().add(LoadHomeData(userIdInt));
            // --------------------------------------

            // Navegar a la página de resumen del entrenamiento
            context.go('/training-summary');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Entrenamiento guardado exitosamente!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ActiveTrainingFailure) {
            String errorMessage = state.message;

            // Manejar errores específicos del backend
            if (errorMessage.contains('User not found')) {
              errorMessage =
                  'Error del servidor: Usuario no encontrado. Por favor, contacta al soporte técnico.';
            } else if (errorMessage.contains(
              'La distancia debe ser mayor a 0.1 km',
            )) {
              errorMessage =
                  'La distancia del entrenamiento debe ser mayor a 100 metros.';
            } else if (errorMessage.contains('Error del backend')) {
              errorMessage =
                  'Error del servidor. Intenta nuevamente o contacta soporte.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Reintentar',
                  textColor: Colors.white,
                  onPressed: () {
                    // Reintentar el envío
                    _onSaveTraining();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildTrainingUI(state);
        },
      ),
    );
  }

  Widget _buildTrainingUI(ActiveTrainingState state) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0C0C27)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header con estado y botón de cancelar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Botón de cancelar (solo cuando el entrenamiento está activo)
                          if (_trainingStarted)
                            IconButton(
                              onPressed: _cancelTraining,
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 24,
                              ),
                              tooltip: 'Cancelar entrenamiento',
                            )
                          else
                            const SizedBox(
                              width: 48,
                            ), // Espacio para mantener centrado
                          // Estado del entrenamiento
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _trainingStarted
                                    ? Icons.circle
                                    : Icons.play_circle_outline,
                                color:
                                    _trainingStarted
                                        ? Colors.green
                                        : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _trainingStarted
                                    ? 'Entrenamiento en curso'
                                    : 'Preparado para entrenar',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          // Espacio para mantener centrado
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Timer
                      TimerWidget(
                        elapsed: _elapsed,
                        isTrainingStarted: _trainingStarted,
                      ),
                      const SizedBox(height: 12),

                      // Clima
                      WeatherWidget(
                        weatherDescription: _weatherDescription,
                        isTrainingStarted: _trainingStarted,
                      ),
                      const SizedBox(height: 12),

                      // Métricas
                      TrainingMetricsCard(
                        distanceKm: _trainingStarted ? _distanceKm : 0.0,
                        pace:
                            _trainingStarted
                                ? (_distanceKm > 0
                                    ? (_elapsed.inMinutes / _distanceKm)
                                        .toStringAsFixed(2)
                                    : '0.00')
                                : '0.00',
                        heartRate: 0,
                        calories: 0,
                      ),
                      const SizedBox(height: 12),

                      // Alerta de movimiento
                      MovementAlertWidget(
                        showAlert:
                            _trainingStarted && _totalDistanceMeters == 0.0,
                      ),
                      const SizedBox(height: 20),

                      // Botones
                      if (!_trainingStarted && !_showFinishForm)
                        _buildStartButton(),
                      if (_trainingStarted && !_showFinishForm)
                        _buildFinishButton(),
                      if (_showFinishForm) _buildFinishForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C2E), Color(0xFF2A2A3E)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6A00).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bug_report,
                  color: Color(0xFFFF6A00),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Información de Debug',
                style: TextStyle(
                  color: Color(0xFFFF6A00),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDebugItem(
                  'Pasos',
                  '$_currentSteps',
                  Icons.directions_walk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDebugItem(
                  'Distancia',
                  '${_totalDistanceMeters.toStringAsFixed(2)}m',
                  Icons.straighten,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDebugItem(
                  'Latitud',
                  '${_lastLatitude.toStringAsFixed(6)}',
                  Icons.location_on,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDebugItem(
                  'Longitud',
                  '${_lastLongitude.toStringAsFixed(6)}',
                  Icons.location_on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebugItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[400], size: 12),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ElevatedButton(
        onPressed: _startTraining,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6A00),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Iniciar entrenamiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ElevatedButton(
        onPressed: _finishTraining,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stop, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Finalizar entrenamiento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF6A00).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalles del entrenamiento',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Tipo de entrenamiento
          _buildCompactDropdown(
            label: 'Tipo',
            value: _selectedTrainingType,
            items: trainingTypes,
            onChanged: (val) => setState(() => _selectedTrainingType = val),
          ),
          const SizedBox(height: 8),

          // Tipo de terreno
          _buildCompactDropdown(
            label: 'Terreno',
            value: _selectedTerrainType,
            items: terrainTypes,
            onChanged: (val) => setState(() => _selectedTerrainType = val),
          ),
          const SizedBox(height: 8),

          // Notas
          _buildCompactTextField(
            controller: _notesController,
            label: 'Notas (opcional)',
          ),
          const SizedBox(height: 12),

          // Botón de guardar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSaveTraining,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDropdown({
    required String label,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                items:
                    items
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: onChanged,
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF1C1C2E),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 16,
                ),
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
