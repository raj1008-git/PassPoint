import 'package:equatable/equatable.dart';

abstract class DepartmentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Load departments
class LoadDepartments extends DepartmentEvent {}

// Create department
class CreateDepartment extends DepartmentEvent {
  final String name;

  CreateDepartment(this.name);

  @override
  List<Object?> get props => [name];
}

// Update department
class UpdateDepartment extends DepartmentEvent {
  final String id;
  final String newName;

  UpdateDepartment(this.id, this.newName);

  @override
  List<Object?> get props => [id, newName];
}

// Delete department
class DeleteDepartment extends DepartmentEvent {
  final String id;

  DeleteDepartment(this.id);

  @override
  List<Object?> get props => [id];
}
