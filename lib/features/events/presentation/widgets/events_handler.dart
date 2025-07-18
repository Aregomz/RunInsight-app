import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/events_bloc.dart';
import '../bloc/events_event.dart';
import '../bloc/events_state.dart';
import 'event_popup_dialog.dart';
import '../../data/services/events_service.dart';
import '../../domain/entities/event.dart';

class EventsHandler extends StatefulWidget {
  final Widget child;

  const EventsHandler({
    super.key,
    required this.child,
  });

  @override
  State<EventsHandler> createState() => _EventsHandlerState();
}

class _EventsHandlerState extends State<EventsHandler> {
  @override
  void initState() {
    super.initState();
    // Cargar eventos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsBloc>().add(const LoadFutureEvents());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventsBloc, EventsState>(
      listener: (context, state) {
        if (state is EventsLoaded) {
          _checkAndShowEvents(state.events);
        }
      },
      child: widget.child,
    );
  }

  void _checkAndShowEvents(List<Event> events) {
    print('Eventos recibidos en EventsHandler: ${events.length}');
    for (final e in events) {
      print('Evento: id=${e.id}, fecha=${e.dateEvent}, activo=${e.isCurrentlyActive}');
    }
    final activeEvent = EventsService.getFirstActiveEvent(events);
    print('Evento activo encontrado: $activeEvent');
    if (activeEvent != null) {
      _showEventDialog(activeEvent);
    }
  }

  void _showEventDialog(Event event) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EventPopupDialog(
        event: event,
        onDismiss: () {
          // Cerrar el diálogo
          Navigator.of(context).pop();
        },
      ),
    );
  }
} 