import 'package:flutter/material.dart';

// ============================================
// পুরো App-এর রং এখানেই। Light আর Dark দুই সেট। কোনো Screen
// আর নিজের মতো রং বানাবে না, সবাই এখান থেকে নেবে
//
// ThemeExtension কেন: Flutter-এর Theme-এর ভিতরে নিজের রং
// ঢোকানোর স্ট্যান্ডার্ড উপায়। Theme বদলালে (Light <-> Dark) যে
// Widget এই রং ব্যবহার করছে, সে নিজে থেকেই নতুন রঙে আঁকা হয়
// ============================================
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bg; // পুরো Screen-এর পটভূমি
  final Color surface; // Card, Sheet, Dialog-এর পটভূমি
  final Color border; // পাতলা সীমারেখা (Shadow-এর বদলে)
  final Color ink; // প্রধান লেখা
  final Color muted; // দ্বিতীয় স্তরের লেখা
  final Color faint; // হালকা লেখা (Label, ছোট Caption)
  final Color subtle; // আরও হালকা (Hint, Placeholder)
  final Color field; // Input Field-এর ভরাট রং
  final Color track; // Progress Bar-এর খালি অংশ
  final Color accent; // ভরাট Button/Card-এর রং (উপরে সাদা লেখা)
  final Color accentFg; // Surface-এর উপরে Text/Icon/Bar-এর Accent
  final Color danger; // লাল সতর্কতা
  final Color shadeEnd; // Chart-এর ফিকে প্রান্তের রং

  const AppColors({
    required this.bg,
    required this.surface,
    required this.border,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.subtle,
    required this.field,
    required this.track,
    required this.accent,
    required this.accentFg,
    required this.danger,
    required this.shadeEnd,
  });

  // ---- Light: এতদিন যে রংগুলো ব্যবহার করছিলাম, হুবহু সেগুলোই ----
  static const light = AppColors(
    bg: Color(0xFFFAFAF8),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE5E3DD),
    ink: Color(0xFF1A1A1A),
    muted: Color(0x8A000000), // আগের Colors.black54
    faint: Color(0x73000000), // আগের Colors.black45
    subtle: Color(0x61000000), // আগের Colors.black38
    field: Color(0xFFF5F4F0),
    track: Color(0xFFEFEEE9),
    accent: Color(0xFF1B4332),
    accentFg: Color(0xFF1B4332),
    danger: Color(0xFFB3261E),
    shadeEnd: Color(0xFFC9D8CF),
  );

  // ---- Dark: সবুজ-ঘেঁষা গাঢ় ধূসর, Pure Black না ----
  static const dark = AppColors(
    bg: Color(0xFF121413),
    surface: Color(0xFF1B1E1C),
    border: Color(0xFF2C312E),
    ink: Color(0xFFECEAE4),
    muted: Color(0xFFA8ACA8),
    faint: Color(0xFF8A8E8A),
    subtle: Color(0xFF6C706C),
    field: Color(0xFF242826),
    track: Color(0xFF2A2F2C),
    accent: Color(0xFF2D6A4F), // সাদা লেখার নিচে যথেষ্ট কনট্রাস্ট
    accentFg: Color(0xFF7DB596), // গাঢ় পটভূমিতে পড়ার মতো হালকা সবুজ
    danger: Color(0xFFE57368),
    shadeEnd: Color(0xFF33473C),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? border,
    Color? ink,
    Color? muted,
    Color? faint,
    Color? subtle,
    Color? field,
    Color? track,
    Color? accent,
    Color? accentFg,
    Color? danger,
    Color? shadeEnd,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      subtle: subtle ?? this.subtle,
      field: field ?? this.field,
      track: track ?? this.track,
      accent: accent ?? this.accent,
      accentFg: accentFg ?? this.accentFg,
      danger: danger ?? this.danger,
      shadeEnd: shadeEnd ?? this.shadeEnd,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      field: Color.lerp(field, other.field, t)!,
      track: Color.lerp(track, other.track, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentFg: Color.lerp(accentFg, other.accentFg, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      shadeEnd: Color.lerp(shadeEnd, other.shadeEnd, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
