import 'package:flutter/material.dart';
import 'package:lw_app/Models/Event/event.dart';
import 'package:lw_app/Models/Event/event_type.dart';
import 'package:lw_app/Utils/date_formatter.dart';
import 'package:add_2_calendar_new/add_2_calendar_new.dart' as calendar;
import 'package:cloudinary_flutter/image/cld_image.dart';

class CourseDetailPage extends StatelessWidget {
  final Event course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Hero Background Image
          SizedBox(
            height: size.height * 0.45,
            width: double.infinity,
            child: Hero(
              tag: 'course_image_${course.id}',
              child: CldImageWidget(
                publicId: course.bannerPublicId ?? 'samples/cloudinary-icon',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            height: size.height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  theme.scaffoldBackgroundColor.withValues(alpha: 0.2),
                  theme.scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.45),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24.0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    course.category,
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 48),
                      
                      // Info Grid/List
                      _buildInfoTile(
                        context,
                        Icons.calendar_today_rounded,
                        "Begin Datum",
                        "${course.day} ${DateFormatter.formatDate(course.startDate)}",
                      ),
                      if (course.endDate != null)
                        _buildInfoTile(
                          context,
                          Icons.event_note_rounded,
                          "Eind Datum",
                          DateFormatter.formatDate(course.endDate),
                        ),
                      _buildInfoTile(
                        context,
                        Icons.access_time_rounded,
                        "Tyd",
                        DateFormatter.formatTime(course.time),
                      ),
                      
                      const SizedBox(height: 32),
                      Text(
                        "Beskrywing",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        course.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _addToCalendar(),
                          icon: const Icon(Icons.event_available_rounded),
                          label: const Text("Voeg by Kalender"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Integrated Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.hintColor,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addToCalendar() {
    try {
      if (course.startDate == null) return;

      // Parse base date
      final baseDate = DateTime.parse(course.startDate!);

      // Remove timezone from time
      final cleanTime = course.time.split('+').first;
      final timeParts = cleanTime.split(':');

      final startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      final endDateTime = startDateTime.add(const Duration(hours: 1));

      calendar.Recurrence? recurrence;
      if (course.type != EventType.ONCE) {
        calendar.Frequency frequency;
        if (course.type == EventType.DAILY) {
          frequency = calendar.Frequency.daily;
        } else if (course.type == EventType.WEEKLY) {
          frequency = calendar.Frequency.weekly;
        } else if (course.type == EventType.MONTHLY) {
          frequency = calendar.Frequency.monthly;
        } else if (course.type == EventType.YEARLY) {
          frequency = calendar.Frequency.yearly;
        } else {
          frequency = calendar.Frequency.weekly; // Default to weekly
        }

        recurrence = calendar.Recurrence(
          frequency: frequency,
          interval: 1,
          endDate: course.endDate != null ? DateTime.parse(course.endDate!) : null,
        );
      }

      final calendar.Event calEvent = calendar.Event(
        title: course.title,
        description: course.description,
        location: 'Lewende Woord Paarl',
        startDate: startDateTime,
        endDate: endDateTime,
        allDay: false,
        recurrence: recurrence,
      );

      calendar.Add2Calendar.addEvent2Cal(calEvent);
    } catch (e) {
      debugPrint("Error adding to calendar: $e");
    }
  }
}
