import 'package:equatable/equatable.dart';

abstract class VisitorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitorInitial extends VisitorState {}

class VisitorLoading extends VisitorState {}

class VisitorReady extends VisitorState {}
