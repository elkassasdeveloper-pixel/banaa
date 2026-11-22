import 'package:flutter_bloc/flutter_bloc.dart';

class McqQuestionCubit extends Cubit<McqQuestionState> {
  McqQuestionCubit() : super(McqQuestionInitial());
}
sealed class McqQuestionState {}

final class McqQuestionInitial extends McqQuestionState {}
