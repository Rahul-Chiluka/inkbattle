import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:inkbattle_frontend/constants/app_images.dart';
import 'package:inkbattle_frontend/widgets/blue_background_scaffold.dart';
import 'package:inkbattle_frontend/utils/routes/routes.dart';
import 'package:inkbattle_frontend/widgets/custom_svg.dart';
import 'package:inkbattle_frontend/utils/lang.dart';
import 'package:inkbattle_frontend/widgets/country_picker_widget.dart';

class CreateRoom extends StatefulWidget {
  const CreateRoom({super.key});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  int players = 0;
  int coins = 250;

  String? selectedLanguage;
  String? selectedScript;
  String? selectedCountry;
  String? selectedPoints;
  String? selectedCategory;
  String? selectedGamePlay;

  bool voiceEnabled = true;
  bool isPublic = true;

  final List<String> languages = ["English", "Hindi", "Marathi"];
  final List<String> scripts = ["Native", "Roman"];
  // Countries are now handled via CountryPickerWidget with ISO-2 codes
  final List<String> points = ["50", "100", "150", "200"];
  final List<String> categories = ["Animal", "Fruits", "Objects"];
  final List<String> gamePlays = ["1 vs 1", "2 vs 2", "3 vs 3"];

  final List<String> playerNames = ["John", "Arjun", "Rock", "Rajesh"];

  static double get _controlHeight => 45.h;
  static double get _gap => 10.w;

