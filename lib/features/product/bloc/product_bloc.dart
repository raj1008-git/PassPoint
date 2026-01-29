import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/dev.log.dart';
import '../../../data/repositories/product_repository.dart';
import '../model/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;
  StreamSubscription<List<ProductModel>>? _productSubscription;

  ProductBloc({ProductRepository? repository})
    : _repository = repository ?? ProductRepository(),
      super(ProductInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadStaffProducts>(_onLoadStaffProducts);
    on<ReceiveByReception>(_onReceiveByReception);
    on<ForwardProduct>(_onForwardProduct);
    on<CompleteProduct>(_onCompleteProduct);
    on<ProductsUpdated>(_onProductsUpdated);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());

      await _productSubscription?.cancel();

      _productSubscription = _repository.getAllProductsStream().listen(
        (products) {
          add(ProductsUpdated(products));
        },
        onError: (error) {
          devLog('Product stream error', params: {'error': error.toString()});
        },
      );
    } catch (e) {
      devLog('Error loading products', params: {'error': e.toString()});
      emit(ProductError(e.toString(), []));
    }
  }

  Future<void> _onLoadStaffProducts(
    LoadStaffProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());

      await _productSubscription?.cancel();

      _productSubscription = _repository
          .getStaffProductsStream(event.staffName)
          .listen(
            (products) {
              add(ProductsUpdated(products));
            },
            onError: (error) {
              devLog(
                'Product stream error',
                params: {'error': error.toString()},
              );
            },
          );
    } catch (e) {
      devLog('Error loading staff products', params: {'error': e.toString()});
      emit(ProductError(e.toString(), []));
    }
  }

  Future<void> _onReceiveByReception(
    ReceiveByReception event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    final currentProducts = currentState is ProductLoaded
        ? currentState.products
        : <ProductModel>[];

    try {
      emit(ProductOperationInProgress(currentProducts));

      await _repository.receiveByReception(
        event.productId,
        event.receptionistName,
      );

      devLog('Product received by reception');
    } catch (e) {
      devLog('Error receiving product', params: {'error': e.toString()});
      emit(ProductError(e.toString(), currentProducts));
    }
  }

  Future<void> _onForwardProduct(
    ForwardProduct event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    final currentProducts = currentState is ProductLoaded
        ? currentState.products
        : <ProductModel>[];

    try {
      emit(ProductOperationInProgress(currentProducts));

      await _repository.forwardProduct(
        productId: event.productId,
        fromStaffName: event.fromStaffName,
        fromDepartment: event.fromDepartment,
        toDepartmentId: event.toDepartmentId,
        toDepartmentName: event.toDepartmentName,
        toPersonName: event.toPersonName,
        feedback: event.feedback,
      );

      devLog('Product forwarded successfully');
    } catch (e) {
      devLog('Error forwarding product', params: {'error': e.toString()});
      emit(ProductError(e.toString(), currentProducts));
    }
  }

  Future<void> _onCompleteProduct(
    CompleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    final currentProducts = currentState is ProductLoaded
        ? currentState.products
        : <ProductModel>[];

    try {
      emit(ProductOperationInProgress(currentProducts));

      await _repository.completeProduct(
        productId: event.productId,
        staffName: event.staffName,
        department: event.department,
        feedback: event.feedback,
        signatureUrl: event.signatureUrl,
      );

      devLog('Product completed successfully');
    } catch (e) {
      devLog('Error completing product', params: {'error': e.toString()});
      emit(ProductError(e.toString(), currentProducts));
    }
  }

  Future<void> _onProductsUpdated(
    ProductsUpdated event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    if (currentState is ProductOperationInProgress) {
      emit(
        ProductOperationSuccess(
          event.products,
          'Operation completed successfully',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) {
        emit(ProductLoaded(event.products));
      }
    } else {
      emit(ProductLoaded(event.products));
    }
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}
