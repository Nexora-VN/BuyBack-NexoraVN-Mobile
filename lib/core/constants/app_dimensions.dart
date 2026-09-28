import 'package:flutter/material.dart';

abstract class AppDimensions {
  // Spacing & Margins
  static const double unitXs = 4.0;
  static const double unitSm = 8.0;
  static const double unitMd = 16.0;
  static const double unitLg = 24.0;
  static const double unitXl = 32.0;

  static const double marginMobile = 16.0;
  static const double gutter = 16.0;

  // Touch Target
  static const double minTouchTarget = 44.0;

  // Border Radii
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusControl = 12.0; // Input & Buttons
  static const double radiusCard = 16.0;    // Main Cards & Containers
  static const double radiusPill = 999.0;   // Status Badges

  // BorderRadius helpers
  static final BorderRadius roundedControl = BorderRadius.circular(radiusControl);
  static final BorderRadius roundedCard = BorderRadius.circular(radiusCard);
  static final BorderRadius roundedPill = BorderRadius.circular(radiusPill);
}
