import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Month Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedRange = 'Oylar oralig\'ini tanlang';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Month Picker Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _selectedRange,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showMonthPicker,
              child: const Text('Oy oralig\'ini tanlash'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMonthPicker() async {
    final result = await MonthPickerWidget.show(
      context,
      startDate: DateTime(2023, 1),
      endDate: DateTime(2025, 12),
      rangeLimit: 3, // 3 oydan ko'p tanlay olmasin
      initialSelectedMonth: ['01.02.2025', '31.03.2025'], // Boshlang'ich tanlangan oylar
      // Ixtiyoriy: Yil rendererini o'zgartirish
      yearRenderer: (year) => Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey.shade200,
        width: double.infinity,
        child: Text(
          '$year yil',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      // Ixtiyoriy: Oy rendererini o'zgartirish
      monthRenderer: (month, isSelected) => Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black,
        alignment: Alignment.center,
        child: Text(
          _getMonthName(month.month),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.red,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedRange =
        'Tanlangan oraliq:\n${DateFormat('dd.MM.yyyy').format(result[0])} - ${DateFormat('dd.MM.yyyy').format(result[1])}';
      });
    }
  }

  // O'zbek tilidagi oylar nomlari
  String _getMonthName(int month) {
    final List<String> months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'Iyun',
      'Iyul',
      'Avgust',
      'Sentabr',
      'Oktabr',
      'Noyabr',
      'Dekabr'
    ];
    return months[month - 1];
  }
}

// Month Picker Widget
class MonthPickerWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? rangeLimit;
  final List<String>? initialSelectedMonth;
  final Widget Function(int year)? yearRenderer;
  final Widget Function(DateTime month, bool isSelected)? monthRenderer;
  final Function(DateTime startMonth, DateTime? endMonth) onSave;

  const MonthPickerWidget({
    super.key,
    this.startDate,
    this.endDate,
    this.rangeLimit,
    this.initialSelectedMonth,
    this.yearRenderer,
    this.monthRenderer,
    required this.onSave,
  });

  @override
  State<MonthPickerWidget> createState() => _MonthPickerWidgetState();

  static Future<List<DateTime>?> show(
      BuildContext context, {
        DateTime? startDate,
        DateTime? endDate,
        int? rangeLimit,
        List<String>? initialSelectedMonth,
        Widget Function(int year)? yearRenderer,
        Widget Function(DateTime month, bool isSelected)? monthRenderer,
      }) async {
    return await showModalBottomSheet<List<DateTime>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return MonthPickerWidget(
              startDate: startDate,
              endDate: endDate,
              rangeLimit: rangeLimit,
              initialSelectedMonth: initialSelectedMonth,
              yearRenderer: yearRenderer,
              monthRenderer: monthRenderer,
              onSave: (startMonth, endMonth) {
                Navigator.pop(context, [
                  startMonth,
                  endMonth ?? DateTime(startMonth.year, startMonth.month + 1, 0),
                ]);
              },
            );
          },
        );
      },
    );
  }
}

class _MonthPickerWidgetState extends State<MonthPickerWidget> {
  late DateTime _minDate;
  late DateTime _maxDate;
  DateTime? _startMonth;
  DateTime? _endMonth;
  late ScrollController _scrollController;

  // Oylar tanlash paytida ko'rsatiladigan xabar
  String? _limitMessage;

