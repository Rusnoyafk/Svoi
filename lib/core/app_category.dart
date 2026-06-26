import 'package:flutter/material.dart';

/// Категорії оголошень
enum AnnouncementCategory {
  services(
    label: 'Послуги',
    icon: Icons.handyman_outlined,
    color: Color(0xFF6C4DE6),
  ),
  housing(
    label: 'Житло',
    icon: Icons.home_outlined,
    color: Color(0xFF1E88E5),
  ),
  work(
    label: 'Робота',
    icon: Icons.work_outline,
    color: Color(0xFF43A047),
  ),
  kids(
    label: 'Діти',
    icon: Icons.child_care_outlined,
    color: Color(0xFFE53935),
  ),
  items(
    label: 'Речі',
    icon: Icons.shopping_bag_outlined,
    color: Color(0xFFFF7043),
  ),
  documents(
    label: 'Документи',
    icon: Icons.description_outlined,
    color: Color(0xFF00ACC1),
  ),
  transport(
    label: 'Транспорт',
    icon: Icons.directions_car_outlined,
    color: Color(0xFF5E35B1),
  ),
  animals(
    label: 'Тварини',
    icon: Icons.pets_outlined,
    color: Color(0xFF6D4C41),
  ),
  beauty(
    label: 'Краса',
    icon: Icons.spa_outlined,
    color: Color(0xFFD81B60),
  ),
  legal(
    label: 'Юридичне',
    icon: Icons.gavel_outlined,
    color: Color(0xFF546E7A),
  );

  const AnnouncementCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// Категорії івентів
enum EventCategory {
  meetups(
    label: 'Зустрічі',
    icon: Icons.people_outline,
    color: Color(0xFF6C4DE6),
  ),
  sports(
    label: 'Спорт',
    icon: Icons.sports_soccer_outlined,
    color: Color(0xFF43A047),
  ),
  kids(
    label: 'Діти',
    icon: Icons.child_friendly_outlined,
    color: Color(0xFFE53935),
  ),
  holidays(
    label: 'Свята',
    icon: Icons.celebration_outlined,
    color: Color(0xFFFF7043),
  ),
  education(
    label: 'Навчання',
    icon: Icons.school_outlined,
    color: Color(0xFF1E88E5),
  ),
  help(
    label: 'Допомога',
    icon: Icons.volunteer_activism_outlined,
    color: Color(0xFFD81B60),
  ),
  culture(
    label: 'Культура',
    icon: Icons.museum_outlined,
    color: Color(0xFF5E35B1),
  ),
  entertainment(
    label: 'Розваги',
    icon: Icons.local_activity_outlined,
    color: Color(0xFF00ACC1),
  ),
  travel(
    label: 'Подорожі',
    icon: Icons.flight_outlined,
    color: Color(0xFF00897B),
  ),
  business(
    label: 'Бізнес',
    icon: Icons.business_center_outlined,
    color: Color(0xFF546E7A),
  );

  const EventCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
