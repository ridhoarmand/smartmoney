import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade package to version 8.0.1.
///
/// Use in [MaterialApp] like this:
///
/// MaterialApp(
///  theme: AppTheme.light,
///  darkTheme: AppTheme.dark,
///  :
/// );
sealed class AppTheme {
  // The defined light theme.
  static ThemeData light = FlexThemeData.light(
    colors: const FlexSchemeColor(
      // Custom
      primary: Color(0xff695f00),
      primaryContainer: Color(0xfff3e47f),
      primaryLightRef: Color(0xff695f00),
      secondary: Color(0xff7c7b16),
      secondaryContainer: Color(0xfff8f591),
      secondaryLightRef: Color(0xff7c7b16),
      tertiary: Color(0xff375f97),
      tertiaryContainer: Color(0xffd5e3ff),
      tertiaryLightRef: Color(0xff375f97),
      appBarColor: Color(0xfff8f591),
      error: Color(0xffba1a1a),
      errorContainer: Color(0xffffdad6),
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
      useError: true,
    ),
    tones: FlexSchemeVariant.ultraContrast.tones(Brightness.light),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The defined dark theme.
  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      // Custom
      primary: Color(0xffd8c84f),
      primaryContainer: Color(0xff4f4700),
      primaryLightRef: null,
      secondary: Color(0xffe9e784),
      secondaryContainer: Color(0xff333200),
      secondaryLightRef: null,
      tertiary: Color(0xffa7c8ff),
      tertiaryContainer: Color(0xff1b477e),
      tertiaryLightRef: null,
      appBarColor: Color(0xfff8f591),
      error: Color(0xffffb4ab),
      errorContainer: Color(0xff93000a),
    ),
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
      navigationRailLabelType: NavigationRailLabelType.all,
    ),
    keyColors: const FlexKeyColors(
      useSecondary: true,
      useTertiary: true,
      useError: true,
    ),
    tones: FlexSchemeVariant.ultraContrast.tones(Brightness.dark),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
