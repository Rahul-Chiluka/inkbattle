import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inkbattle_frontend/models/room_model.dart';
import 'package:inkbattle_frontend/presentations/game/widgets/submitted.dart';
import 'package:inkbattle_frontend/repositories/user_repository.dart';

class FormPopup extends StatefulWidget {
  List<RoomParticipant> participants;
  final int roomId;
  FormPopup({super.key, required this.participants, required this.roomId});
  @override
  State<FormPopup> createState() => _FormPopupState();
}

class _FormPopupState extends State<FormPopup> {
  final _formKey = GlobalKey<FormState>();
  // String? _selectedMember;
  String? _selectedReason;
  RoomParticipant? _selectedUser;
  final UserRepository _userRepository = UserRepository();
  final _descriptionController = TextEditingController();

  final List<String> members = [];
  final List<String> reasons = ['Spam', 'Abuse', 'Other'];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return AlertDialog(
      contentPadding: EdgeInsets.all(isTablet ? 24.w : 16.w),
      icon: Align(
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
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: const BorderSide(color: Colors.yellow, width: 1.5),
      ),
      title: Text(
        'Report Member',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 22.sp,
        ),
      ),
      content: SingleChildScrollView(
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
                onChanged: (val) => setState(() => _selectedUser = val),
                validator: (val) =>
                    val == null ? 'Please select a member' : null,
              ),
              SizedBox(height: 15.h),
              _buildLabel('Reason'),
              SizedBox(height: 4.h),
              _buildDropdown(
                value: _selectedReason,
                items: reasons,
                onChanged: (val) => setState(() => _selectedReason = val),
                validator: (val) =>
                    val == null ? 'Please select a reason' : null,
              ),
              SizedBox(height: 15.h),
              _buildLabel('Description'),
              SizedBox(height: 4.h),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF141414),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter description'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // API expects the user id of the reported member, not the room-participant row id
              final userToBlockId = _selectedUser!.userId ?? _selectedUser!.user?.id ?? _selectedUser!.id;
              if (userToBlockId != null) {
                _userRepository.reportUser(
                    roomId: widget.roomId.toString(),
                    userToBlockId: userToBlockId,
                    reportType: 'user');
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const SubmittedPopup(),
                );
              }
            }
          },
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
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
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              dropdownColor: const Color(0xFF141414),
              onChanged: (val) {
                state.didChange(val);
                onChanged(val);
              },
              items: items.map<DropdownMenuItem<T?>>((item) {
                if (item is String) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else if (item is RoomParticipant) {
                  return DropdownMenuItem<T?>(
                    value: (item) as T,
                    child: Text(
                      item.user?.name ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  return DropdownMenuItem<T?>(
                    value: item,
                    child: Text(
                      item.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
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
