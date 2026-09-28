import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ecommerce_mobile/config/theme/app_spacing.dart';
import 'package:ecommerce_mobile/config/theme/app_typography.dart';
import 'package:ecommerce_mobile/features/product/data/models/product_model.dart';
import 'package:ecommerce_mobile/features/product/data/product_repository.dart';
import 'package:ecommerce_mobile/features/product/presentation/widgets/product_card.dart';
import 'package:ecommerce_mobile/routing/app_routes.dart';
import 'package:ecommerce_mobile/shared/widgets/empty_view.dart';
import 'package:ecommerce_mobile/shared/widgets/loading_indicator.dart';

class ProductFilterNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() {
    return {'search': '', 'category': '', 'sortBy': 'createdAt', 'sortOrder': 'DESC'};
  }

  void updateFilter(Map<String, dynamic> newFilter) {
    state = {...state, ...newFilter};
  }

  void setSearch(String search) {
    state = {...state, 'search': search};
  }

  void setSort(String sortBy, String sortOrder) {
    state = {...state, 'sortBy': sortBy, 'sortOrder': sortOrder};
  }
}

final productFilterNotifierProvider =
    NotifierProvider<ProductFilterNotifier, Map<String, dynamic>>(
  ProductFilterNotifier.new,
);

final productListProvider = FutureProvider<List<ProductModel>>((ref) async {
  final filter = ref.watch(productFilterNotifierProvider);
  final repo = ref.watch(productRepositoryProvider);

  final res = await repo.getProducts(
    search: filter['search'] as String?,
    categoryId: filter['category'] as String?,
    sortBy: filter['sortBy'] as String?,
    sortOrder: filter['sortOrder'] as String?,
    limit: 20,
  );
  return res.items;
});

class ProductListScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final String? initialSearch;

  const ProductListScreen({
    super.key,
    this.initialCategory,
    this.initialSearch,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCategory != null || widget.initialSearch != null) {
        ref.read(productFilterNotifierProvider.notifier).updateFilter({
          if (widget.initialCategory != null) 'category': widget.initialCategory,
          if (widget.initialSearch != null) 'search': widget.initialSearch,
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(productFilterNotifierProvider.notifier).setSearch(query.trim());
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Sắp xếp theo', style: AppTypography.h3),
              ),
              ListTile(
                title: const Text('Mới nhất'),
                onTap: () {
                  ref.read(productFilterNotifierProvider.notifier).setSort('createdAt', 'DESC');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Giá: Thấp đến cao'),
                onTap: () {
                  ref.read(productFilterNotifierProvider.notifier).setSort('price', 'ASC');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Giá: Cao đến thấp'),
                onTap: () {
                  ref.read(productFilterNotifierProvider.notifier).setSort('price', 'DESC');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sản Phẩm', style: AppTypography.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showSortSheet,
            tooltip: 'Sắp xếp & Bộ lọc',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Products Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(productListProvider),
              child: productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const EmptyView(
                      icon: Icons.search_off,
                      title: 'Không tìm thấy sản phẩm',
                      description: 'Thử tìm kiếm với từ khóa khác hoặc xóa bộ lọc.',
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
                      );
                    },
                  );
                },
                loading: () => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, _) => const ProductCardSkeleton(),
                ),
                error: (err, _) => Center(
                  child: EmptyView(
                    icon: Icons.error_outline,
                    title: 'Đã có lỗi xảy ra',
                    description: err.toString(),
                    buttonText: 'Thử lại',
                    onButtonPressed: () => ref.invalidate(productListProvider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
