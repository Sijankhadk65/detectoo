import 'package:flutter/material.dart';

/// Represents a plant owned by the user.
class Plant {
  final String name;
  final IconData icon;
  final PlantHealthStatus healthStatus;
  final String lastWatered;

  const Plant({
    required this.name,
    required this.icon,
    required this.healthStatus,
    required this.lastWatered,
  });
}

/// Health status of a plant.
enum PlantHealthStatus {
  healthy('Healthy', Color(0xFF2E7D32)),
  needsAttention('Needs Attention', Color(0xFFE65100)),
  recovering('Recovering', Color(0xFF1565C0));

  final String label;
  final Color color;

  const PlantHealthStatus(this.label, this.color);
}
