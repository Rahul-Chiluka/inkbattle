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
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(255, 255, 255, 0.8),
              Color.fromRGBO(9, 189, 255, 0.8)
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
                  // Only show icon/image if NOT filled (selected)
                  if (!isFilled) ...[
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
                    Icons.keyboard_arrow_down_rounded,
                    size: 24.sp,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Previous design for other screens (game_room, multiplayer, create_room)
      // return Container(
      //   width: width,
      //   height: height ?? (isTablet ? 52.h : 45.h),
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(25.r),
      //     border: Border.all(
      //       color: isFilled ? Colors.white : Colors.grey,
      //       width: isTablet ? 1.5.w : 1.w,
      //     ),
      //     color: const Color(0xFF0E0E0E),
      //   ),
      //   child: Material(
      //     color: Colors.transparent,
      //     child: InkWell(
      //       borderRadius: BorderRadius.circular(25.r),
      //       onTap: onCountrySelected != null ? () => _showCountryPicker(context) : null,
      //       child: Padding(
      //         padding: EdgeInsets.symmetric(
      //           horizontal: isTablet ? 14.w : 10.w,
      //           vertical: isTablet ? 12.h : 10.h,
      //         ),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.start,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             if (imageUrl != null) ...[
      //               Image.asset(
      //                 imageUrl!,
      //                 height: isTablet ? 22.h : 18.h,
      //                 width: isTablet ? 22.w : 18.w,
      //               ),
      //               SizedBox(width: isTablet ? 10.w : 8.w),
      //             ] else if (icon != null) ...[
      //               Icon(
      //                 icon,
      //                 color: iconColor ?? Colors.white70,
      //                 size: isTablet ? 22.sp : 18.sp,
      //               ),
      //               SizedBox(width: isTablet ? 10.w : 8.w),
      //             ],
      //             Expanded(
      //               child: Row(
      //                 children: [
      //                   if (isFilled) ...[
      //                     Text(
      //                       getCountryFlag(countryCode),
      //                       style: TextStyle(fontSize: isTablet ? 18.sp : 16.sp),
      //                     ),
      //                     SizedBox(width: 8.w),
      //                   ],
      //                   Expanded(
      //                     child: Text(
      //                       displayText,
      //                       overflow: TextOverflow.ellipsis,
      //                       maxLines: 1,
      //                       softWrap: false,
      //                       textAlign: TextAlign.left,
      //                       style: GoogleFonts.lato(
      //                         color: isFilled ? Colors.white : Colors.white54,
      //                         fontSize: isTablet ? 15.sp : 13.sp,
      //                         fontWeight: FontWeight.w600,
      //                         height: 1.2,
      //                       ),
      //                     ),
      //                   ),
      //                 ],
      //               ),
      //             ),
      //             SizedBox(width: isTablet ? 8.w : 6.w),
      //             Icon(
      //               Icons.arrow_drop_down,
      //               color: Colors.white70,
      //               size: isTablet ? 20.sp : 16.sp,
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // );
      return Container(
        width: width,
        height: height ?? (isTablet ? 65.0 : 45.h), // Force height to match other pills
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: Colors.white, // Always white to match others
            width: isTablet ? 2.0 : 1.w, // Match the 2.0 tablet width from MultiplayerScreen
          ),
          color: const Color(0xFF0E0E0E),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25.r),
            onTap: () => _showCountryPicker(context),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20.0 : 10.w, // Increased horizontal padding
                // Removing vertical padding and letting Row + Height handle centering
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center, // Vertically centers everything
                children: [
                  // Use the public icon if no specific image is provided
                  if (!isFilled) ...[
                    Icon(
                      icon ?? Icons.public,
                      color: iconColor ?? Colors.lightGreenAccent,
                      size: isTablet ? 32.0 : 18.sp, // Increased size to match other pills
                    ),
                    SizedBox(width: isTablet ? 12.0 : 8.w),
                  ],
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isFilled) ...[
                          Text(
                            getCountryFlag(countryCode),
                            style: TextStyle(fontSize: isTablet ? 22.sp : 18.sp),
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
                              fontSize: isTablet ? 22.0 : 13.sp, // Match the 22.0 font size
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isTablet ? 10.0 : 6.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded, // Use the rounded arrow to match others
                    color: Colors.white70,
                    size: isTablet ? 32.0 : 16.sp, // Match arrow size
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
      showPhoneCode: false,
      showSearch: true, // Enable search functionality
      searchAutofocus: true, // Auto-focus search field for better UX
      onSelect: (Country country) {
        onCountrySelected(country.countryCode);
      },
      countryListTheme: CountryListThemeData(
        backgroundColor: const Color(0xFF1A1A2E), // Match SelectionBottomSheet
        flagSize: 28,
        textStyle: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 16.sp, // Match item text size
          fontWeight: FontWeight.normal,
        ),
        searchTextStyle: GoogleFonts.lato(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search', // Match "Search" label
          labelStyle: GoogleFonts.lato(
            color: Colors.white70,
            fontSize: 14.sp,
          ),
          hintText: 'Start typing to search...',
          hintStyle: GoogleFonts.lato(
            color: const Color.fromRGBO(255, 255, 255, 0.52),
            fontSize: 14.sp,
          ),
          prefixIcon: const Icon(
            Icons.search, 
            color: Color.fromRGBO(9, 189, 255, 1) // Cyan
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          filled: true,
          fillColor: Colors.black, // Black fill
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(
              color: Color.fromRGBO(255, 255, 255, 0.2),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: const BorderSide(
              color: Color.fromRGBO(9, 189, 255, 1),
              width: 1.5,
            ),
          ),
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
