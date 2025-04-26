import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_template_app/components/item_selects/multi_select_field.dart';
import 'package:my_template_app/components/main_button/main_button.dart';
import 'package:my_template_app/components/theme/app_theme.dart';
import 'package:my_template_app/presentation/components/custom_toast.dart';

void main() {
  runApp(const MyApp());
}

class City {
  final int id;
  final String name;

  City(this.id, this.name);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context,child){
        AppTheme.init();
        return MaterialApp(
          navigatorKey: CustomToast.navigatorKey,
          title: 'MultiSelect Demo',
          theme: AppTheme.data,
          themeMode: AppTheme.themeMode,
          home: MultiSelectExample(),
        );
      },
    );
  }
}

class MultiSelectExample extends StatefulWidget {
  const MultiSelectExample({super.key});

  @override
  State<MultiSelectExample> createState() => _MultiSelectExampleState();
}

class _MultiSelectExampleState extends State<MultiSelectExample> {
  final List<City> cities = [
    City(1, "Toshkent"),
    City(2, "Samarqand"),
    City(3, "Buxoro"),
    City(4, "Xiva"),
    City(5, "Farg‘ona"),
    City(6, "Namangan"),
    City(7, "Andijon"),
    City(99, "Barchasi"), // Barchasini tanlash uchun maxsus ID
  ];
  List<City> selectedCities = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shaharlar tanlash")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MultiSelectField<City>(
              items: cities,
              getName: (city) => city.name,
              getId: (city) => city.id,
              initialSelectedIds: [2, 3],
              labelText: "Shaharlar",
              hintText: "Shaharlarni tanlang",
              selectAllWhenIdSelected: 99,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedCities = selected;
                });
              },
            ),
            MainButton(text: 'Saqlash',),
            MainButton(text: 'Saqlash',onTap: (){},),
            MainButton(text: 'Saqlash',onTap: (){},onLoading: true,),

          ],
        ),
      ),
    );
  }
}