  @override
  void initState() {
    super.initState();
    _minDate = widget.startDate ?? DateTime(DateTime.now().year - 5, 1);
    _maxDate = widget.endDate ?? DateTime(DateTime.now().year + 5, 12);
    _scrollController = ScrollController();

    if (widget.initialSelectedMonth != null && widget.initialSelectedMonth!.isNotEmpty) {
      if (widget.initialSelectedMonth!.isNotEmpty) {
        try {
          final startDate = DateFormat('dd.MM.yyyy').parse(widget.initialSelectedMonth![0]);
          _startMonth = DateTime(startDate.year, startDate.month);
        } catch (e) {
          // Noto'g'ri format berilganda, e'tiborsiz qoldiriladi
        }
      }

      if (widget.initialSelectedMonth!.length >= 2) {
        try {
          final endDate = DateFormat('dd.MM.yyyy').parse(widget.initialSelectedMonth![1]);
          _endMonth = DateTime(endDate.year, endDate.month);
        } catch (e) {
          // Noto'g'ri format berilganda, e'tiborsiz qoldiriladi
        }
      }
    }

    // Tanlangan oyga scroll qilish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_startMonth != null) {
        _scrollToSelectedYear(_startMonth!.year);
      }
    });
  }

  void _scrollToSelectedYear(int year) {
    final years = _getYearList();
    final index = years.indexOf(year);
    if (index != -1) {
      // Taxminiy pozitsiyani hisoblash
      final estimatedPosition = index * 380.0; // O'zingizning element balandligiga qarab moslang
      _scrollController.animateTo(
        estimatedPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<int> _getYearList() {
    List<int> years = [];
    for (int year = _minDate.year; year <= _maxDate.year; year++) {
      years.add(year);
    }
    return years;
  }

  // Oylar oraliġi chegarasi (oy sonida)
  int _calculateMonthDifference(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 + endDate.month - startDate.month;
  }

  void _selectMonth(DateTime month) {
    setState(() {
      _limitMessage = null; // Har safar xabarni tozalash

      if (_startMonth == null || _endMonth != null) {
        // Birinchi tanlash yoki yangi oraliq
        _startMonth = month;
        _endMonth = null;
      } else {
        // Ikkinchi tanlash (oraliq uchun)
        if (month.isBefore(_startMonth!)) {
          // Agar tanlangan oy boshlang'ich oydan oldin bo'lsa, yangi startMonth qo'yamiz
          // endMonth ni null qilamiz
          _startMonth = month;
          _endMonth = null;
        } else {
          // Agar rangeLimit berilgan bo'lsa, tekshiramiz
          if (widget.rangeLimit != null) {
            final difference = _calculateMonthDifference(_startMonth!, month);

            // Bu yerda 0 dan boshlanadigan hisobni 1 dan boshlanishi kerak (1 oy farq = 1 oy)
            // Shuning uchun difference + 1 qilamiz
            final actualDifference = difference + 1;

            if (actualDifference > widget.rangeLimit!) {
              // Agar oraliq limitdan oshsa, faqat boshlang'ich oyni qoldiramiz
              _limitMessage = 'Oraliq ${widget.rangeLimit} oydan oshmasligi kerak';
              _startMonth = month; // Tanlangan oyni yangi boshlang'ich oy sifatida o'rnatamiz
              _endMonth = null;
              return;
            }
          }
          _endMonth = month;
        }
      }
    });
  }

  String _formatSelectedRange() {
    if (_startMonth == null) {
      return 'кк.оо.гггг дан кк.оо.гггг гача';
    }

    final startFormatted = DateFormat('dd.MM.yyyy').format(DateTime(_startMonth!.year, _startMonth!.month, 1));

    if (_endMonth == null) {
      // Tanlangan oyning oxirgi kunini hisoblaymiz
      final lastDay = DateTime(_startMonth!.year, _startMonth!.month + 1, 0).day;
      final endFormatted = DateFormat('dd.MM.yyyy').format(DateTime(_startMonth!.year, _startMonth!.month, lastDay));
      return '$startFormatted дан $endFormatted гача';
    } else {
      final lastDay = DateTime(_endMonth!.year, _endMonth!.month + 1, 0).day;
      final endFormatted = DateFormat('dd.MM.yyyy').format(DateTime(_endMonth!.year, _endMonth!.month, lastDay));
      return '$startFormatted дан $endFormatted гача';
    }
  }

  bool _isMonthInRange(DateTime month) {
    if (_startMonth == null || _endMonth == null) return false;

    return (month.isAfter(_startMonth!) || _isSameMonth(month, _startMonth!)) &&
        (month.isBefore(_endMonth!) || _isSameMonth(month, _endMonth!));
  }

  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatSelectedRange(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        if (_limitMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Text(
                _limitMessage!,
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _getYearList().length,
            itemBuilder: (context, index) {
              final year = _getYearList()[index];
              return _buildYearSection(year);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_startMonth != null) {
                  widget.onSave(_startMonth!, _endMonth);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Сақлаш', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearSection(int year) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.yearRenderer != null
              ? widget.yearRenderer!(year)
              : Text(
            year.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildMonthGrid(year),
        const Divider(thickness: 1),
      ],
    );
  }
  Widget _buildMonthGrid(int year) {
    // O'zbek tilidagi oylar nomlari
    final monthsUZ = [
      'Yanvar', 'Fevral', 'Mart',
      'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr',
      'Oktabr', 'Noyabr', 'Dekabr'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = DateTime(year, index + 1);
        final isInRange = _minDate.isBefore(month) && _maxDate.isAfter(month) ||
            _isSameMonth(_minDate, month) || _isSameMonth(_maxDate, month);

        if (!isInRange) {
          return const SizedBox.shrink();
        }

        final isSelected = _startMonth != null && _isSameMonth(_startMonth!, month) ||
            _endMonth != null && _isSameMonth(_endMonth!, month);

        final isInSelectedRange = _isMonthInRange(month);

        // Biz endni disable qilmaymiz, oylarni har doim tanlay olish kerak
        // Tanlaganida startMonth ga o'zgaradi, xolos

        return GestureDetector(
          onTap: isInRange ? () => _selectMonth(month) : null,
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isInSelectedRange
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected || isInSelectedRange
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
            ),
            child: widget.monthRenderer != null
                ? widget.monthRenderer!(month, isSelected)
                : Center(
              child: Text(
                monthsUZ[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}