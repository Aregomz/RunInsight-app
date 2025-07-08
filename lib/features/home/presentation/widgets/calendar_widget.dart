import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = now.weekday; // 1 = lunes, 7 = domingo
    
    // Obtener los días de la semana actual
    final startOfWeek = now.subtract(Duration(days: today - 1));
    final daysOfWeek = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: daysOfWeek.asMap().entries.map((entry) {
          final index = entry.key;
          final date = entry.value;
          final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
          final isCurrentWeek = date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
                               date.isBefore(startOfWeek.add(const Duration(days: 7)));
          
          return Column(
            children: [
              Text(
                _getDayName(index),
                style: TextStyle(
                  color: isToday ? const Color(0xFFFF6A00) : Colors.white70,
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isToday ? const Color(0xFFFF6A00) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isToday ? null : Border.all(
                    color: isCurrentWeek ? Colors.white30 : Colors.white10,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getDayName(int index) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[index];
  }
} 