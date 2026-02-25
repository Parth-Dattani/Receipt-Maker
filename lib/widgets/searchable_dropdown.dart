import 'package:flutter/material.dart';

/// Improved Searchable Dropdown Widget - No setState during build
class SearchableDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String hintText;
  final String searchHintText;
  final Widget Function(T)? itemBuilder;
  /// Optional: string used for search/filter. If null, [itemLabel] is used.
  final String Function(T)? searchLabel;
  final bool enabled;

  const SearchableDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.hintText = 'Select an option',
    this.searchHintText = 'Search...',
    this.itemBuilder,
    this.searchLabel,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _SearchDialog<T>(
        items: widget.items,
        value: widget.value,
        itemLabel: widget.itemLabel,
        onChanged: widget.onChanged,
        hintText: widget.hintText,
        searchHintText: widget.searchHintText,
        itemBuilder: widget.itemBuilder,
        searchLabel: widget.searchLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? _showSearchDialog : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: widget.enabled ? Colors.white : Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.value != null
                    ? widget.itemLabel(widget.value as T)
                    : widget.hintText,
                style: TextStyle(
                  color: widget.value != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: widget.enabled ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

/// Separate stateful widget for the search dialog
class _SearchDialog<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String hintText;
  final String searchHintText;
  final Widget Function(T)? itemBuilder;
  final String Function(T)? searchLabel;

  const _SearchDialog({
    Key? key,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
    required this.hintText,
    required this.searchHintText,
    this.itemBuilder,
    this.searchLabel,
  }) : super(key: key);

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  late final TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = List.from(widget.items);

    // Add listener to update filtered items
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        final q = query.toLowerCase();
        _filteredItems = widget.items.where((item) {
          final label = (widget.searchLabel ?? widget.itemLabel)(item).toLowerCase();
          return label.contains(q);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    // setState will be triggered by the listener
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.hintText),
      contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search TextField
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHintText,
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            SizedBox(height: 16),

            // Results count
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredItems.length} result${_filteredItems.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

            // Results List
            Flexible(
              child: _filteredItems.isEmpty
                  ? Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No results found',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = widget.value == item;

                  return InkWell(
                    onTap: () {
                      widget.onChanged(item);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade50
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: widget.itemBuilder != null
                                ? widget.itemBuilder!(item)
                                : Text(
                              widget.itemLabel(item),
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.blue.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        if (widget.value != null)
          TextButton(
            onPressed: () {
              widget.onChanged(null);
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}