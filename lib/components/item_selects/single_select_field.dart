import 'package:flutter/material.dart';

/// ----------------------------------------------------------------
/// showSingleSelectBottomSheet funksiyasi
/// ----------------------------------------------------------------
/// Modal bottom sheet orqali yagona element tanlash.
/// Qaytarilgan natija foydalanuvchi bottom sheet-ni yopganida null bo‘lishi mumkin.
Future<T?> showSingleSelectBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required int Function(T) getId,
  required String Function(T) getName,
  T? selectedItem,
  String title = '',
  // Bottom sheet ning bo‘yini ekran balandligining qanchalik foizini egallashini belgilaydi (default: 0.8 = 80%).
  double heightFactor = 0.8,
  bool isDismissible = false,
  bool enableDrag = false,
  // Agar berilsa, har bir elementni moslashtirilgan ko‘rinishda chizish uchun funksiya.
  Widget Function(T item, bool isSelected, void Function(bool? value) onChanged)? itemRender,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return _SingleSelectBottomSheetContent<T>(
        items: items,
        getId: getId,
        getName: getName,
        selectedItem: selectedItem,
        title: title,
        heightFactor: heightFactor,
        itemRender: itemRender,
      );
    },
  );
}

/// ----------------------------------------------------------------
/// _SingleSelectBottomSheetContent widgeti
/// ----------------------------------------------------------------
/// Modal bottom sheet ning asosiy tarkibini tashkil etuvchi widget.
/// Unda sarlavha, qidiruv maydoni va elementlar ro'yxati mavjud.
class _SingleSelectBottomSheetContent<T> extends StatefulWidget {
  final List<T> items;
  final int Function(T) getId;
  final String Function(T) getName;
  final T? selectedItem;
  final String title;
  final double heightFactor;

  // Maxsus element chizish funksiyasi (agar berilsa).
  final Widget Function(T item, bool isSelected, void Function(bool? value) onChanged)? itemRender;

  const _SingleSelectBottomSheetContent({
    super.key,
    required this.items,
    required this.getId,
    required this.getName,
    this.selectedItem,
    required this.title,
    this.heightFactor = 0.8,
    this.itemRender,
  });

  @override
  State<_SingleSelectBottomSheetContent<T>> createState() => _SingleSelectBottomSheetContentState<T>();
}

class _SingleSelectBottomSheetContentState<T> extends State<_SingleSelectBottomSheetContent<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Dastlab barcha elementlar ko‘rsatiladi.
    _filteredItems = widget.items;
    // Qidiruv maydonidagi o‘zgarishlarni kuzatish.
    _searchController.addListener(_onSearchChanged);
  }

  /// Qidiruv maydonidagi o‘zgarishlar yuz berganda:
  /// - Kiritilgan matnni kichik harflarga o‘tkazamiz.
  /// - Elementlarni nomlarida qidiruv matni mavjudligini tekshiramiz.
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) => widget.getName(item).toLowerCase().contains(query)).toList();
    });
  }

  @override
  void dispose() {
    // Listenerni olib tashlash va controllerni yopish.
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Element tanlanganda modal bottom sheet-ni yopib, tanlangan elementni qaytaradi.
  void _selectItem(T item) {
    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Matn uslublari Theme orqali olinadi.
    final titleStyle = theme.textTheme.titleMedium;
    final itemStyle = theme.textTheme.labelMedium;
    final hintStyle = theme.textTheme.labelMedium?.copyWith(color: theme.hintColor);

    return Padding(
      // Klaviatura chiqishi holatini ham hisobga olamiz.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SizedBox(
        // Bottom sheet balandligi ekran balandligining [heightFactor] qismi.
        height: MediaQuery.of(context).size.height * widget.heightFactor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sarlavha va close tugmasi.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(Icons.close, size: 20, color: Colors.white),
                  ),
                  // Close tugmasi bosilganda hech qanday element tanlanmagan holda qaytish.
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Qidiruv maydoni.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Qidiruv',
                  hintStyle: hintStyle,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ),
            // Elementlar ro'yxati.
            Expanded(
              child: _filteredItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.selectedItem != null && widget.getId(widget.selectedItem as T) == widget.getId(item);
                        // Agar maxsus render funksiyasi berilgan bo‘lsa, uni ishlatamiz.
                        if (widget.itemRender != null) {
                          return GestureDetector(
                            onTap: () => _selectItem(item),
                            child: widget.itemRender!(item, isSelected, (_) {
                              _selectItem(item);
                            }),
                          );
                        }
                        // Aks holda, oddiy ListTile ko‘rinishida chiqaramiz.
                        return ListTile(
                          title: Text(
                            widget.getName(item),
                            style: itemStyle,
                          ),
                          trailing: isSelected ? Icon(Icons.check, color: theme.primaryColor) : null,
                          onTap: () => _selectItem(item),
                        );
                      },
                    )
                  : Center(child: Text("Ma'lumot yo'q", style: itemStyle)),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------------------------------------------
