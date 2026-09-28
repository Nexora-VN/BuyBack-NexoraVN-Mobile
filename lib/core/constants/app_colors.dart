import 'package:flutter/material.dart';

/// Soft-Fintech color tokens according to DESIGN/nexora_soft_fintech/DESIGN.md
abstract class AppColors {
  // Brand & Accent
  static const Color primary = Color(0xFFA8245E);
  static const Color primaryContainer = Color(0xFFC83F77);
  static const Color brandPressed = Color(0xFFA72D61);
  static const Color secondary = Color(0xFFA82E65);
  static const Color secondaryContainer = Color(0xFFFF74AA);
  static const Color softSurface = Color(0xFFFBE4ED);

  // Surfaces & Backgrounds
  static const Color surface = Color(0xFFFFF8F8);
  static const Color background = Color(0xFFFFF8F8);
  static const Color pageTint = Color(0xFFFFF5F9);
  static const Color canvas = Color(0xFFFFFAFC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFFBE2EC);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFEEDDE5);
  static const Color outline = Color(0xFF8A7177);
  static const Color outlineVariant = Color(0xFFDDBFC6);

  // Typography Colors
  static const Color textPrimary = Color(0xFF25181E);
  static const Color textSecondary = Color(0xFF725F68);
  static const Color textDisabled = Color(0xFFA6949D);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Semantic Status: Success (AVAILABLE, PAID, COMPLETED)
  static const Color statusSuccessText = Color(0xFF16845B);
  static const Color statusSuccessBg = Color(0xFFE9F7F1);

  // Semantic Status: Pending / Warning (PENDING, ESTIMATED, PROCESSING)
  static const Color statusPendingText = Color(0xFFA96813);
  static const Color statusPendingBg = Color(0xFFFFF5DC);

  // Semantic Status: Info / Validated (VALIDATED)
  static const Color statusInfoText = Color(0xFF3568C9);
  static const Color statusInfoBg = Color(0xFFEAF1FF);

  // Semantic Status: Danger / Rejected (REJECTED, FAILED, REVERSED)
  static const Color statusDangerText = Color(0xFFC23B55);
  static const Color statusDangerBg = Color(0xFFFDECEF);

  // Semantic Status: Review / Mismatch (MANUAL_REVIEW, MISMATCH)
  static const Color statusReviewText = Color(0xFF7752A8);
  static const Color statusReviewBg = Color(0xFFF2ECFA);
}
