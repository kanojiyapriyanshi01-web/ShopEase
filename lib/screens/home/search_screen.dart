// lib/screens/home/search_screen.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  List<Product> _results = [];

  final List<String> _recent = ['Silk Saree', 'T-Shirt', 'Gold Necklace', 'Vitamin C Serum'];
  final List<String> _trending = ['Kurtis', 'Jeans', 'Lipstick', 'Earbuds', 'Sneakers', 'Face Wash'];

  @override
  void initState() {
    super.initState();
    // initialQuery from voice search
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _ctrl.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _search(widget.initialQuery!);
      });
    } else {
      // From route arguments
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final query = ModalRoute.of(context)?.settings.arguments as String?;
        if (query != null && query.isNotEmpty) {
          _ctrl.text = query;
          _search(query);
        }
      });
    }
  }

  void _search(String q) {
    setState(() {
      _query = q;
      _results = SampleData.products
          .where((p) =>
              p.name.toLowerCase().contains(q.toLowerCase()) ||
              p.category.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0.5,
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: widget.initialQuery == null,
          onChanged: _search,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                fontSize: 14),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () { _ctrl.clear(); _search(''); })
                : null,
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildEmptyState(isDark)
          : _results.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.search_off, size: 60,
                      color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                  const SizedBox(height: 12),
                  Text('No results found for "$_query"',
                      style: TextStyle(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textGrey,
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Try a different keyword',
                      style: TextStyle(
                          color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                          fontSize: 13)),
                ]))
              : Column(children: [
                  // Results count
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(children: [
                      Text('${_results.length} results for ',
                          style: TextStyle(fontSize: 13,
                              color: isDark ? AppTheme.darkTextSecondary : Colors.grey)),
                      Text('"$_query"',
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ]),
                  ),
                  Expanded(child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10,
                        mainAxisSpacing: 10, childAspectRatio: 0.62),
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) => ProductCard(product: _results[i]),
                  )),
                ]),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recent.isNotEmpty) ...[
          Text('Recent Searches',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8,
              children: _recent.map((s) => ActionChip(
                    label: Text(s),
                    avatar: const Icon(Icons.history, size: 14),
                    onPressed: () { _ctrl.text = s; _search(s); },
                    backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
                    labelStyle: TextStyle(fontSize: 13,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                    side: BorderSide(color: isDark ? AppTheme.darkDivider : Colors.grey.shade300),
                  )).toList()),
          const SizedBox(height: 20),
        ],
        Text('Trending',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8,
            children: _trending.map((s) => ActionChip(
                  label: Text(s),
                  avatar: const Icon(Icons.trending_up, size: 14, color: Colors.orange),
                  onPressed: () { _ctrl.text = s; _search(s); },
                  backgroundColor: isDark ? AppTheme.darkCard : Colors.orange.shade50,
                  labelStyle: TextStyle(fontSize: 13,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textDark),
                  side: BorderSide(color: isDark ? AppTheme.darkDivider : Colors.orange.shade200),
                )).toList()),
      ],
    );
  }
}