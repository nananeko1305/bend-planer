import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The three looks, from the design canvas. All are dark: the app is used at
/// night, at the gig.
const Map<SkinId, AppColors> kSkins = {
  // A · Bina: a concert stage, magenta and violet lights, orange for tips.
  SkinId.bina: AppColors(
    skin: SkinId.bina,
    primary: Color(0xFFFF2E97),
    secondary: Color(0xFF7C3AED),
    tip: Color(0xFFFF8A00),
    tipText: Color(0xFFFFB866),
    background: Color(0xFF0B0614),
    surface: Color(0xFF17121F),
    surfaceHigh: Color(0xFF221A2E),
    border: Color(0xFF2E2540),
    ink: Color(0xFFF7F3FF),
    muted: Color(0xFFBDB3D1),
    onPrimary: Colors.white,
    buttonGradient: [Color(0xFFE0157F), Color(0xFF7C3AED)],
    heroGradient: [Color(0xFFFF2E97), Color(0xFFFF5A5F), Color(0xFFFF8A00)],
    displayFont: 'Unbounded',
    bodyFont: 'Manrope',
    radius: 20,
  ),
  // B · Neon: a club at night, pink and cyan tubes.
  SkinId.neon: AppColors(
    skin: SkinId.neon,
    primary: Color(0xFFFF4FD8),
    secondary: Color(0xFF2DE2FF),
    tip: Color(0xFFFFB547),
    tipText: Color(0xFFFFD08A),
    background: Color(0xFF06070D),
    surface: Color(0xFF0D1019),
    surfaceHigh: Color(0xFF151A27),
    border: Color(0xFF232A3D),
    ink: Color(0xFFEEF4FF),
    muted: Color(0xFFA9B4C8),
    onPrimary: Color(0xFF12060F),
    buttonGradient: [Color(0xFFFF4FD8), Color(0xFFFF8BE6)],
    heroGradient: null,
    displayFont: 'TiltNeon',
    bodyFont: 'Outfit',
    radius: 18,
    glow: [
      Shadow(color: Color(0xCCFF4FD8), blurRadius: 8),
      Shadow(color: Color(0x88FF4FD8), blurRadius: 18),
    ],
  ),
  // C · Zlato: black and gold, a vinyl record.
  SkinId.zlato: AppColors(
    skin: SkinId.zlato,
    primary: Color(0xFFE0BE63),
    secondary: Color(0xFFC9A64F),
    tip: Color(0xFFE0BE63),
    tipText: Color(0xFFE0BE63),
    background: Color(0xFF0D0B08),
    surface: Color(0xFF15120D),
    surfaceHigh: Color(0xFF1E1A12),
    border: Color(0xFF3A3427),
    ink: Color(0xFFF4ECDD),
    muted: Color(0xFFB8AD99),
    onPrimary: Color(0xFF1A1408),
    buttonGradient: [Color(0xFFF2D98A), Color(0xFFC9A64F)],
    heroGradient: [Color(0xFFF7E7B0), Color(0xFFE0BE63), Color(0xFFB48C33)],
    displayFont: 'PlayfairDisplay',
    bodyFont: 'Manrope',
    radius: 14,
  ),
};
