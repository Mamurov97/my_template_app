import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// --------------------------------------------------
/// SingleMonthPicker
/// --------------------------------------------------
/// Modal bottom sheet orqali bitta oy tanlash uchun picker widgeti.
/// Ushbu widget yordamida foydalanuvchi bitta oy tanlaydi va tanlov darhol qaytariladi.
///
/// Qo'shimcha parametr:
/// - [separatorWidget]: Yillar bo'limlari orasidagi ajratuvchi widgetni belgilash uchun.
class SingleMonthPicker extends StatefulWidget {
  final DateTime? startDate; // Tanlanishi mumkin bo'lgan eng kichik sana (oy)
  final DateTime? endDate; // Tanlanishi mumkin bo'lgan eng katta sana (oy)
  final DateTime? selectedMonth; // Dastlabki tanlangan oy
  final Widget Function(int year)? yearRenderer; // Yil bo'limini maxsus ko'rsatish uchun renderer funksiya
  final Widget Function(DateTime month, bool isSelected)? monthRenderer; // Oy ko'rsatishni maxsus sozlash uchun renderer funksiya
  final Function(DateTime selectedMonth) onSave; // Oy tanlangandan keyin chaqiriladigan callback
  final Widget? separatorWidget; // Yillar bo'limlari orasidagi ajratuvchi widget

  const SingleMonthPicker({
    super.key,
    this.startDate,
    this.endDate,
    this.selectedMonth,
    this.yearRenderer,
    this.monthRenderer,
    required this.onSave,
    this.separatorWidget,
  });

  /// Modal bottom sheet ichida SingleMonthPicker ni ishga tushurish uchun statik funksiya.
  static Future<DateTime?> show(
      BuildContext context, {
        DateTime? startDate,
        DateTime? endDate,
        DateTime? selectedMonth,
        Widget Function(int year)? yearRenderer,
        Widget Function(DateTime month, bool isSelected)? monthRenderer,
        Widget? separatorWidget,
      }) async {
    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleMonthPicker(
              startDate: startDate,
              endDate: endDate,
              selectedMonth: selectedMonth,
              yearRenderer: yearRenderer,
              monthRenderer: monthRenderer,
              separatorWidget: separatorWidget,
              onSave: (selectedMonth) {
                // Tanlangan oy darhol qaytariladi.
                Navigator.pop(context, selectedMonth);
              },
            );
          },
        );
      },
    );
  }

  @override
  State<SingleMonthPicker> createState() => _SingleMonthPickerState();
}

class _SingleMonthPickerState extends State<SingleMonthPicker> {
  late DateTime _minimumDate; // Tanlanishi mumkin bo'lgan eng kichik sana (oy)
  late DateTime _maximumDate; // Tanlanishi mumkin bo'lgan eng katta sana (oy)
  DateTime? _selectedMonth; // Foydalanuvchi tomonidan tanlangan oy
  late final List<int> _yearList; // Ko'rsatiladigan yillar ro'yxati

  // RangeMonthPicker misolidagi singari, indeksga asoslangan scroll controller.
  final ItemScrollController _itemScrollController = ItemScrollController();

  // Har bir yil bo'limi uchun unikal GlobalKey lar.
  late final Map<int, GlobalKey> _yearSectionKeys;
  // Har bir oy uchun unikal GlobalKey lar (kalit: "year-month").
  final Map<String, GlobalKey> _monthKeys = {};

