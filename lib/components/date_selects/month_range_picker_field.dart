import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// ------------------------------
/// RangeMonthPicker
/// ------------------------------
/// Ushbu widget modal bottom sheet orqali oylar oralig'ini tanlash imkoniyatini beradi.
/// Foydalanuvchi boshlang'ich oy va tugash oy tanlaydi. Agar tanlangan oralik belgilangan limitdan oshsa,
/// faqat boshlang'ich oy yangilanadi va tugash oy null bo'ladi.
/// Widget yil va oy qismlarini moslashtirish imkoniyatini ham beradi.
///
/// [separatorWidget] – yillar ro'yxati orasidagi ajratgich widget (agar berilmasa, standart Divider() ishlatiladi).
class RangeMonthPicker extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? rangeLimit;
  final List<DateTime>? selectedRange;
  final Widget Function(int year)? yearRenderer;
  final Widget Function(DateTime month, bool isSelected)? monthRenderer;
  final Function(DateTime rangeStart, DateTime? rangeEnd) onSave;
  final Widget? separatorWidget;

  const RangeMonthPicker({
    super.key,
    this.startDate,
    this.endDate,
    this.rangeLimit,
    this.selectedRange,
    this.yearRenderer,
    this.monthRenderer,
    required this.onSave,
    this.separatorWidget,
  });

  @override
  State<RangeMonthPicker> createState() => _RangeMonthPickerState();

  /// Modal bottom sheet sifatida ochadi va tanlangan oralikni qaytaradi.
  static Future<List<DateTime>?> show(
    BuildContext context, {
    DateTime? startDate,
    DateTime? endDate,
    int? rangeLimit,
    List<DateTime>? selectedRange,
    Widget Function(int year)? yearRenderer,
    Widget Function(DateTime month, bool isSelected)? monthRenderer,
    Widget? separatorWidget,
  }) async {
    return await showModalBottomSheet<List<DateTime>>(
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
            return RangeMonthPicker(
              startDate: startDate,
              endDate: endDate,
              rangeLimit: rangeLimit,
              selectedRange: selectedRange,
              yearRenderer: yearRenderer,
              monthRenderer: monthRenderer,
              separatorWidget: separatorWidget,
              onSave: (rangeStart, rangeEnd) {
                Navigator.pop(context, [rangeStart, rangeEnd ?? DateTime(rangeStart.year, rangeStart.month + 1, 0)]);
              },
            );
          },
        );
      },
    );
  }
}

class _RangeMonthPickerState extends State<RangeMonthPicker> {
  late DateTime _minDate;
  late DateTime _maxDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late final List<int> _years;

  // ItemScrollController va ItemPositionsListener yordamida indeksga asoslangan scroll.
  final ItemScrollController _itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    _minDate = widget.startDate ?? DateTime(DateTime.now().year - 5, 1);
    _maxDate = widget.endDate ?? DateTime(DateTime.now().year + 5, 12);
    _years = List.generate(_maxDate.year - _minDate.year + 1, (index) => _minDate.year + index);

    // Agar dastlabki tanlangan oralik berilgan bo'lsa, uni o'zgaruvchilarga tayinlaymiz.
    if (widget.selectedRange != null && widget.selectedRange!.isNotEmpty) {
      _rangeStart = widget.selectedRange![0];
      if (widget.selectedRange!.length >= 2) {
        _rangeEnd = widget.selectedRange![1];
      }
    }

