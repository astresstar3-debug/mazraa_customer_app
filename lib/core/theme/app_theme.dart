import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppColors {
  static const forest = Color(0xFF155A37);
  static const forestDark = Color(0xFF0D4328);
  static const forestSoft = Color(0xFFE9F0E5);
  static const terracotta = Color(0xFFC76532);
  static const terracottaSoft = Color(0xFFF8E9DF);
  static const ivory = Color(0xFFFCFAF2);
  static const surface = Color(0xFFFFFDF7);
  static const border = Color(0xFFE8E1D2);
  static const text = Color(0xFF173E2B);
  static const muted = Color(0xFF77766D);
  static const success = Color(0xFF2E7D4B);
  static const warning = Color(0xFFC7792E);
  static const error = Color(0xFFC94E28);
  static const disabled = Color(0xFFC7C8BE);
  static const green = forest;
  static const greenLight = success;
  static const orange = terracotta;
  static const cream = ivory;
  static const sand = forestSoft;
}

@immutable
class MazraaTheme extends ThemeExtension<MazraaTheme> {
  const MazraaTheme({
    required this.cardShadow,
    required this.pagePadding,
    required this.cardRadius,
    required this.controlRadius,
  });
  final List<BoxShadow> cardShadow;
  final EdgeInsetsDirectional pagePadding;
  final double cardRadius;
  final double controlRadius;

  @override
  MazraaTheme copyWith({
    List<BoxShadow>? cardShadow,
    EdgeInsetsDirectional? pagePadding,
    double? cardRadius,
    double? controlRadius,
  }) => MazraaTheme(
    cardShadow: cardShadow ?? this.cardShadow,
    pagePadding: pagePadding ?? this.pagePadding,
    cardRadius: cardRadius ?? this.cardRadius,
    controlRadius: controlRadius ?? this.controlRadius,
  );

  @override
  MazraaTheme lerp(covariant MazraaTheme? other, double t) {
    if (other == null) return this;
    return MazraaTheme(
      cardShadow: t < .5 ? cardShadow : other.cardShadow,
      pagePadding: EdgeInsetsDirectional.lerp(
        pagePadding,
        other.pagePadding,
        t,
      )!,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      controlRadius: controlRadius + (other.controlRadius - controlRadius) * t,
    );
  }
}

abstract final class AppTheme {
  static const _extension = MazraaTheme(
    cardShadow: [
      BoxShadow(color: Color(0x120D4328), blurRadius: 14, offset: Offset(0, 3)),
    ],
    pagePadding: EdgeInsetsDirectional.fromSTEB(16, 10, 16, 20),
    cardRadius: 16,
    controlRadius: 13,
  );

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: dark ? const Color(0xFF7BCB99) : AppColors.forest,
      onPrimary: Colors.white,
      primaryContainer: dark ? const Color(0xFF174B31) : AppColors.forestSoft,
      onPrimaryContainer: dark ? Colors.white : AppColors.forestDark,
      secondary: AppColors.terracotta,
      onSecondary: Colors.white,
      secondaryContainer: dark
          ? const Color(0xFF5C3322)
          : AppColors.terracottaSoft,
      onSecondaryContainer: dark ? Colors.white : AppColors.terracotta,
      error: AppColors.error,
      onError: Colors.white,
      surface: dark ? const Color(0xFF17211B) : AppColors.surface,
      onSurface: dark ? const Color(0xFFECEDE8) : AppColors.text,
      outline: dark ? const Color(0xFF536057) : AppColors.border,
      shadow: const Color(0x220D4328),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );
    return base.copyWith(
      scaffoldBackgroundColor: dark ? const Color(0xFF111A15) : AppColors.ivory,
      textTheme: base.textTheme
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface)
          .copyWith(
            displaySmall: TextStyle(
              fontSize: 30,
              height: 1.25,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            headlineSmall: TextStyle(
              fontSize: 23,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            titleLarge: TextStyle(
              fontSize: 19,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            bodyLarge: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: scheme.onSurface,
            ),
            bodyMedium: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: scheme.onSurface,
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline.withValues(alpha: .78)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          side: BorderSide(color: scheme.primary),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 10,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : AppColors.muted,
          ),
        ),
      ),
      dividerColor: scheme.outline,
      extensions: const [_extension],
    );
  }
}
