import 'package:flutter/material.dart';
import 'package:mipal/helpers/colors.dart';

class AppWidgets {
  static Widget buildTextField({
    required String labelText,
    required TextEditingController controller,
    required double width,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines,
    IconData? prefixIcon,
    String? hintText,
    FormFieldValidator<String>? validator,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: AppColors.inputBackground,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
        ),
      ),
    );
  }

  static Widget buildValidationButton({
    required String text,
    required VoidCallback? onPressed,
    required double width,
    Color color = AppColors.primary,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(width, 50),
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),

      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  static Widget errorText(String message) {
    return Text(message, style: TextStyle(color: Colors.red, fontSize: 14.0));
  }
}
