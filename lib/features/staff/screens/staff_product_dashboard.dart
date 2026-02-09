import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/product_export_service.dart';
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
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
    ); // Changed from 4 to 5
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

  Future<void> _exportMyProducts(List<ProductModel> products) async {
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 16),
              Text('Exporting your products...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      // Export staff products using existing static method
      final path = await ProductExportService.exportStaffProducts(
        widget.staffName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${products.length} products to:\n$path'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
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
        actions: [
          // Export CSV Button
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              final products = (state is ProductLoaded)
                  ? state.products
                  : (state is ProductOperationInProgress)
                  ? state.products
                  : (state is ProductOperationSuccess)
                  ? state.products
                  : <ProductModel>[];

              return IconButton(
                icon: const Icon(Icons.download, color: AppTheme.info),
                tooltip: 'Export to CSV',
                onPressed: products.isEmpty
                    ? null
                    : () => _exportMyProducts(products),
              );
            },
          ),
        ],
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
                  Tab(text: 'Sent'), // NEW TAB
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
              _buildSentProductsList(), // NEW - Shows products staff created
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

  // New method to show sent products
  Widget _buildSentProductsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where(
            'createdByStaffId',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid,
          )
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sentProducts = snapshot.data!.docs
            .map((doc) => ProductModel.fromSnapshot(doc))
            .toList();

        // Apply search filter
        final filtered = _searchQuery.isEmpty
            ? sentProducts
            : sentProducts.where((p) {
                final query = _searchQuery.toLowerCase();
                return p.registrationNumber.toLowerCase().contains(query) ||
                    p.subject.toLowerCase().contains(query) ||
                    p.targetPersonName.toLowerCase().contains(query);
              }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_outlined,
                  size: 64,
                  color: AppTheme.grey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products sent yet',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Products you send will appear here',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final product = filtered[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSentProductTile(product),
            );
          },
        );
      },
    );
  }

  // New tile for sent products (shows status tracking)
  Widget _buildSentProductTile(ProductModel product) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => ProductDetailsDialog(product: product),
        );
      },
      borderRadius: AppTheme.radiusMedium,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(color: AppTheme.greyLight, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Registration Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.numbers, size: 14, color: AppTheme.info),
                      const SizedBox(width: 4),
                      Text(
                        product.registrationNumber,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.info,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Status Badge
                _buildStatusBadge(product.currentStatus),
              ],
            ),

            const SizedBox(height: 12),

            // Subject
            Text(
              product.subject,
              style: AppTheme.labelLarge.copyWith(fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Sent To
            Row(
              children: [
                const Icon(Icons.send, size: 14, color: AppTheme.info),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Sent to: ${product.targetDepartmentName} - ${product.targetPersonName}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Current Status Info
            if (product.currentStatus == 'forwarded' ||
                product.currentStatus == 'completed') ...[
              Row(
                children: [
                  Icon(
                    product.currentStatus == 'completed'
                        ? Icons.check_circle
                        : Icons.location_on,
                    size: 14,
                    color: product.currentStatus == 'completed'
                        ? AppTheme.success
                        : AppTheme.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      product.currentStatus == 'completed'
                          ? 'Completed by ${product.currentPersonName ?? "Unknown"}'
                          : 'Currently with: ${product.currentPersonName ?? "In transit"}',
                      style: AppTheme.bodySmall.copyWith(
                        color: product.currentStatus == 'completed'
                            ? AppTheme.success
                            : AppTheme.warning,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            if (product.currentStatus == 'submitted') ...[
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppTheme.warning),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Awaiting receptionist approval',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'submitted':
        bgColor = AppTheme.pendingOrange;
        textColor = AppTheme.pendingOrangeIcon;
        label = 'Pending';
        break;
      case 'received_by_reception':
        bgColor = AppTheme.checkedInGreen;
        textColor = AppTheme.checkedInGreenIcon;
        label = 'Received';
        break;
      case 'forwarded':
        bgColor = AppTheme.checkedOutBlue;
        textColor = AppTheme.info;
        label = 'In Transit';
        break;
      case 'completed':
        bgColor = AppTheme.totalPurple;
        textColor = AppTheme.totalPurpleIcon;
        label = 'Completed';
        break;
      default:
        bgColor = AppTheme.greyLight;
        textColor = AppTheme.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
