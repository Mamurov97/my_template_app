import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_template_app/presentation/assets/app_icons.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key, required this.onChanged,});
  final Function(String text) onChanged;

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return  TextField(
      onChanged: widget.onChanged,
      decoration:InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(14.w),
            child: SvgPicture.asset(AppIcons.search),
          ),
          hintText: 'Qidirish',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          filled: true,
          fillColor: Colors.white),
    );
  }
}
