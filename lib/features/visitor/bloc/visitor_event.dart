import 'package:equatable/equatable.dart';

abstract class VisitorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitorInitEvent extends VisitorEvent {}