/// SingleSelectField widgeti – yagona tanlov forma maydoni
/// ----------------------------------------------------------------
/// InputDecorator orqali tanlangan elementni ko‘rsatadi va
/// modal bottom sheet orqali element tanlash imkoniyatini beradi.
class SingleSelectField<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) getName;
  final int Function(T) getId;

  // Dastlab tanlangan element (agar mavjud bo‘lsa).
  final T? selectedItem;

  // Field ustidagi label; agar bo‘sh bo‘lsa, "Tanlang" deb ko‘rsatiladi.
  final String labelText;
  final String hintText;
  final Widget? leading;
  final Widget? trailing;

  // Tanlov o‘zgarganida chaqiriladigan callback.
  final ValueChanged<T?>? onSelectionChanged;

  // Bottom sheet parametrlarini uzatish.
  final double bottomSheetHeightFactor;
  final bool bottomSheetIsDismissible;
  final bool bottomSheetEnableDrag;
  final String? bottomSheetTitle;

  // Maxsus item render funksiyasi (agar kerak bo‘lsa).
  final Widget Function(T item, bool isSelected, void Function(bool? value) onChanged)? itemRender;

  const SingleSelectField({
    super.key,
    required this.items,
    required this.getName,
    required this.getId,
    this.selectedItem,
    this.labelText = "",
    this.hintText = "Tanlang",
    this.leading,
    this.trailing,
    this.onSelectionChanged,
    this.bottomSheetHeightFactor = 0.8,
    this.bottomSheetIsDismissible = false,
    this.bottomSheetEnableDrag = false,
    this.bottomSheetTitle,
    this.itemRender,
  });

  @override
  State<SingleSelectField<T>> createState() => _SingleSelectFieldState<T>();
}

class _SingleSelectFieldState<T> extends State<SingleSelectField<T>> {
  // Dastlabki tanlangan qiymat widget.parametridan olinadi.
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  /// Bottom sheet ochilib, foydalanuvchi element tanlaganida natija qaytariladi.
  Future<void> _openSingleSelect() async {
    final result = await showSingleSelectBottomSheet<T>(
      context: context,
      items: widget.items,
      getId: widget.getId,
      getName: widget.getName,
      selectedItem: _selectedItem,
      title: widget.bottomSheetTitle ?? (widget.labelText.isNotEmpty ? widget.labelText : "Tanlang"),
      heightFactor: widget.bottomSheetHeightFactor,
      isDismissible: widget.bottomSheetIsDismissible,
      enableDrag: widget.bottomSheetEnableDrag,
      itemRender: widget.itemRender,
    );
    if (result != null) {
      setState(() {
        _selectedItem = result;
      });
      widget.onSelectionChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayStyle = theme.textTheme.labelMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Agar label berilgan bo‘lsa, uni yuqorida ko‘rsatish.
        if (widget.labelText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.labelText,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        InkWell(
          onTap: _openSingleSelect,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: _selectedItem == null ? widget.hintText : null,
              border: const OutlineInputBorder(),
              prefixIcon: widget.leading,
              suffixIcon: widget.trailing ?? const Icon(Icons.arrow_drop_down),
            ),
            child: _selectedItem != null
                ? ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: double.infinity),
                    child: Text(
                      widget.getName(_selectedItem as T),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: displayStyle,
                    ),
                  )
                : Text(
                    widget.hintText,
                    style: TextStyle(color: theme.hintColor),
                  ),
          ),
        ),
      ],
    );
  }
}
