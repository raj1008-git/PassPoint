import 'package:equatable/equatable.dart';

import '../model/product_model.dart';

abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load all products (for receptionist)
class LoadAllProducts extends ProductEvent {}

// Load staff products
class LoadStaffProducts extends ProductEvent {
  final String staffName;

  LoadStaffProducts(this.staffName);

  @override
  List<Object?> get props => [staffName];
}

// Receive by reception
class ReceiveByReception extends ProductEvent {
  final String productId;
  final String receptionistName;

  ReceiveByReception({required this.productId, required this.receptionistName});

  @override
  List<Object?> get props => [productId, receptionistName];
}

// Forward product
class ForwardProduct extends ProductEvent {
  final String productId;
  final String fromStaffName;
  final String fromDepartment;
  final String toDepartmentId;
  final String toDepartmentName;
  final String toPersonName;
  final String feedback;

  ForwardProduct({
    required this.productId,
    required this.fromStaffName,
    required this.fromDepartment,
    required this.toDepartmentId,
    required this.toDepartmentName,
    required this.toPersonName,
    required this.feedback,
  });

  @override
  List<Object?> get props => [
    productId,
    fromStaffName,
    fromDepartment,
    toDepartmentId,
    toDepartmentName,
    toPersonName,
    feedback,
  ];
}

// Complete product
class CompleteProduct extends ProductEvent {
  final String productId;
  final String staffName;
  final String department;
  final String feedback;
  final String signatureUrl;

  CompleteProduct({
    required this.productId,
    required this.staffName,
    required this.department,
    required this.feedback,
    required this.signatureUrl,
  });

  @override
  List<Object?> get props => [
    productId,
    staffName,
    department,
    feedback,
    signatureUrl,
  ];
}

// Internal event for real-time updates
class ProductsUpdated extends ProductEvent {
  final List<ProductModel> products;

  ProductsUpdated(this.products);

  @override
  List<Object?> get props => [products];
}
