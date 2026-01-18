import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_picker/country_picker.dart';
import 'package:inkbattle_frontend/constants/app_colors.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';
import 'package:google_fonts/google_fonts.dart';

/// A reusable country picker widget that returns ISO-2 country codes
/// 
/// This widget provides a consistent country selection UI across the app
/// and ensures all countries are supported with ISO-2 standard codes.
class CountryPickerWidget extends StatelessWidget {
  final String? selectedCountryCode; // ISO-2 code (e.g., "US", "IN", "GB")
  final ValueChanged<String?> onCountrySelected; // Callback with ISO-2 code
  final String hintText;
  final String? imageUrl;
  final IconData? icon;
  final Color? iconColor;
  final double? width;
  final double? height;
  final bool isTablet;
  final bool useGradientDesign; // Use gradient design (for profile_edit and guest_signup)

  const CountryPickerWidget({
    super.key,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.hintText = 'Country',
    this.imageUrl,
    this.icon,
    this.iconColor,
    this.width,
    this.height,
    this.isTablet = false,
    this.useGradientDesign = false, // Default to previous design
  });

  /// Get country name from ISO-2 code
  static String? getCountryName(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) return null;
    try {
      final country = Country.parse(countryCode);
      return country.name;
    } catch (e) {
      return null;
    }
  }

  /// Get country flag emoji from ISO-2 code
  static String getCountryFlag(String? countryCode) {
    if (countryCode == null || countryCode.isEmpty) return '🏳️';
    try {
      final country = Country.parse(countryCode);
      return country.flagEmoji;
    } catch (e) {
      return '🏳️';
    }
  }

  /// Check if a country code is valid ISO-2
  static bool isValidCountryCode(String? code) {
    if (code == null || code.isEmpty) return false;
    try {
      Country.parse(code);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final countryCode = selectedCountryCode;
    final countryName = countryCode != null 
        ? getCountryName(countryCode) 
        : null;
    final displayText = countryName ?? hintText;
    final isFilled = countryCode != null && countryCode.isNotEmpty;

    if (useGradientDesign) {
      // Gradient design for profile_edit and guest_signup (matches _buildGradientDropdown)
      return Container(
        width: width,
        alignment: Alignment.center,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(255, 255, 255, 1),
              Color.fromRGBO(9, 189, 255, 1)
            ],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13.r),
            onTap: onCountrySelected != null ? () => _showCountryPicker(context) : null,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13.r),
                color: Colors.black,
              ),
              child: Row(
                children: [
                  if (imageUrl != null) ...[
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Image.asset(
                        imageUrl!,
                        height: isTablet ? 24.h : 21.h,
                        width: isTablet ? 24.w : 21.w,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ] else if (icon != null) ...[
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Icon(
                        icon,
                        color: iconColor ?? Colors.white70,
                        size: isTablet ? 24.sp : 21.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          if (isFilled) ...[
                            Text(
                              getCountryFlag(countryCode),
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            displayText,
                            style: TextStyle(
                              color: isFilled
                                  ? Colors.white
                                  : const Color.fromRGBO(255, 255, 255, 0.52),
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 35.sp,
                    color: const Color.fromRGBO(9, 189, 255, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Previous design for other screens (game_room, multiplayer, create_room)
      return Container(
        width: width,
        height: height ?? (isTablet ? 52.h : 45.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: isFilled ? Colors.white : Colors.grey,
            width: isTablet ? 1.5.w : 1.w,
          ),
          color: const Color(0xFF0E0E0E),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25.r),
            onTap: onCountrySelected != null ? () => _showCountryPicker(context) : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 14.w : 10.w,
                vertical: isTablet ? 12.h : 10.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (imageUrl != null) ...[
                    Image.asset(
                      imageUrl!,
                      height: isTablet ? 22.h : 18.h,
                      width: isTablet ? 22.w : 18.w,
                    ),
                    SizedBox(width: isTablet ? 10.w : 8.w),
                  ] else if (icon != null) ...[
                    Icon(
                      icon,
                      color: iconColor ?? Colors.white70,
                      size: isTablet ? 22.sp : 18.sp,
                    ),
                    SizedBox(width: isTablet ? 10.w : 8.w),
                  ],
                  Expanded(
                    child: Row(
                      children: [
                        if (isFilled) ...[
                          Text(
                            getCountryFlag(countryCode),
                            style: TextStyle(fontSize: isTablet ? 18.sp : 16.sp),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Expanded(
                          child: Text(
                            displayText,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.lato(
                              color: isFilled ? Colors.white : Colors.white54,
                              fontSize: isTablet ? 15.sp : 13.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isTablet ? 8.w : 6.w),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                    size: isTablet ? 20.sp : 16.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      // favorite: <String>['US', 'GB', 'IN', 'CA', 'AU', 'DE', 'FR', 'ES', 'IT', 'JP', 'CN', 'BR', 'MX'],
      showPhoneCode: false,
      showSearch: true, // Enable search functionality
      searchAutofocus: true, // Auto-focus search field for better UX
      onSelect: (Country country) {
        onCountrySelected(country.countryCode);
      },
      countryListTheme: CountryListThemeData(
        flagSize: 28,
        backgroundColor: const Color(0xFF1A1A2E),
        textStyle: GoogleFonts.lato(
          fontSize: 18.sp,
          color: Colors.white,
        ),
        searchTextStyle: GoogleFonts.lato(
          fontSize: 18.sp,
          color: Colors.white,
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search country',
          labelStyle: GoogleFonts.lato(
            color: Colors.white70,
            fontSize: 16.sp,
          ),
          hintText: 'Start typing to search',
          hintStyle: GoogleFonts.lato(
            color: const Color.fromRGBO(255, 255, 255, 0.52),
            fontSize: 16.sp,
          ),
          prefixIcon: const Icon(Icons.search, color: Color.fromRGBO(9, 189, 255, 1)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              width: 3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              width: 3,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(
              color: Color.fromRGBO(9, 189, 255, 1),
              width: 3,
            ),
          ),
          filled: true,
          fillColor: Colors.black,
        ),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
    );
  }
}
