import 'package:flutter/material.dart';

/// ----------------------------------------------------------------
/// showMultiSelectBottomSheet funksiyasi
/// ----------------------------------------------------------------
/// Modal bottom sheet orqali bir nechta element tanlash.
/// Qaytarilgan natija null bo‘lishi mumkin (foydalanuvchi close tugmasini bosganda).
Future<List<T>?> showMultiSelectBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required String Function(T) getName,
  required int Function(T) getId,
  String title = "Tanlang",
  List<int>? initialSelectedIds,
  int? selectAllWhenIdSelected,
  // Agar berilsa, elementlarni moslashtirilgan ko‘rinishda chizish uchun.
  Widget Function(T item, bool isSelected, void Function(bool? value) onChanged)? itemRender,
  bool isDismissible = false,
  bool enableDrag = false,
  // Bottom sheet ekranning qancha foizini egallashi (default: 0.8 = 80%)
  double heightFactor = 0.8,
}) async {
  // Tanlangan element ID larini saqlash.
  List<int> selectedIds = initialSelectedIds != null ? List.from(initialSelectedIds) : [];
  if (selectAllWhenIdSelected != null && selectedIds.contains(selectAllWhenIdSelected)) {
    selectedIds = [selectAllWhenIdSelected];
  }

  final searchController = TextEditingController();

  final result = await showModalBottomSheet<List<T>?>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Filtrlash: qidiruv maydonidagi so‘z asosida.
          final filteredItems = items.where((item) => getName(item).toLowerCase().contains(searchController.text.toLowerCase())).toList();

          final theme = Theme.of(context);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * heightFactor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sarlavha va close ikonkasi.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, null),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Center(
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Qidiruv maydoni va "Tozalash" tugmasi (vertikal tarzda)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Qidiruv',
                          labelStyle: theme.textTheme.labelMedium,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              // Istalgan holatda selectedIds tozalanishi mumkin.
                              // selectedIds.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 0),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text("Tozalash"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Elementlar ro'yxati.
                  Expanded(
                    child: filteredItems.isNotEmpty
                        ? ListView.builder(
                            itemCount: filteredItems.length,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final itemId = getId(item);
                              final isSelectAll = selectAllWhenIdSelected != null && (itemId == selectAllWhenIdSelected);
                              final isSelected = selectedIds.contains(itemId);

                              void toggleSelection(bool? value) {
                                setState(() {
                                  if (isSelectAll) {
                                    selectedIds = value == true ? [itemId] : [];
                                  } else {
                                    if (selectedIds.contains(selectAllWhenIdSelected)) {
                                      selectedIds.remove(selectAllWhenIdSelected);
                                    }
                                    if (value == true) {
                                      selectedIds.add(itemId);
                                    } else {
                                      selectedIds.remove(itemId);
                                    }
                                  }
                                });
                              }

                              if (itemRender != null) {
                                return GestureDetector(
                                  onTap: () => toggleSelection(!isSelected),
                                  child: itemRender(item, isSelected, toggleSelection),
                                );
                              }
                              return CheckboxListTile(
                                title: Text(
                                  getName(item),
                                  style: theme.textTheme.labelMedium,
                                ),
                                value: isSelected,
                                onChanged: toggleSelection,
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: theme.primaryColor,
                              );
                            },
                          )
                        : Center(
                            child: Text("Element topilmadi", style: theme.textTheme.labelMedium),
                          ),
                  ),
                  const SizedBox(height: 10),
                  // Saqlash tugmasi.
                  ElevatedButton(
                    onPressed: selectedIds.isNotEmpty
                        ? () {
                            final selectedItems = items.where((item) => selectedIds.contains(getId(item))).toList();
                            Navigator.pop(context, selectedItems);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 36)),
                    child: const Text("Saqlash", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  return result;
}