  @override
  void initState() {
    super.initState();
    _minimumDate = widget.startDate ?? DateTime(DateTime.now().year - 5, 1);
    _maximumDate = widget.endDate ?? DateTime(DateTime.now().year + 5, 12);
    _yearList = List.generate(
      _maximumDate.year - _minimumDate.year + 1,
          (index) => _minimumDate.year + index,
    );
    _yearSectionKeys = {for (int year in _yearList) year: GlobalKey()};

    // Dastlabki tanlangan oy (agar berilgan bo'lsa) to'g'ridan-to'g'ri tayinlanadi.
    if (widget.selectedMonth != null) {
      _selectedMonth = DateTime(widget.selectedMonth!.year, widget.selectedMonth!.month);
    }

    // Widget qurilgach, tanlangan yil va oy bo'limlariga scroll qilamiz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedMonth != null) {
        _scrollToSelectedYear(_selectedMonth!.year);
      }
    });
  }

  /// Tanlangan yil indeksiga asoslangan scroll qilish.
  void _scrollToSelectedYear(int year) {
    final index = _yearList.indexOf(year);
    if (index != -1) {
      _itemScrollController.jumpTo(index: index);
    }
  }

  /// Foydalanuvchi oyga bosganida, tanlovni yangilab, callback orqali qaytaradi.
  void _handleMonthTap(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
    widget.onSave(month);
  }

  /// Ikki sana oy darajasida tenglashishini tekshiruvchi yordamchi funksiya.
  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Yuqori panel: tanlangan oy va yopish tugmasi.
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedMonth != null
                    ? DateFormat('MMMM yyyy').format(_selectedMonth!)
                    : "Oy tanlang",
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
        // Yillar bo'yicha ro'yxatni ko'rsatish uchun ScrollablePositionedList.separated.
        Expanded(
          child: ScrollablePositionedList.separated(
            itemScrollController: _itemScrollController,
            itemCount: _yearList.length,
            separatorBuilder: (context, index) =>
            widget.separatorWidget ?? const Divider(),
            itemBuilder: (context, index) {
              final year = _yearList[index];
              return _buildYearSection(year);
            },
          ),
        ),
      ],
    );
  }

  /// Berilgan yil uchun bo'lim quruvchi widget.
  Widget _buildYearSection(int year) {
    return Container(
      key: _yearSectionKeys[year],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yil sarlavhasi yoki maxsus renderer orqali yil bo'limini ko'rsatish.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.yearRenderer != null
                ? widget.yearRenderer!(year)
                : Text(
              year.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Berilgan yil uchun oylar gridi.
          _buildMonthGrid(year),
        ],
      ),
    );
  }

  /// Berilgan yil uchun oylar gridini quruvchi funksiya.
  Widget _buildMonthGrid(int year) {
    const List<String> monthsNames = [
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final monthDate = DateTime(year, index + 1);
        // Tanlanishi mumkin bo'lgan oylar oralig'i: _minimumDate va _maximumDate orasidagi oylar.
        final isWithinRange = (_minimumDate.isBefore(monthDate) &&
            _maximumDate.isAfter(monthDate)) ||
            _isSameMonth(_minimumDate, monthDate) ||
            _isSameMonth(_maximumDate, monthDate);
        if (!isWithinRange) return const SizedBox.shrink();
        final isSelected = _selectedMonth != null && _isSameMonth(_selectedMonth!, monthDate);
        // Har bir oy uchun unikal kalit tayinlanadi.
        final String monthKeyStr = "$year-${index + 1}";
        final monthKey = _monthKeys[monthKeyStr] ?? GlobalKey();
        _monthKeys[monthKeyStr] = monthKey;
        return GestureDetector(
          onTap: isWithinRange ? () => _handleMonthTap(monthDate) : null,
          child: Container(
            key: monthKey,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
              ),
            ),
            child: widget.monthRenderer != null
                ? widget.monthRenderer!(monthDate, isSelected)
                : Center(
              child: Text(
                monthsNames[index],
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
    super.dispose();
  }
}

/// --------------------------------------------------
/// SingleMonthPickerField
/// --------------------------------------------------
/// InputDecorator orqali tanlangan oyni ko'rsatadigan va modal bottom sheet orqali
/// SingleMonthPicker ni ishga tushiradigan widget.
/// Foydalanuvchi interfeysida tanlovni oson va tushunarli tarzda aks ettiradi.
class SingleMonthPickerField extends StatefulWidget {
  final String labelText; // Input ustidagi label matni
  final String hintText; // Tanlanmagan holatdagi ko'rsatma matni
  final ValueChanged<DateTime?>? onSelectionChanged; // Oy tanlanganda chaqiriladigan callback
  final DateTime? startDate; // Tanlanishi mumkin bo'lgan eng kichik sana (oy)
  final DateTime? endDate; // Tanlanishi mumkin bo'lgan eng katta sana (oy)
  final DateTime? selectedMonth; // Dastlabki tanlangan oy
  final Widget Function(int year)? yearRenderer; // Yil bo'limini maxsus ko'rsatish uchun funksiya
  final Widget Function(DateTime month, bool isSelected)? monthRenderer; // Oy ko'rsatishni maxsus sozlash uchun funksiya
  final InputDecoration? inputDecoration; // Input dekoratsiyasini o'zgartirish uchun qo'shimcha parametr
  final Widget? separatorWidget; // SingleMonthPicker da foydalaniladigan ajratuvchi widget

  const SingleMonthPickerField({
    super.key,
    this.labelText = "",
    this.hintText = "Tanlang",
    this.onSelectionChanged,
    this.startDate,
    this.endDate,
    this.selectedMonth,
    this.yearRenderer,
    this.monthRenderer,
    this.inputDecoration,
    this.separatorWidget,
  });

  @override
  State<SingleMonthPickerField> createState() => _SingleMonthPickerFieldState();
}

class _SingleMonthPickerFieldState extends State<SingleMonthPickerField> {
  DateTime? _chosenMonth; // Foydalanuvchi tomonidan tanlangan oy

  @override
  void initState() {
    super.initState();
    if (widget.selectedMonth != null) {
      _chosenMonth = widget.selectedMonth;
    }
  }

  /// Modal bottom sheet orqali SingleMonthPicker ni ochish.
  Future<void> _openMonthPicker() async {
    final result = await SingleMonthPicker.show(
      context,
      startDate: widget.startDate,
      endDate: widget.endDate,
      selectedMonth: widget.selectedMonth,
      yearRenderer: widget.yearRenderer,
      monthRenderer: widget.monthRenderer,
      separatorWidget: widget.separatorWidget,
    );
    if (result != null) {
      setState(() {
        _chosenMonth = result;
      });
      widget.onSelectionChanged?.call(result);
    }
  }

  /// Tanlangan oyni formatlab chiqarish (masalan: "Mart 2023").
  String _formatMonth() {
    if (_chosenMonth == null) return widget.hintText;
    return DateFormat('MMMM yyyy').format(_chosenMonth!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayStyle = theme.textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.labelText,
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        InkWell(
          onTap: _openMonthPicker,
          child: InputDecorator(
            decoration: widget.inputDecoration ??
                InputDecoration(
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
            child: Text(_formatMonth(), style: displayStyle),
          ),
        ),
      ],
    );
  }
}
