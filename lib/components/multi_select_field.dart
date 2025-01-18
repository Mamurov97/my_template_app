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
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Filtrlash: qidiruv maydonidagi so‘z asosida.
          final filteredItems = items.where((item) => getName(item).toLowerCase().contains(searchController.text.toLowerCase())).toList();

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
                  // Sarlavha va close ikonkasi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        decoration: const InputDecoration(
                          labelText: 'Qidiruv',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}), // Faqat filter yangilanadi.
                      ),
                      const SizedBox(height: 4),
                      // Minimal joy egallaydigan va o‘ngga hizalanadigan "Tozalash" tugmasi.
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              selectedIds.clear();
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
                                title: Text(getName(item)),
                                value: isSelected,
                                onChanged: toggleSelection,
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Theme.of(context).primaryColor,
                              );
                            },
                          )
                        : const Center(child: Text("Element topilmadi")),
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
/// Tanlangan elementlarni chip shaklida ko'rsatadi va modalni chaqiradi.
class MultiSelectField<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getName;
  final int Function(T) getId;
  final List<int>? initialSelectedIds;

  // Field ustidagi label; bo'sh bo'lsa "Tanlang" chiqadi.
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
  });

  @override
  State<MultiSelectField<T>> createState() => _MultiSelectFieldState<T>();
}

class _MultiSelectFieldState<T> extends State<MultiSelectField<T>> {
  List<T> _selectedItems = [];

  Future<void> _openMultiSelect() async {
    final result = await showMultiSelectBottomSheet<T>(
      context: context,
      items: widget.items,
      getName: widget.getName,
      getId: widget.getId,
      initialSelectedIds: widget.initialSelectedIds,
      selectAllWhenIdSelected: widget.selectAllWhenIdSelected,
      itemRender: widget.itemRender,
      // Bottom sheet parametrlarini uzatish.
      title: widget.bottomSheetTitle ?? (widget.labelText.isNotEmpty ? widget.labelText : "Tanlang"),
      isDismissible: widget.bottomSheetIsDismissible,
      enableDrag: widget.bottomSheetEnableDrag,
      heightFactor: widget.bottomSheetHeightFactor,
    );
    // Foydalanuvchi modalni close qilsa (result == null) tanlov o'zgarmaydi.
    if (result != null) {
      setState(() {
        _selectedItems = result;
      });
      widget.onSelectionChanged?.call(_selectedItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field ustidagi label (agar berilgan bo‘lsa)
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(widget.labelText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        InkWell(
          onTap: _openMultiSelect,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: _selectedItems.isEmpty ? widget.hintText : null,
              border: const OutlineInputBorder(),
              prefixIcon: widget.leading,
              suffixIcon: widget.trailing ?? const Icon(Icons.arrow_drop_down),
            ),
            child: _selectedItems.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _selectedItems
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Chip(label: Text(widget.getName(item))),
                            ),
                          )
                          .toList(),
                    ),
                  )
                : Text(widget.hintText, style: TextStyle(color: Theme.of(context).hintColor)),
          ),
        ),
      ],
    );
  }
}