/// ----------------------------------------------------------------
/// MultiSelectField widgeti – forma maydoni
/// ----------------------------------------------------------------
/// InputDecorator orqali tanlangan elementlar chiplari ko‘rsatiladi va modal bottom sheet orqali elementlarni tanlash imkoniyati beriladi.
/// Yangi parametrlar orqali ko‘rsatiladigan chiplar qatorining maksimal soni ham belgilanishi mumkin.
class MultiSelectField<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getName;
  final int Function(T) getId;
  final List<int>? initialSelectedIds;

  // Field ustidagi label; bo'sh bo'lsa "Tanlang" deb ko‘rsatiladi.
  final String labelText;
  final String hintText;
  final Widget? leading;
  final Widget? trailing;
  final Widget Function(T item, bool isSelected, void Function(bool? value) onChanged)? itemRender;
  final int? selectAllWhenIdSelected;
  final ValueChanged<List<T>>? onSelectionChanged;

  // Bottom sheet parametrlarini uzatish.
  final bool bottomSheetIsDismissible;
  final bool bottomSheetEnableDrag;
  final double bottomSheetHeightFactor;
  final String? bottomSheetTitle;

  // Chiplar ko'rinishida maksimal qatorda ko'rsatiladigan qatordan soni va har bir qatordagi chiplarning balandligi.
  final int maxChipLines;
  final double chipLineHeight;

  const MultiSelectField({
    super.key,
    required this.items,
    required this.getName,
    required this.getId,
    this.initialSelectedIds,
    this.labelText = "",
    this.hintText = "Tanlang",
    this.leading,
    this.trailing,
    this.itemRender,
    this.selectAllWhenIdSelected,
    this.onSelectionChanged,
    this.bottomSheetIsDismissible = false,
    this.bottomSheetEnableDrag = false,
    this.bottomSheetHeightFactor = 0.8,
    this.bottomSheetTitle,
    this.maxChipLines = 2,
    this.chipLineHeight = 40.0,
  });

  @override
  State<MultiSelectField<T>> createState() => _MultiSelectFieldState<T>();
}

class _MultiSelectFieldState<T> extends State<MultiSelectField<T>> {
  late List<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initialSelectedIds != null ? List.from(widget.initialSelectedIds!) : [];
  }

  Future<void> _openMultiSelect() async {
    final result = await showMultiSelectBottomSheet<T>(
      context: context,
      items: widget.items,
      getName: widget.getName,
      getId: widget.getId,
      initialSelectedIds: _selectedIds,
      selectAllWhenIdSelected: widget.selectAllWhenIdSelected,
      itemRender: widget.itemRender,
      title: widget.bottomSheetTitle ?? (widget.labelText.isNotEmpty ? widget.labelText : "Tanlang"),
      isDismissible: widget.bottomSheetIsDismissible,
      enableDrag: widget.bottomSheetEnableDrag,
      heightFactor: widget.bottomSheetHeightFactor,
    );
    // Foydalanuvchi modalni close qilsa (result == null) tanlov o'zgarmaydi.
    if (result != null) {
      _selectedIds = result.map((e) => widget.getId(e)).toList();
      setState(() {});
      widget.onSelectionChanged?.call(widget.items.where((item) => _selectedIds.contains(widget.getId(item))).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayTextStyle = theme.textTheme.labelMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.labelText,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        InkWell(
          onTap: _openMultiSelect,
          child: InputDecorator(
            decoration: InputDecoration(
                hintText: _selectedIds.isEmpty ? widget.hintText : null,
                border: const OutlineInputBorder(),
                prefixIcon: widget.leading,
                suffixIcon: widget.trailing ?? const Icon(Icons.arrow_drop_down),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12)),
            child: _selectedIds.isNotEmpty
                ? ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: (widget.chipLineHeight + 5) * widget.maxChipLines,
                    ),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        children: widget.items
                            .where((item) => _selectedIds.contains(widget.getId(item)))
                            .map((item) => Chip(
                                  label: Text(widget.getName(item), style: displayTextStyle),
                                  padding: EdgeInsets.zero,
                                  backgroundColor: theme.chipTheme.backgroundColor,
                                ))
                            .toList(),
                      ),
                    ),
                  )
                : Text(widget.hintText, style: TextStyle(color: theme.hintColor)),
          ),
        ),
      ],
    );
  }
}
