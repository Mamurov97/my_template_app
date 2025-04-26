import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template_app/components/theme/light_mode_colors.dart';

import 'base_colors.dart';

class AppTheme {
  /// App theme colors
  static late BaseColors colors;

  /// Current app theme mode
  static late ThemeMode themeMode;

  /// App theme data
  static late ThemeData data;

  static Future<void> init() async {
    themeMode = ThemeMode.light;
    colors = _getThemeColors();

    final textTheme = TextTheme(
      ///display
      displayLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 24.sp,
        color: colors.black,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 24.sp,
        color: colors.black,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 24.sp,
        color: colors.black,
      ),

      ///headline
      headlineLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        color: colors.black,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 20.sp,
        color: colors.black,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20.sp,
        color: colors.black,
      ),

      ///title
      titleLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
        color: colors.black,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 16.sp,
        color: colors.black,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        color: colors.black,
      ),

      ///body
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 15.sp,
        color: colors.black,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15.sp,
        color: colors.black,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
        color: colors.black,
      ),

      ///label
      labelLarge: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12.sp,
        color: colors.black,
      ),
      labelMedium: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
        color: colors.black,
      ),
      labelSmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        color: colors.black,
      ),
    );

    data = ThemeData(
      useMaterial3: true,
      fontFamily: 'Golos',
      colorScheme: ColorScheme.light(
        primary: colors.primary,
      ),
      textTheme: textTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.dark,
      brightness: themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colors.background,
        surfaceTintColor: colors.background,
        titleTextStyle: textTheme.bodyLarge,
        iconTheme: IconThemeData(color: colors.dark),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
      ),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: colors.primary,
        selectedBorderColor: colors.primary,
        fillColor: colors.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
        ),
        side: BorderSide(color: colors.dark),
      ),
      iconButtonTheme: IconButtonThemeData(style: ElevatedButton.styleFrom(surfaceTintColor: Colors.red)),
      // tabBarTheme: TabBarTheme(
      //   labelColor: colors.black,
      //   unselectedLabelColor: colors.black,
      //   labelStyle: textTheme.labelLarge?.copyWith(fontSize: 12.sp),
      //   unselectedLabelStyle: textTheme.labelMedium?.copyWith(fontSize: 12.sp),
      //   indicator: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.circular(8.r),
      //     boxShadow: const [
      //       BoxShadow(
      //         offset: Offset(0, 3),
      //         blurRadius: 1,
      //         color: Color.fromRGBO(0, 0, 0, 0.04),
      //       ),
      //       BoxShadow(
      //         offset: Offset(0, 3),
      //         blurRadius: 8,
      //         color: Color.fromRGBO(0, 0, 0, 0.12),
      //       ),
      //     ],
      //   ),
      // ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          fixedSize: Size(1.sw, 0.055.sh),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          backgroundColor: colors.primary,
          disabledBackgroundColor: colors.blueGray,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.white,
        focusColor: colors.primary,
        floatingLabelStyle: textTheme.labelSmall?.copyWith(
          color: colors.primary,
        ),
        counterStyle: textTheme.bodySmall?.copyWith(
          color: colors.primary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.blueGray50),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.red),
        ),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: colors.blueGray50)),
        helperStyle: textTheme.labelSmall,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.blueGray50),
        errorStyle: textTheme.labelSmall?.copyWith(
          color: colors.red,
          fontSize: 10.sp,
          height: 0.3,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 10.h,
        ),
      ),
    );
  }

  static BaseColors _getThemeColors() => const LightModeColors();
}
