
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/widgets/text_widget.dart';

class SelectionBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? selectedItem;

  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    this.selectedItem,
  });

  @override
  State<SelectionBottomSheet> createState() => _SelectionBottomSheetState();
}

class _SelectionBottomSheetState extends State<SelectionBottomSheet> {
  late List<String> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = List.from(widget.items);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20.h,
        left: 15.w,
        right: 15.w,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar for drag indication (optional but nice)
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 15.h),

          // Title
          TextWidget(
            text: widget.title,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          SizedBox(height: 15.h),

          // Search Field
          TextField(
            controller: _searchController,
            style: GoogleFonts.lato(color: Colors.white, fontSize: 16.sp),
            decoration: InputDecoration(
              labelText: 'Search',
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
                color: Color.fromRGBO(9, 189, 255, 1),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              filled: true,
              fillColor: Colors.black,
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
          ),
          SizedBox(height: 15.h),

          // List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: TextWidget(
                      text: 'No matches found',
                      color: Colors.grey,
                      fontSize: 14.sp,
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredItems.length,
                    separatorBuilder: (c, i) => Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = item == widget.selectedItem;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context, item);
                          },
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(
                              vertical: 13.h, // Reduced from 16.h
                              horizontal: 12.w, // Added horizontal padding for "floating" look
                            ),

                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color.fromRGBO(9, 189, 255, 0.1)
                                  : null,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: GoogleFonts.lato(
                                      color: isSelected
                                          ? const Color.fromRGBO(9, 189, 255, 1)
                                          : Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color.fromRGBO(9, 189, 255, 1),
                                    size: 26.sp, // Increased from 20
                                  ),

                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
