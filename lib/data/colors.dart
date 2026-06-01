// lib/data/colors.dart
import 'package:flutter/material.dart';

class HawkinsColors {
  // Cores baseadas na escala de consciência de Hawkins
  static const Map<String, Color> energyColors = {
    'Ativa': Color(0xFFFF6B35),    // Laranja energético (Ação)
    'Passiva': Color(0xFF4ECDC4),  // Verde-água calmo (Receptividade)
  };

  static const Map<String, Color> flowGradient = {
    'Fácil': Color(0xFF95E1D3),        // Verde claro
    'Médio': Color(0xFFFFD93D),        // Amarelo dourado
    'Difícil': Color(0xFFFF6B6B),      // Vermelho coral
    'Fácil – Médio': Color(0xFFA8E6CF), // Verde médio
    'Médio – Difícil': Color(0xFFFF8B6B), // Laranja intenso
  };

  static const Map<String, List<Color>> organGradients = {
    'Mente': [Color(0xFF6C5CE7), Color(0xFFA8A4E6)],       // Roxo mente
    'Corpo': [Color(0xFFFF6B35), Color(0xFFFFA07A)],       // Laranja corpo
    'Corpo/Mente': [Color(0xFF00B894), Color(0xFF55EFC4)], // Verde integração
    'Espírito': [Color(0xFF9B59B6), Color(0xFFD7BDE2)],    // Violeta espírito
  };

  // Fundo neumórfico
  static const Color background = Color(0xFFE6EEF0);
  static const Color lightShadow = Color(0xFFFFFFFF);
  static const Color darkShadow = Color(0xFFC8D6DB);
}