import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/presentations/game/widgets/submitted.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';
import 'dart:developer' as developer;

class FormPopup extends StatefulWidget {
  List<RoomParticipant> participants;
  final int roomId;

  FormPopup({
    super.key,
    required this.participants,
    required this.roomId,
  });

  @override
  State<FormPopup> createState() => _FormPopupState();
}

class _FormPopupState extends State<FormPopup> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  RoomParticipant? _selectedUser;
  final UserRepository _userRepository = UserRepository();
  final _descriptionController = TextEditingController();

  final List<String> reasons = ['Spam', 'Abuse', 'Other'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final bool isTablet = mq.width > 600;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 420.w : mq.width * 0.95,
        ),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24.w : 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.yellow, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// CLOSE BUTTON
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: isTablet ? 28.r : 24.r,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              /// TITLE
              Text(
                'Report Member',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22.sp,
                ),
              ),

              SizedBox(height: 12.h),

              /// CONTENT
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Member Name'),
                        SizedBox(height: 4.h),
                        _buildDropdown<RoomParticipant>(
                          value: _selectedUser,
                          items: widget.participants,
                          onChanged: (val) =>
                              setState(() => _selectedUser = val),
                          validator: (val) =>
                              val == null ? 'Please select a member' : null,
                        ),

                        SizedBox(height: 15.h),

                        _buildLabel('Reason'),
                        SizedBox(height: 4.h),
                        _buildDropdown<String>(
                          value: _selectedReason,
                          items: reasons,
                          onChanged: (val) =>
                              setState(() => _selectedReason = val),
                          validator: (val) =>
                              val == null ? 'Please select a reason' : null,
                        ),

                        SizedBox(height: 15.h),

                        _buildLabel('Description'),
                        SizedBox(height: 4.h),
                        TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Enter description",
                            hintStyle:
                                const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF141414),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter description'
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// ACTION BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      const logTag = 'ReportMemberForm';
                      final userToBlockId =
                          _selectedUser!.userId ??
                              _selectedUser!.user?.id ??
                              _selectedUser!.id;

                      if (userToBlockId == null) {
                        developer.log(
                          'Report Member skipped: userToBlockId is null for selected user',
                          name: logTag,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Could not get user id. Please try another member.')),
                          );
                        }
                        return;
                      }

                      developer.log(
                        'Report Member API call | roomId=${widget.roomId} userToBlockId=$userToBlockId reportType=user',
                        name: logTag,
                      );
                      final result = await _userRepository.reportUser(
                        roomId: widget.roomId.toString(),
                        userToBlockId: userToBlockId,
                        reportType: 'user',
                      );

                      if (!mounted) return;

                      result.fold(
                        (failure) {
                          developer.log(
                            'Report Member failed: ${failure.message}',
                            name: logTag,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(failure.message)),
                          );
                        },
                        (_) {
                          developer.log('Report Member success', name: logTag);
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const SubmittedPopup(),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required FormFieldValidator<T?> validator,
  }) {
    return FormField<T?>(
      validator: validator,
      builder: (FormFieldState<T?> state) {
        return InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF141414),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
              isExpanded: true,
              value: value,
              icon:
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: const Color(0xFF141414),
              onChanged: (val) {
                state.didChange(val);
                onChanged(val);
              },
              items: items.map((item) {
                if (item is String) {
                  return DropdownMenuItem<T?>(
                    value: item as T,
                    child: Text(item,
                        style: const TextStyle(color: Colors.white)),
                  );
                } else if (item is RoomParticipant) {
                  return DropdownMenuItem<T?>(
                    value: item as T,
                    child: Text(
                      item.user?.name ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                return DropdownMenuItem<T?>(
                  value: item,
                  child: Text(item.toString(),
                      style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
      ),
    );
  }
}
