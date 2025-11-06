import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pass_point/core/utils/dev.log.dart';
import 'package:pass_point/features/visitor/bloc/visitor_event.dart';
import 'package:pass_point/features/visitor/bloc/visitor_state.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  VisitorBloc() : super(VisitorInitial()) {
    // Event Handler Registration.
    on<VisitorInitEvent>(_onInit);
    devLog('Visitor Bloc created');
  }
  Future<void> _onInit(
    VisitorInitEvent event,
    Emitter<VisitorState> emit,
  ) async {
    devLog('Visitor Bloc _onInit called: Starting Initialization sequence');
    emit(VisitorLoading());
    await Future.delayed(Duration(milliseconds: 350));
    emit(VisitorReady());
    devLog('VisitorBLoc ready: Initialization Complete');
  }
}
