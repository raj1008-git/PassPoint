import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/dev.log.dart';
import '../../../data/models/department_model.dart';
import '../../../data/repositories/department_repository.dart';
import 'department_event.dart';
import 'department_state.dart';

class DepartmentBloc extends Bloc<DepartmentEvent, DepartmentState> {
  final DepartmentRepository _repository;
  StreamSubscription<List<Department>>? _departmentSubscription;

  DepartmentBloc({DepartmentRepository? repository})
    : _repository = repository ?? DepartmentRepository(),
      super(DepartmentInitial()) {
    on<LoadDepartments>(_onLoadDepartments);
    on<CreateDepartment>(_onCreateDepartment);
    on<UpdateDepartment>(_onUpdateDepartment);
    on<DeleteDepartment>(_onDeleteDepartment);
    on<_DepartmentsUpdated>(_onDepartmentsUpdated);
  }

  Future<void> _onLoadDepartments(
    LoadDepartments event,
    Emitter<DepartmentState> emit,
  ) async {
    try {
      emit(DepartmentLoading());

      // Cancel existing subscription
      await _departmentSubscription?.cancel();

      // Subscribe to real-time updates
      _departmentSubscription = _repository.getDepartmentsStream().listen(
        (departments) {
          add(_DepartmentsUpdated(departments));
        },
        onError: (error) {
          devLog(
            'Department stream error',
            params: {'error': error.toString()},
          );
        },
      );
    } catch (e) {
      devLog('Error loading departments', params: {'error': e.toString()});
      emit(DepartmentError(e.toString(), []));
    }
  }

  Future<void> _onCreateDepartment(
    CreateDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    final currentState = state;
    final currentDepts = currentState is DepartmentLoaded
        ? currentState.departments
        : <Department>[];

    try {
      emit(DepartmentOperationInProgress(currentDepts));

      await _repository.createDepartment(event.name);

      devLog('Department created successfully');
      // Real-time stream will update the list automatically
    } catch (e) {
      devLog('Error creating department', params: {'error': e.toString()});
      emit(DepartmentError(e.toString(), currentDepts));
    }
  }

  Future<void> _onUpdateDepartment(
    UpdateDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    final currentState = state;
    final currentDepts = currentState is DepartmentLoaded
        ? currentState.departments
        : <Department>[];

    try {
      emit(DepartmentOperationInProgress(currentDepts));

      await _repository.updateDepartment(event.id, event.newName);

      devLog('Department updated successfully');
      // Real-time stream will update the list automatically
    } catch (e) {
      devLog('Error updating department', params: {'error': e.toString()});
      emit(DepartmentError(e.toString(), currentDepts));
    }
  }

  Future<void> _onDeleteDepartment(
    DeleteDepartment event,
    Emitter<DepartmentState> emit,
  ) async {
    final currentState = state;
    final currentDepts = currentState is DepartmentLoaded
        ? currentState.departments
        : <Department>[];

    try {
      emit(DepartmentOperationInProgress(currentDepts));

      await _repository.deleteDepartment(event.id);

      devLog('Department deleted successfully');
      // Real-time stream will update the list automatically
    } catch (e) {
      devLog('Error deleting department', params: {'error': e.toString()});
      emit(DepartmentError(e.toString(), currentDepts));
    }
  }

  Future<void> _onDepartmentsUpdated(
    _DepartmentsUpdated event,
    Emitter<DepartmentState> emit,
  ) async {
    final currentState = state;

    if (currentState is DepartmentOperationInProgress) {
      // If operation was in progress, show success
      emit(
        DepartmentOperationSuccess(
          event.departments,
          'Operation completed successfully',
        ),
      );
      // After a brief moment, go back to loaded state
      await Future.delayed(const Duration(milliseconds: 500));
      if (!isClosed) {
        emit(DepartmentLoaded(event.departments));
      }
    } else {
      // Just update the list
      emit(DepartmentLoaded(event.departments));
    }
  }

  @override
  Future<void> close() {
    _departmentSubscription?.cancel();
    return super.close();
  }
}

// Internal event for real-time updates
class _DepartmentsUpdated extends DepartmentEvent {
  final List<Department> departments;

  _DepartmentsUpdated(this.departments);

  @override
  List<Object?> get props => [departments];
}
