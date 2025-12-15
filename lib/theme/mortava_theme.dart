// Tema global Mortava Shop 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MortavaColors {
  // Warna teks utama
  static const Color darkText = Color(0xFF2C1B10);
  static const Color softBrownText = Color(0xFF4A3424);

  // Oranye / kuning yang sering dipakai
  static const Color softOrangeBorder = Color(0xFFFFB74D); // input border
  static const Color bottomNavBorder = Color(0xFFFFD54F);  // bottom nav
  static const Color primaryOrange = Color(0xFFF57C00);    // accent utama

  // Background cream login/register
  static const Color bgTopAuth = Color(0xFFFFFBF6);
  static const Color bgBottomAuth = Color(0xFFFFF0DA);

  // Background cream marketplace
  static const Color bgTopMarketplace = Color(0xFFFFFCF5);
  static const Color bgBottomMarketplace = Color(0xFFFFF4D8);
}

class MortavaGradients {
  // Background login/register
  static const LinearGradient authBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      MortavaColors.bgTopAuth,
      MortavaColors.bgBottomAuth,
    ],
  );

  // Background marketplace
  static const LinearGradient marketplaceBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      MortavaColors.bgTopMarketplace,
      MortavaColors.bgBottomMarketplace,
    ],
  );

  // Card login & register
  static const LinearGradient authCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE6C5), // peach
      Color(0xFFFFCC8F), // warm orange 
    ],
  );

  // Tombol utama: kuning gradient
  static const LinearGradient primaryButton = LinearGradient(
    colors: [
      Color(0xFFFFF59D),
      Color(0xFFFFEB3B),
    ],
  );

  // Frame card produk di marketplace
  static const LinearGradient productCardFrame = LinearGradient(
    colors: [
      Color(0xFFFFF9C4), // kuning lembut
      Color(0xFFFFE0B2), // oranye kuning lembut
    ],
  );
}

class MortavaTextStyles {
  // Title besar (login)
  static TextStyle headingLarge() => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: MortavaColors.darkText,
      );

  // Title medium (register)
  static TextStyle headingMedium() => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: MortavaColors.darkText,
      );

  // Body kecil (subtitle)
  static TextStyle bodySmall([Color? color]) => GoogleFonts.poppins(
        fontSize: 13,
        color: color ?? Colors.brown.withOpacity(0.7),
        height: 1.4,
      );

  // Label field
  static TextStyle labelSmall([Color? color]) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color ?? MortavaColors.softBrownText,
      );
}

class MortavaDecorations {
  // Background login/register
  static BoxDecoration authBackgroundBox() =>
      const BoxDecoration(gradient: MortavaGradients.authBackground);

  // Background marketplace
  static BoxDecoration marketplaceBackgroundBox() =>
      const BoxDecoration(gradient: MortavaGradients.marketplaceBackground);

  // Card login/register
  static BoxDecoration authCardBox() => BoxDecoration(
        gradient: MortavaGradients.authCard,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            blurRadius: 36,
            spreadRadius: -4,
            offset: const Offset(0, 18),
            color: Colors.orange.withOpacity(0.25),
          ),
        ],
      );

  // Card register sama dengan card login 
  static BoxDecoration registerCardBox() => authCardBox();

  // Outer card produk (frame gradient)
  static BoxDecoration productOuterCardBox() => BoxDecoration(
        gradient: MortavaGradients.productCardFrame,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            spreadRadius: -6,
            color: Colors.orange.withOpacity(0.25),
            offset: const Offset(0, 8),
          ),
        ],
      );

  // Inner card produk (putih krem)
  static BoxDecoration productInnerCardBox() => BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(18),
      );

  // Container untuk bottom nav (border + shadow)
  static BoxDecoration bottomNavBox() => BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(
            color: MortavaColors.bottomNavBorder,
            width: 1.4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            spreadRadius: -4,
            offset: const Offset(0, -4),
            color: Colors.orange.withOpacity(0.25),
          ),
        ],
      );
}

class MortavaInputs {
  // Dekorasi input umum (login & register)
  static InputDecoration roundedInput({
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    const borderRadius = 30.0;

    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.black38,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: MortavaColors.softOrangeBorder,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: MortavaColors.softOrangeBorder,
          width: 1.6,
        ),
      ),
    );
  }
}