  bool get isFormComplete {
    return selectedLanguage != null &&
        selectedScript != null &&
        selectedCountry != null &&
        selectedPoints != null &&
        selectedCategory != null &&
        selectedGamePlay != null;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 800));
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return BlueBackgroundScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.go(Routes.homeScreen);
                    },
                    child: CustomSvgImage(
                      imageUrl: AppImages.arrow_back,
                      height: 25.h,
                      width: 25.w,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.h,
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final double controlWidth = (constraints.maxWidth - _gap) / 2;

                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: _gap,
                    runSpacing: _gap,
                    children: [
                      _buildGradientDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.wordTheme,
                        value: selectedLanguage,
                        items: languages,
                        imageurl: AppImages.mp1,
                        onChanged: (v) => setState(() => selectedLanguage = v),
                      ),
                      _buildGradientDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.wordScript,
                        value: selectedScript,
                        items: scripts,
                        imageurl: AppImages.mp2,
                        onChanged: (v) => setState(() => selectedScript = v),
                      ),
                      SizedBox(
                        width: controlWidth,
                        child: CountryPickerWidget(
                          selectedCountryCode: selectedCountry,
                          onCountrySelected: (countryCode) => setState(() => selectedCountry = countryCode),
                          hintText: AppLocalizations.country,
                          imageUrl: AppImages.mp4,
                          isTablet: isTablet,
                        ),
                      ),
                      _buildGradientDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.points,
                        value: selectedPoints,
                        items: points,
                        imageurl: AppImages.mp3,
                        onChanged: (v) => setState(() => selectedPoints = v),
                      ),
                      _buildGradientDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.category,
                        value: selectedCategory,
                        items: categories,
                        imageurl: AppImages.mp5,
                        onChanged: (v) => setState(() => selectedCategory = v),
                      ),
                      _buildGradientDropdown(
                        width: controlWidth,
                        hint: AppLocalizations.gamePlay,
                        value: selectedGamePlay,
                        items: gamePlays,
                        imageurl: AppImages.mp7,
                        onChanged: (v) => setState(() => selectedGamePlay = v),
                      ),
                      _buildCheckboxField(
                        width: controlWidth,
                        title: AppLocalizations.voice,
                        value: voiceEnabled,
                        onChanged: (v) =>
                            setState(() => voiceEnabled = v ?? false),
                      ),
                      _buildToggleField(
                        width: controlWidth,
                        title: AppLocalizations.public,
                        value: isPublic,
                        onChanged: (v) => setState(() => isPublic = v),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 2.w),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(AppImages.copy1,
                                width: 18.w, height: 22.h),
                            SizedBox(width: 2.w),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    const ClipboardData(text: "ad234"));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("${AppLocalizations.copied}: ad234")),
                                );
                              },
                              child: Text(
                                "ad234",
                                style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    backgroundColor:
                                        const Color.fromARGB(255, 91, 174, 212),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Image.asset(AppImages.copy,
                                width: 18.w, height: 22.h),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 25.sp, color: Colors.white),
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border:
                                  Border.all(color: Colors.white, width: 2.w),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (players > 5) {
                                      setState(() => players -= 5);
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(2.w),
                                    child: Icon(Icons.remove,
                                        size: 14.sp, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4.w, vertical: 1.h),
                                  child: Text(
                                    "$players",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.sp),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => players += 5),
                                  child: Padding(
                                    padding: EdgeInsets.all(2.w),
                                    child: Icon(Icons.add,
                                        size: 20.sp, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_left,
                              size: 25.sp, color: Colors.white),
                          Container(
                            width: 30.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.9, color: Colors.white),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_right,
                              size: 25.sp, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF002547),
                          Color(0xFF002444),
                          Color(0xFF002242),
                          Color(0xFF002548),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(width: 2, color: Colors.blue)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.waiting,
                          height: 90.h,
                          width: 90.w,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          AppLocalizations.waitingForPlayers,
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () {
                  if (isFormComplete) {
                    context.push(Routes.gameScreen, extra: {
                      'language': selectedLanguage,
                      'script': selectedScript,
                      'country': selectedCountry,
                      'points': selectedPoints,
                      'category': selectedCategory,
                      'gamePlay': selectedGamePlay,
                      'voiceEnabled': voiceEnabled,
                      'isPublic': isPublic,
                      'players': players,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.pleaseFillAllDetails)),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isFormComplete
                        ? const Color.fromARGB(255, 47, 219, 53)
                        : Colors.red,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isFormComplete
                          ? Image.asset(
                              AppImages.rocket,
                              height: 25.h,
                              width: 25.w,
                            )
                          : Image.asset(
                              AppImages.coin,
                              height: 25.h,
                              width: 25.w,
                            ),
                      SizedBox(width: 8.w),
                      Text(
                        isFormComplete ? AppLocalizations.letsGoRoomLive : "$coins",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                height: isTablet ? 60.h : 50.h,
                padding: EdgeInsets.all(10.w),
                color: Colors.grey,
                child: const SizedBox.shrink(),
              ),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientDropdown({
    required double width,
    required String hint,
    required String? value,
    required List<String> items,
    required String imageurl,
    required ValueChanged<String?> onChanged,
  }) {
    final GlobalKey tapKey = GlobalKey();
    return SizedBox(
      width: width,
      height: _controlHeight,
      child: Container(
        padding: EdgeInsets.all(1.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: value != null ? Colors.white.withOpacity(0.15) : null,
          border: value == null
              ? Border.all(color: Colors.grey, width: 1.w)
              : Border.all(color: Colors.white, width: 1.w),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: tapKey,
            borderRadius: BorderRadius.circular(23.r),
            onTap: () async {
              final box =
                  tapKey.currentContext!.findRenderObject() as RenderBox;
              final Offset pos = box.localToGlobal(Offset.zero);
              final Size size = box.size;
              const double gap = -2.0;
              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(
                    pos.dx,
                    pos.dy + size.height + gap,
                    pos.dx + size.width,
                    pos.dy + size.height + gap),
                color: Colors.transparent,
                constraints: BoxConstraints(
                  minWidth: size.width,
                  maxWidth: size.width,
                ),
                items: [
                  PopupMenuItem<String>(
                    enabled: false,
                    padding: EdgeInsets.zero,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.r),
                          color: Colors.white.withOpacity(0.15)),
                      padding: EdgeInsets.all(2.w),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23.r),
                          color: const Color(0xFF0E0E0E),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final e = entry.value;
                            return Container(
                              decoration: index < items.length - 1
                                  ? const BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 0.2),
                                              width: 1)))
                                  : null,
                              child: InkWell(
                                onTap: () => Navigator.pop(context, e),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      e,
                                      style: GoogleFonts.lato(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
              if (selected != null) onChanged(selected);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23.r),
                color: const Color(0xFF0E0E0E),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      imageurl,
                      height: 25.h,
                      width: 25.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        value ?? hint,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: value == null ? Colors.grey : Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 24.sp,
                      color: value == null ? Colors.grey : Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxField({
    required double width,
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: _controlHeight,
      child: _gradientShell(
        isActive: value,
        child: InkWell(
          borderRadius: BorderRadius.circular(13.r),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.graphic_eq,
                    color: value
                        ? const Color.fromARGB(255, 9, 133, 25)
                        : Colors.grey,
                    size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.lato(
                        color:
                            value ? Colors.white.withOpacity(0.9) : Colors.grey,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                Transform.scale(
                  scale: 1.3,
                  child: Checkbox(
                    value: value,
                    onChanged: onChanged,
                    activeColor: const Color.fromARGB(255, 7, 182, 7),
                    checkColor: Colors.black,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleField({
    required double width,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SizedBox(
      width: width,
      height: _controlHeight,
      child: _gradientShell(
        isActive: value,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_open,
                color: value
                    ? const Color.fromARGB(255, 220, 228, 223)
                    : Colors.grey,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                    color: value ? Colors.white.withOpacity(0.9) : Colors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(!value),
                child: Image.asset(
                  value ? AppImages.boxtoggleon : AppImages.boxtoggleoff,
                  width: 30.w,
                  height: 35.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientShell({required Widget child, required bool isActive}) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
        border: isActive
            ? Border.all(color: Colors.white, width: 1.w)
            : Border.all(color: Colors.grey, width: 1.w),
        color: isActive ? Colors.white.withOpacity(0.15) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: BackdropFilter(
          filter: isActive
              ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
              : ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.r),
              color: const Color(0xFF0E0E0E),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
