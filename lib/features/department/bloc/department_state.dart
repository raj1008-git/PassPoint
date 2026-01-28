import 'package:equatable/equatable.dart';

import '../../../data/models/department_model.dart';

abstract class DepartmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

// Initial state
class DepartmentInitial extends DepartmentState {}

// Loading state
class DepartmentLoading extends DepartmentState {}

// Loaded state (with list of departments)
class DepartmentLoaded extends DepartmentState {
  final List<Department> departments;

  DepartmentLoaded(this.departments);

  @override
  List<Object?> get props => [departments];
}

// Operation in progress (create/update/delete)
class DepartmentOperationInProgress extends DepartmentState {
  final List<Department> departments;

  DepartmentOperationInProgress(this.departments);

  @override
  List<Object?> get props => [departments];
}

// Operation success
class DepartmentOperationSuccess extends DepartmentState {
  final List<Department> departments;
  final String message;

  DepartmentOperationSuccess(this.departments, this.message);

  @override
  List<Object?> get props => [departments, message];
}

// Error state
class DepartmentError extends DepartmentState {
  final String message;
  final List<Department> departments;

  DepartmentError(this.message, this.departments);

  @override
  List<Object?> get props => [message, departments];
}
