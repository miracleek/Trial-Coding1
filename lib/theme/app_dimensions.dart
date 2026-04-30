import 'package:flutter/material.dart';

/// Responsive dimensions based on screen width.
/// Design baseline: 360px wide (small Android phone).
class AppDimensions {
  final double screenW;
  final double screenH;
  final double safeTop;
  final double safeBottom;

  AppDimensions.of(BuildContext context)
    : screenW = MediaQuery.sizeOf(context).width,
      screenH = MediaQuery.sizeOf(context).height,
      safeTop = MediaQuery.paddingOf(context).top,
      safeBottom = MediaQuery.paddingOf(context).bottom;

  // Scale factor relative to 360px baseline
  double get _s => (screenW / 360).clamp(0.8, 1.4);

  // Padding / spacing
  double get pagePadding => 20 * _s;
  double get cardPadding => 16 * _s;
  double get itemSpacing => 12 * _s;
  double get sectionSpacing => 24 * _s;

  // Font sizes
  double get fontXS => 10 * _s;
  double get fontSM => 12 * _s;
  double get fontMD => 14 * _s;
  double get fontLG => 16 * _s;
  double get fontXL => 18 * _s;
  double get font2XL => 22 * _s;
  double get font3XL => 28 * _s;

  // Border radius
  double get radiusSM => 8 * _s;
  double get radiusMD => 12 * _s;
  double get radiusLG => 16 * _s;
  double get radiusXL => 24 * _s;

  // Icon sizes
  double get iconSM => 16 * _s;
  double get iconMD => 20 * _s;
  double get iconLG => 24 * _s;

  // Component heights
  double get buttonHeight => 52 * _s;
  double get inputHeight => 48 * _s;
  double get avatarRadius => 16 * _s;
  double get cardAvatarRadius => 20 * _s;

  // Chart
  double get chartSize => (screenW * 0.28).clamp(90.0, 140.0);
  double get chartCenterRadius => chartSize * 0.33;
  double get chartRingRadius => chartSize * 0.1;
}
