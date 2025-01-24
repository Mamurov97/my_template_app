import 'package:flutter/material.dart';
import 'package:my_template_app/components/multi_select_field.dart';

void main() {
  runApp(const MyApp());
}

/// Demo ilovasi: SingleSelectField widgetini qanday ishlatish.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SingleSelect Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SingleSelectDemoPage(),
    );
  }
}

class SingleSelectDemoPage extends StatefulWidget {
  const SingleSelectDemoPage({super.key});

  @override
  State<SingleSelectDemoPage> createState() => _SingleSelectDemoPageState();
}

class _SingleSelectDemoPageState extends State<SingleSelectDemoPage> {
  List<Item> selectedItems = [];
  final List<Item> items = List.generate(
    10,
    (index) => Item(id: index, name: 'Item $index'),
  );
  Item? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SingleSelect Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MultiSelectField<Item>(
              items: items,
              getName: (item) => item.name,
              getId: (item) => item.id,
              initialSelectedIds: selectedItems.map((e) => e.id).toList(),
              labelText: 'Elementni tanlang',
              hintText: 'Hech nima tanlanmagan',
              bottomSheetHeightFactor: 0.8,
              bottomSheetIsDismissible: false,
              bottomSheetEnableDrag: false,
              bottomSheetTitle: 'Elementlarni tanlang',
              // itemRender: (item, isSelected, onChanged) {
              //   return Container(
              //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              //     decoration: BoxDecoration(
              //       color: isSelected ? Colors.green.shade100 : Colors.transparent,
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(item.name, style: const TextStyle(fontSize: 16)),
              //         if (isSelected)
              //           Icon(Icons.check, color: Theme.of(context).primaryColor),
              //       ],
              //     ),
              //   );
              // },
              onSelectionChanged: (item) {
                setState(() {
                  selectedItems = item;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Tanlangan element: ${selectedItem != null ? selectedItem!.name : "Yo\'q"}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Oddiy model klassi.
class Item {
  final int id;
  final String name;

  Item({required this.id, required this.name});
}

class WorkerInformationsModel {
  final String name;
  final String surname;
  final String position;
  final String department;
  final String phoneNumber;
  final String email;

  WorkerInformationsModel({
    required this.name,
    required this.surname,
    required this.position,
    required this.department,
    required this.phoneNumber,
    required this.email,
  });

  factory WorkerInformationsModel.fromJson(Map<String, dynamic> json) {
    return WorkerInformationsModel(
      name: json['name'],
      surname: json['surname'],
      position: json['position'],
      department: json['department'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }

  toJson() {
    return {
      'name': name,
      'surname': surname,
      'position': position,
      'department': department,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }
}
