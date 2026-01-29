import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../product/bloc/product_bloc.dart';
import '../../product/bloc/product_state.dart';
import '../../product/model/product_model.dart';
import '../../product/widgets/complete_product_dialog.dart';
import '../../product/widgets/forward_product_dialog.dart';
import '../../product/widgets/product_details_dialog.dart';
import '../../product/widgets/product_list_tile.dart';

class StaffProductDashboard extends StatefulWidget {
  final String staffName;
  final String department;

  const StaffProductDashboard({
    Key? key,
    required this.staffName,
    required this.department,
  }) : super(key: key);

  @override
  State<StaffProductDashboard> createState() => _StaffProductDashboardState();
}

class _StaffProductDashboardState extends State<StaffProductDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ProductModel> _filterProducts(
    List<ProductModel> products,
    String status,
  ) {
    var filtered = products;

    if (status != 'all') {
      filtered = filtered.where((p) => p.currentStatus == status).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final query = _searchQuery.toLowerCase();
        return p.registrationNumber.toLowerCase().contains(query) ||
            p.subject.toLowerCase().contains(query) ||
            p.senderOfficeName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Future<void> _forwardProduct(ProductModel product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ForwardProductDialog(
        product: product,
        currentStaffName: widget.staffName,
        currentDepartment: widget.department,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product forwarded successfully'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  Future<void> _completeProduct(ProductModel product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => CompleteProductDialog(
        product: product,
        staffName: widget.staffName,
        department: widget.department,
        isReceptionist: false,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product marked as completed'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.dark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Products',
          style: TextStyle(color: AppTheme.dark),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppTheme.info.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Showing products assigned to: ${widget.staffName}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                    filled: true,
                    fillColor: AppTheme.greyLight.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: AppTheme.radiusMedium,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryRed,
                unselectedLabelColor: AppTheme.grey,
                indicatorColor: AppTheme.primaryRed,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Received'),
                  Tab(text: 'Forwarded'),
                  Tab(text: 'Completed'),
                  Tab(text: 'All'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message, style: AppTheme.bodyLarge),
                ],
              ),
            );
          }

          final products = (state is ProductLoaded)
              ? state.products
              : (state is ProductOperationInProgress)
              ? state.products
              : (state is ProductOperationSuccess)
              ? state.products
              : <ProductModel>[];

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(
                _filterProducts(products, 'received_by_reception'),
              ),
              _buildProductList(_filterProducts(products, 'forwarded')),
              _buildProductList(_filterProducts(products, 'completed')),
              _buildProductList(_filterProducts(products, 'all')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No products assigned to you',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductListTile(
            product: product,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ProductDetailsDialog(product: product),
              );
            },
            actionButton: _buildActionButtons(product),
          ),
        );
      },
    );
  }

  Widget? _buildActionButtons(ProductModel product) {
    // Can't take action on completed products
    if (product.currentStatus == 'completed') {
      return null;
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _forwardProduct(product),
                icon: const Icon(Icons.forward, size: 18),
                label: const Text('Forward'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.info,
                  side: const BorderSide(color: AppTheme.info),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _completeProduct(product),
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.success,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
