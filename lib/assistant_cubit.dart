import 'dart:async';

import 'package:educ_core/services/dio_helper.dart';
import 'package:educ_core/utils/helpers.dart';
import 'package:educ_core/utils/result.dart';
import 'package:educ_student/core/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const assistantShowDuration = Duration(milliseconds: 800);
const bubbleTransitionDuration = Duration(milliseconds: 500);
const bubbleDuration = Duration(seconds: 3);

class AssistantCubit extends Cubit<AssistantState> {
  int appEventCode;

  AssistantCubit({required this.appEventCode}) : super(AssistantInitial()) {
    getBubbles().whenComplete(() {
      if (assistantBubbles.isNotEmpty) {
        resetAssistant();
      }
    });
  }

  List<AssistantBubble> assistantBubbles = [];

  List<AssistantBubble> allAssistantBubbles = [];
  bool isAssistantActive = false;
  bool isBubbleActive = false;
  bool isBubbleShown = false;
  int currentIndex = 0;
  int _runId = 0; // bump to cancel any running bubble loop

  void _clearBubble() {
    isBubbleActive = false;
    isBubbleShown = false;
  }

  void resetAssistant() {
    currentIndex = 0;
    showNextBubble();
  }

  Future<void> showNextBubble() async {
    final run = ++_runId; // cancels any previous loop
    bool cancelled() => isClosed || run != _runId;
    if (assistantBubbles.isEmpty) {
      currentIndex = 0;
      _clearBubble();
      await deactivateAssistant();
      emit(AssistantBubbleChanged());
      return;
    }
    while (!cancelled() && currentIndex < assistantBubbles.length) {
      await activateAssistant();
      if (cancelled()) return;
      await showBubble();
      if (cancelled()) return;
      await Future.delayed(bubbleDuration);
      if (cancelled()) return;
      await hideBubble();
      if (cancelled()) return;
      deactivateBubble();

      currentIndex++;
    }

    if (!cancelled()) await deactivateAssistant();
  }

  void setEventCode(int newCode) async {
    appEventCode = newCode;
    _runId++;
    _clearBubble();
    // await getBubbles();
    assistantBubbles = allAssistantBubbles
        .where((element) => element.appEventId == appEventCode)
        .toList();
    currentIndex = 0;
    if (!isClosed) emit(AssistantBubbleChanged());
  }

  void triggerAssistant() => showNextBubble();

  Future<void> getBubbles() async {
    try {
      final response = await DioHelper.dio.get(
        '/api/CodeAssitantBubble/GetList',
        queryParameters: {'m_code': '812'},
      );

      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] is List) {
        final List<dynamic> items = data['data'];

        allAssistantBubbles = List<AssistantBubble>.from(
          items.map((e) => AssistantBubble.fromJson(e)),
        ).where((element) => element.isActive == 'Y').toList();
        setEventCode(appEventCode);

        emit(AssistantLoaded());
      } else {
        throw Exception('Invalid response structure');
      }
    } catch (e, stack) {
      debugPrint('❌ Error loading bubbles: $e');
      debugPrint(stack.toString());
    }
  }

  AssistantBubble? getCurrentBubble() {
    if (assistantBubbles.isEmpty) return null;
    if (currentIndex < 0 || currentIndex >= assistantBubbles.length) {
      return assistantBubbles.last; // رجّع آخر واحدة بدل الكراش
    }
    return assistantBubbles[currentIndex];
  }

  Future<void> activateAssistant() async {
    isAssistantActive = true;
    emit(AssistantBubbleChanged());
    await Future.delayed(assistantShowDuration);
  }

  Future<void> deactivateAssistant() async {
    isAssistantActive = false;
    _clearBubble(); // the bubble can never outlive the assistant
    if (isClosed) return;
    emit(AssistantBubbleChanged());
    await Future.delayed(assistantShowDuration);
  }

  // void activateBubble() {
  //   isBubbleActive = true;
  //   emit(AssistantBubbleChanged());
  // }

  void deactivateBubble() {
    isBubbleActive = false;
    emit(AssistantBubbleChanged());
  }

  Future<void> showBubble() async {
    final run = _runId;
    isBubbleActive = true;
    emit(AssistantBubbleChanged());
    doPostFrame((_) {
      if (isClosed || run != _runId) return;
      isBubbleShown = true;
      emit(AssistantBubbleChanged());
    });
    await Future.delayed(bubbleTransitionDuration);
  }

  Future<void> hideBubble() async {
    isBubbleShown = false;
    emit(AssistantBubbleChanged());
    await Future.delayed(bubbleTransitionDuration);
  }

  @override
  Future<void> close() {
    _runId++; // stop any pending loop so it can't emit after close
    return super.close();
  }
}

sealed class AssistantState {}

final class AssistantInitial extends AssistantState {}

final class AssistantLoading extends AssistantState {}

final class AssistantLoaded extends AssistantState {}

final class AssistantError extends AssistantState {
  final Failure failure;

  AssistantError(this.failure);
}

final class AssistantBubbleChanged extends AssistantState {}

class AssistantBubble {
  int appEventId;
  String fkAppEventIdDescr;
  String objectCode;
  int bubbleSeq;
  String imageUrl;
  String bubbleTextA;
  String bubbleTextE;
  String isActive;
  String addUser;

  AssistantBubble({
    this.appEventId = 0,
    this.fkAppEventIdDescr = '',
    this.objectCode = '',
    this.bubbleSeq = 0,
    this.imageUrl = '',
    this.bubbleTextA = '',
    this.bubbleTextE = '',
    this.isActive = 'Y',
    this.addUser = '',
  });

  factory AssistantBubble.fromJson(Map<String, dynamic> json) =>
      AssistantBubble(
        appEventId: Functions.getValue(
          'int',
          json['app_event_id'],
          caller: 'app_event_id',
          initialValue: 0.toString(),
        ),
        fkAppEventIdDescr: Functions.getValue(
          'String',
          json['fk_app_event_id_descr'],
          caller: 'fk_app_event_id_descr',
          initialValue: ''.toString(),
        ),
        objectCode: Functions.getValue(
          'String',
          json['object_code'],
          caller: 'object_code',
          initialValue: ''.toString(),
        ),
        bubbleSeq: Functions.getValue(
          'int',
          json['bubble_seq'],
          caller: 'bubble_seq',
          initialValue: '0'.toString(),
        ),
        imageUrl: DioHelper.dio.options.baseUrl + json['image_url'],

        bubbleTextA: Functions.getValue(
          'String',
          json['bubble_text_a'],
          caller: 'bubble_text_a',
          initialValue: ''.toString(),
        ),
        bubbleTextE: Functions.getValue(
          'String',
          json['bubble_text_e'],
          caller: 'bubble_text_e',
          initialValue: ''.toString(),
        ),
        isActive: Functions.getValue(
          'String',
          json['is_active'],
          caller: 'is_active',
          initialValue: ''.toString(),
        ),
        addUser: Functions.getValue(
          'String',
          json['add_user'],
          caller: 'add_user',
          initialValue: ''.toString(),
        ),
      );

  Map<String, dynamic> toJson() => {
    'target_m_code': '812',
    'fk_m_code_descr': '812',
    'app_event_id': appEventId,
    'fk_app_event_id_descr': fkAppEventIdDescr,
    'object_code': objectCode,
    'bubble_seq': bubbleSeq,
    'image_url': imageUrl,
    'bubble_text_a': bubbleTextA,
    'bubble_text_e': bubbleTextE,
    'is_active': isActive,
    'add_user': addUser,
  };
}
