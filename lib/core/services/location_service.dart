import 'dart:convert';
import 'package:flutter/services.dart';

/// Модель даних для роботи з локаціями України
class LocationData {
  final List<Oblast> oblasts;
  const LocationData({required this.oblasts});

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        oblasts: (json['oblasts'] as List)
            .map((o) => Oblast.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}

class Oblast {
  final String name;
  final List<Raion> raions;
  const Oblast({required this.name, required this.raions});

  factory Oblast.fromJson(Map<String, dynamic> json) => Oblast(
        name: json['name'] as String,
        raions: (json['raions'] as List)
            .map((r) => Raion.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}

class Raion {
  final String name;
  final List<String> cities;
  const Raion({required this.name, required this.cities});

  factory Raion.fromJson(Map<String, dynamic> json) => Raion(
        name: json['name'] as String,
        cities: List<String>.from(json['cities'] as List),
      );
}

/// Сервіс для роботи з географічними даними України.
/// Завантажує JSON з assets один раз і кешує в пам'яті.
class LocationService {
  LocationData? _cache;

  Future<LocationData> loadLocations() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/ukraine_locations.json');
    _cache = LocationData.fromJson(json.decode(raw) as Map<String, dynamic>);
    return _cache!;
  }

  Future<List<String>> getOblasts() async {
    final data = await loadLocations();
    return data.oblasts.map((o) => o.name).toList();
  }

  Future<List<String>> getRaions(String oblast) async {
    final data = await loadLocations();
    final found = data.oblasts.where((o) => o.name == oblast).firstOrNull;
    if (found == null) return [];
    return found.raions.map((r) => r.name).toList();
  }

  Future<List<String>> getCities(String oblast, String raion) async {
    final data = await loadLocations();
    final foundOblast = data.oblasts.where((o) => o.name == oblast).firstOrNull;
    if (foundOblast == null) return [];
    final foundRaion = foundOblast.raions.where((r) => r.name == raion).firstOrNull;
    if (foundRaion == null) return [];
    return foundRaion.cities;
  }
}