    // Widget qurilgach, tanlangan boshlang'ich oyga scroll qilamiz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rangeStart != null) {
        _scrollToSelectedYear(_rangeStart!.year);
      }
    });
  }

  /// Indeksga asoslangan scroll: _years ro'yxatidagi elementning indexiga ItemScrollController orqali scroll qilinadi.
  void _scrollToSelectedYear(int year) {
    final index = _years.indexOf(year);
    if (index != -1) {
      _itemScrollController.jumpTo(index: index);
    }
  }

  int _calculateMonthDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  /// Foydalanuvchi oy tanlaganda chaqiriladi.
  /// Agar boshlang'ich oy hali tanlanmagan yoki oralik allaqachon tanlangan bo'lsa,
  /// tanlangan oy yangi boshlang'ich oy sifatida qabul qilinadi va tugash oy tozalanadi.
  /// Agar tanlangan oy, hozirgi boshlang'ich oydan oldin bo'lsa, yangi boshlang'ich sifatida qabul qilinadi.
  /// Agar belgilangan limitdan oshsa, faqat boshlang'ich oy yangilanadi.
  void _selectMonth(DateTime month) {
    setState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = month;
        _rangeEnd = null;
      } else {
        if (month.isBefore(_rangeStart!)) {
          _rangeStart = month;
          _rangeEnd = null;
        } else {
          if (widget.rangeLimit != null) {
            final diff = _calculateMonthDifference(_rangeStart!, month) + 1;
            if (diff > widget.rangeLimit!) {
              _rangeStart = month;
              _rangeEnd = null;
              return;
            }
          }
          _rangeEnd = month;
        }
      }
    });
  }

  String _formatSelectedRange() {
    if (_rangeStart == null) return "Oy oralig'ini tanlang";
    final startFormatted = DateFormat('dd.MM.yyyy').format(DateTime(_rangeStart!.year, _rangeStart!.month, 1));
    if (_rangeEnd == null) {
      final lastDay = DateTime(_rangeStart!.year, _rangeStart!.month + 1, 0).day;
      final endFormatted = DateFormat('dd.MM.yyyy').format(DateTime(_rangeStart!.year, _rangeStart!.month, lastDay));
      return '$startFormatted dan $endFormatted gacha';
    } else {
      final lastDay = DateTime(_rangeEnd!.year, _rangeEnd!.month + 1, 0).day;
      final endFormatted = DateFormat('dd.MM.yyyy').format(DateTime(_rangeEnd!.year, _rangeEnd!.month, lastDay));
      return '$startFormatted dan $endFormatted gacha';
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  bool _isMonthInRange(DateTime month) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return (month.isAfter(_rangeStart!) || _isSameMonth(month, _rangeStart!)) && (month.isBefore(_rangeEnd!) || _isSameMonth(month, _rangeEnd!));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Yuqori panel: tanlangan oralik va yopish tugmasi.
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatSelectedRange(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
        // Yillar ro'yxatini ko'rsatadigan ScrollablePositionedList.
        Expanded(
          child: ScrollablePositionedList.separated(
            itemScrollController: _itemScrollController,
            itemCount: _years.length,
            separatorBuilder: (context, index) => widget.separatorWidget ?? const Divider(),
            itemBuilder: (context, index) {
              final year = _years[index];
              return _buildYearSection(year);
            },
          ),
        ),
        // "Сақлаш" tugmasi.
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_rangeStart != null) {
                  widget.onSave(_rangeStart!, _rangeEnd);
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
        // Yil sarlavhasi.
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: widget.yearRenderer != null
              ? widget.yearRenderer!(year)
              : Text(
                  year.toString(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
        // Yil uchun oylar gridi.
        _buildMonthGrid(year),
      ],
    );
  }

  Widget _buildMonthGrid(int year) {
    const monthsUZ = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'];
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
        final isInRange = (_minDate.isBefore(month) && _maxDate.isAfter(month)) || _isSameMonth(_minDate, month) || _isSameMonth(_maxDate, month);
        if (!isInRange) return const SizedBox.shrink();
        final isSelected = (_rangeStart != null && _isSameMonth(_rangeStart!, month)) || (_rangeEnd != null && _isSameMonth(_rangeEnd!, month));
        final isInSelectedRange = _isMonthInRange(month);
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
                color: (isSelected || isInSelectedRange) ? Theme.of(context).primaryColor : Colors.grey.shade300,
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
}

/// ------------------------------
/// RangeMonthPickerField
/// ------------------------------
/// Ushbu widget InputDecorator orqali tanlangan oylar oralig'ini ko'rsatadi va
/// unga bosilganda modal bottom sheet tarzida RangeMonthPicker ni ochadi.
///
/// [separatorWidget] – RangeMonthPicker da ishlatiladigan ajratgich widget.
class RangeMonthPickerField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final ValueChanged<List<DateTime>?>? onSelectionChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? rangeLimit;
  final List<DateTime>? selectedRange;
  final Widget Function(int year)? yearRenderer;
  final Widget Function(DateTime month, bool isSelected)? monthRenderer;
  final InputDecoration? inputDecoration;
  final Widget? separatorWidget;

  const RangeMonthPickerField({
    super.key,
    this.labelText = "",
    this.hintText = "Tanlang",
    this.onSelectionChanged,
    this.startDate,
    this.endDate,
    this.rangeLimit,
    this.selectedRange,
    this.yearRenderer,
    this.monthRenderer,
    this.inputDecoration,
    this.separatorWidget,
  });

  @override
  State<RangeMonthPickerField> createState() => _RangeMonthPickerFieldState();
}

class _RangeMonthPickerFieldState extends State<RangeMonthPickerField> {
  List<DateTime>? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.selectedRange;
  }

  /// Modal bottom sheet orqali RangeMonthPicker ni ochadi.
  Future<void> _openMonthPicker() async {
    final result = await RangeMonthPicker.show(
      context,
      startDate: widget.startDate,
      endDate: widget.endDate,
      rangeLimit: widget.rangeLimit,
      selectedRange: _selectedRange,
      yearRenderer: widget.yearRenderer,
      monthRenderer: widget.monthRenderer,
      separatorWidget: widget.separatorWidget,
    );
    if (result != null) {
      setState(() {
        _selectedRange = result;
      });
      widget.onSelectionChanged?.call(result);
    }
  }

  /// Tanlangan oralikni matn shaklida formatlaydi.
  String _formatRange() {
    if (_selectedRange == null) return widget.hintText;
    final startFormatted = DateFormat('dd.MM.yyyy').format(_selectedRange![0]);
    final endFormatted = DateFormat('dd.MM.yyyy').format(_selectedRange![1]);
    return '$startFormatted - $endFormatted';
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
            child: Text(_formatRange(), style: displayStyle),
          ),
        ),
      ],
    );
  }
}
