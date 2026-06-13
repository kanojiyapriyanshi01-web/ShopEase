// lib/screens/home/search_screen.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  List<Product> _results = [];

  final List<String> _recent = [
    'Silk Saree',
    'T-Shirt',
    'Gold Necklace',
    'Vitamin C Serum',
  ];
  final List<String> _trending = [
    'Kurtis',
    'Jeans',
    'Lipstick',
    'Earbuds',
    'Sneakers',
    'Face Wash',
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: InputBorder.none,
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      _search('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildEmptyState()
          : _results.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No results found',
                          style: TextStyle(
                              color: AppTheme.textGrey, fontSize: 16)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: _results.length,
                  itemBuilder: (ctx, i) =>
                      ProductCard(product: _results[i]),
                ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recent searches
        if (_recent.isNotEmpty) ...[
          const Text(
            'Recent Searches',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recent
                .map((s) => ActionChip(
                      label: Text(s),
                      avatar:
                          const Icon(Icons.history, size: 14),
                      onPressed: () {
                        _ctrl.text = s;
                        _search(s);
                      },
                      backgroundColor: Colors.white,
                      labelStyle: const TextStyle(
                          fontSize: 13, color: AppTheme.textDark),
                      side: BorderSide(color: Colors.grey.shade300),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],

        // Trending
        const Text(
          'Trending',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trending
              .map((s) => ActionChip(
                    label: Text(s),
                    avatar: const Icon(Icons.trending_up,
                        size: 14, color: Colors.orange),
                    onPressed: () {
                      _ctrl.text = s;
                      _search(s);
                    },
                    backgroundColor: Colors.orange.shade50,
                    labelStyle: const TextStyle(
                        fontSize: 13, color: AppTheme.textDark),
                    side: BorderSide(color: Colors.orange.shade200),
                  ))
              .toList(),
        ),
      ],
    );
  }
}