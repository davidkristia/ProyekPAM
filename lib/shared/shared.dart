import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double defaultMargin = 24.0;

final Color primaryColor = Color.fromARGB(255, 16, 124, 134);
final Color secondaryColor = Color(0xFFFFDE69);
final Color dangerColor = Color.fromARGB(255, 41, 2, 2);
final Color blackColor = Color(0xff050522);
final Color whiteColor = Colors.white;

final TextStyle dangerTextStyle = GoogleFonts.roboto(
  fontSize: 36,
  color: dangerColor,
  fontWeight: FontWeight.w500,
);

final TextStyle whiteTextStyle = GoogleFonts.poppins(
  fontSize: 14,
  color: whiteColor,
  fontWeight: FontWeight.w500,
);
