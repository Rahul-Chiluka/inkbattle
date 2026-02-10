import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class TextformFieldWidget extends StatefulWidget {
  const TextformFieldWidget({
    super.key,
    this.hintText,
    this.height,
    this.rouneded = 5.0,
    this.fontWeight,
    this.focusNode,
    this.suffixIcon,
    this.isSuffixIconShow = false,
    this.isRounded = true,
    this.backgroundColor,
    this.controller,
    this.textInputType,
    this.inputFormater,
    this.onChanged,
    this.prefixIcon,
    this.validator,
    this.initialValue,
    this.isBorderColor = true,
    this.obscureText,
    this.hintTextColor = AppColors.textformFieldColor,
    this.textColor = AppColors.textGrey,
    this.fontSize,
    this.readOnly,
    this.maxLine,
    this.contentPadding,
  });

  final String? initialValue;
  final String? hintText;
  final int? maxLine;
  final bool isSuffixIconShow;
  final double? height;
  final double rouneded;
  final Widget? prefixIcon;
  final bool isRounded;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? backgroundColor;
  final Color? hintTextColor;
  final Color? textColor;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormater;
  final bool? isBorderColor;
  final bool? obscureText;
  final bool? readOnly;
  final EdgeInsets? contentPadding;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  @override
  State<TextformFieldWidget> createState() => _TextformFieldWidgetState();
}

class _TextformFieldWidgetState extends State<TextformFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(255, 255, 255, 1),
            Color.fromRGBO(9, 189, 255, 1),
          ],
        ),
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Colors.black,
        ),
        height: widget.height,
        child: TextFormField(
          maxLines: widget.maxLine ?? 1,
          obscureText: widget.obscureText ?? false,
          initialValue: widget.initialValue,
          cursorColor: AppColors.textGrey,
          inputFormatters: widget.inputFormater,
          keyboardType: widget.textInputType,
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          validator: widget.validator,
          readOnly: widget.readOnly ?? false,
          style: GoogleFonts.kumbhSans(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: widget.textColor),
          decoration: InputDecoration(
            contentPadding: widget.contentPadding ?? const EdgeInsets.all(10),
            hintText: widget.hintText,
            suffixIcon: widget.suffixIcon,
            prefixIcon: widget.prefixIcon,
            hintStyle: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: widget.hintTextColor),
            enabledBorder: InputBorder.none,

            //UnderlineInputBorder(
            //     borderRadius: BorderRadius.circular(widget.rouneded),
            //     borderSide: BorderSide(
            //         width: 1,
            //         color: (widget.isBorderColor ?? false) ? AppColors.borderColor : AppColors.backgroundDark)),
            focusedBorder: InputBorder.none,
            //  widget.isRounded
            //     ? UnderlineInputBorder(
            //         borderRadius: BorderRadius.circular(widget.rouneded),
            //         borderSide: BorderSide(
            //             width: 1,
            //             color: (widget.isBorderColor ?? false) ? AppColors.borderColor : AppColors.backgroundDark))
            //     : null,
            border: InputBorder.none,
            //  widget.isRounded
            //     ? UnderlineInputBorder(
            //         borderRadius: BorderRadius.circular(widget.rouneded),
            //         borderSide: BorderSide(
            //             width: 1, color: (widget.isBorderColor ?? false) ? AppColors.borderColor : AppColors.borderColor))
            //     : null,
          ),
        ),
      ),
    );
  }
}
