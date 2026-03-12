import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final Function() onPress;
  const AppButton({
    super.key,
    required this.text,
    required this.onPress,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPress,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          disabledBackgroundColor: AppColors.greyColor,
          disabledForegroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child:
            isLoading
                ? Row(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: ConstantStyles.medium.copyWith(
                        color: AppColors.whiteColor,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 15),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ],
                )
                : Text(
                  text,
                  style: ConstantStyles.medium.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 16,
                  ),
                ),
      ),
    );
  }
}
