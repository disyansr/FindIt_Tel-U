import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../viewmodels/item_viewmodel.dart';
import '../widgets/item_card.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchKeyword = '';
  String _filterStatus = 'Semua';

  final List<String> _filters = ['Semua', 'Hilang', 'Ditemukan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HomeHeader(onSearch: (value) {
            setState(() => _searchKeyword = value);
          }),
          // Filter Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final filter = _filters[i];
                final isSelected = _filterStatus == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _filterStatus = filter),
                  selectedColor: const Color(0xFFB71C1C),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ItemModel>>(
              stream: context.read<ItemViewModel>().itemsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat data.'));
                }

                final items = (snapshot.data ?? []).where((item) {
                  final q = _searchKeyword.toLowerCase();
                  final matchSearch = item.title.toLowerCase().contains(q) ||
                      item.location.toLowerCase().contains(q);
                  final matchFilter = _filterStatus == 'Semua' ||
                      item.status == _filterStatus;
                  return matchSearch && matchFilter;
                }).toList();

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          _filterStatus == 'Semua'
                              ? 'Belum ada laporan barang.'
                              : 'Tidak ada barang "$_filterStatus".',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: items.length,
                  itemBuilder: (_, i) => ItemCard(item: items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}