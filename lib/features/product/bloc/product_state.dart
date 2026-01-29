import 'package:equatable/equatable.dart';

import '../model/product_model.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;

  ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductOperationInProgress extends ProductState {
  final List<ProductModel> products;

  ProductOperationInProgress(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductOperationSuccess extends ProductState {
  final List<ProductModel> products;
  final String message;

  ProductOperationSuccess(this.products, this.message);

  @override
  List<Object?> get props => [products, message];
}

class ProductError extends ProductState {
  final String message;
  final List<ProductModel> products;

  ProductError(this.message, this.products);

  @override
  List<Object?> get props => [message, products];
}
