import 'package:flutter/material.dart';
import 'package:my_template_app/components/date_selects/single_month_picker_field.dart';

void main() {
  runApp(const MyApp());
}

// Asosiy ilova
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Month Picker Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

// Bosh sahifa
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime startFormatted = DateTime(2025, 01, 01);
  DateTime endFormatted = DateTime(2025, 03, 30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Month Picker Demo")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SingleMonthPickerField(
              labelText: "Tanlangan Oylar",
              hintText: "Oylar oralig'ini tanlang",
              startDate: DateTime(2020, 1),
              endDate: DateTime.now(),
              selectedMonth: startFormatted,
              onSelectionChanged: (selectedRange) {
                if (selectedRange != null) {
                  setState(() {
                    startFormatted = selectedRange;
                  });
                  debugPrint("Tanlangan sana: $startFormatted");
                }
              },
            ),
            const SizedBox(height: 20),
            Text("Boshlanish: $startFormatted"),
          ],
        ),
      ),
    );
  }
}
