import 'package:flutter/material.dart';
import 'components/multi_select_field.dart';

void main() {
  runApp(const MyApp());
}

/// Demo ilova uchun asosiy widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiSelect Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MultiSelectDemoPage(),
    );
  }
}

class MultiSelectDemoPage extends StatefulWidget {
  const MultiSelectDemoPage({super.key});

  @override
  State<MultiSelectDemoPage> createState() => _MultiSelectDemoPageState();
}

class _MultiSelectDemoPageState extends State<MultiSelectDemoPage> {
  final List<Item> items = List.generate(
    10,
    (index) => Item(id: index, name: 'Item $index'),
  );
  List<Item> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MultiSelect Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MultiSelectField<Item>(
              items: items,
              getName: (item) => item.name,
              getId: (item) => item.id,
              labelText: 'Elementlarni tanlang',
              hintText: 'Tanlang',
              initialSelectedIds: selectedItems.map((e) => e.id).toList(),
              onSelectionChanged: (selectedData) {
                selectedItems = [...selectedData];
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Tanlangan elementlar: ${selectedItems.map((e) => e.name).join(', ')}',
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
