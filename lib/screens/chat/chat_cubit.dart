import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:educ_core/utils/text_styles.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:educ_core/data/models/chat_message.dart';
import 'package:educ_core/services/centrifugo/conf.dart' as conf;

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(InitChatState());
  final List<ChatMessage> msgs = [];
  StreamSubscription<ChatMessage>? _sub;
  bool connected = false;
  bool error = false;
  final bool _isDisposed = false;
  bool _isInitializing = false;
  bool _subscriptionAttempted = false;
  bool visible = false;
  String text = "";
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  void init(){
    debugPrint("========== ChatPage initState ==========");
    debugPrint("Current connected state: $connected");
    debugPrint("Is client initialized: ${conf.cli.isInitialized}");
    debugPrint("Is client connected: ${conf.cli.isConnected}");

    conf.initializeClient();
    _initializeChat();
  }
  Future<void> _initializeChat() async {
    debugPrint("========== _initializeChat started ==========");
    if (_isInitializing) {
      debugPrint("Already initializing, skipping...");
      return;
    }
    _isInitializing = true;

    try {
      msgs.clear();

      // Check current state
      debugPrint("Before init - isConnected: ${conf.cli.isConnected}");

      if (conf.cli.isConnected) {
        debugPrint("Client already connected, setting connected=true");
          connected = true;
          emit(ReloadState());
      }
      if (conf.cli.isError) {
        debugPrint("something went wrong");
          error = true;
          emit(ReloadState());
      }

      // Initialize
      debugPrint("Calling cli.init with user: ${conf.userId}");
      debugPrint(
        "Calling cli.init with user_token: ${conf.subscriptionJwtToken}",
      );
      conf.cli.init(
        conf.userJwtToken,
        conf.userId,
        int.tryParse(conf.userId) ?? Random().nextInt(100),
      );

      debugPrint("After init - isConnected: ${conf.cli.isConnected}");

      // Connect
      debugPrint("Calling cli.connect...");
      await conf.cli.connect(() {
        debugPrint("========== CONNECT CALLBACK TRIGGERED ==========");
        debugPrint("Callback - _isDisposed: $_isDisposed");

        if (!_isDisposed) {
          debugPrint("Setting connected = true in callback");
            connected = true;
            emit(ReloadState());
        } else {
          debugPrint("Cannot set state - disposed or not mounted");
          error = true;
          emit(ReloadState());
        }
      });

      debugPrint("After connect call - isConnected: ${conf.cli.isConnected}");

      // Subscribe
      debugPrint("Calling cli.subscribe to ${conf.channel}");
      if (!_subscriptionAttempted) {
        _subscriptionAttempted = true;
        debugPrint("Calling cli.subscribe to ${conf.channel}");
        await conf.cli.subscribe(conf.channel);
      } else {
        debugPrint("Subscribe already attempted, skipping");
      }

      debugPrint("Subscribe completed");

      // Set up message listener
      await _sub?.cancel();
      debugPrint("Setting up message listener");

      _sub = conf.cli.messages.listen(
            (msg) {
          debugPrint("Received message: ${msg.text}");
          if (!_isDisposed) {
              msgs.add(msg);
           emit(ReloadState());
          }
        },
        onError: (error) {
          debugPrint("Stream error: $error");
          this.error = true;
          emit(ReloadState());
        },
      );
      getChannelHistory();

      debugPrint("========== _initializeChat completed ==========");
      debugPrint("Final connected state: $connected");
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> getChannelHistory() async {
    try {
      debugPrint("Manually loading history...");
      await Future.delayed(Duration(milliseconds: 500));
      await Dio()
          .get(
        "https://islahsearchapi.hodhdsoft.com/api/FugoMessage/GetList",
        options: Options(
          headers: {"Authorization": "Bearer ${conf.subscriptionJwtToken}"},
        ),
      )
          .then((response) {
        if(response.data["data"] != null){
          final result = response.data["data"] as List<dynamic>;
          final List<ChatMessage> historyMessages  = result
              .map((e) => ChatMessage.fromJson(e as Map<String,dynamic>))
              .toList();
          if(historyMessages.isNotEmpty){
              // Add history messages (oldest first)
              msgs.addAll(historyMessages.reversed);
            emit(ReloadState());
            debugPrint("Loaded ${historyMessages.length} history messages");
          }
        }else{
          debugPrint("Error loading history");
            error = true;
        emit(ReloadState());
        }
      });
    } catch (e) {
      debugPrint("Error loading history: $e");
        error = true;
      emit(ReloadState());
    }
  }

  Future<void> addMsgToHistory(String msg) async {
    try {
      await Dio().post("https://islahsearchapi.hodhdsoft.com/api/FugoMessage/add",options: Options(headers: {"Authorization" : "Bearer ${conf.subscriptionJwtToken}"}),data: {
        "message" : msg
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeVisible(bool value) {
        visible = value;
        emit(ReloadState());
  }
  void onTextChange(String text) {
    if (visible) {
      changeVisible(false);
    }
      this.text = text;
   emit(ReloadState());
  }
  Future<void> sendMessage(BuildContext context, ChatMessage message) async {
    if (text.isEmpty != false) return;

    try {
      await conf.cli.sendMsg(message, conf.userName);
      await Future.delayed(Duration(milliseconds: 200));
      await addMsgToHistory(message.text);

      controller.clear();
      onTextChange.call("");
emit(ReloadState());
      // Keep focus on input field
      if(context.mounted) FocusScope.of(context).requestFocus(focusNode);

      // Scroll to bottom with smooth animation
      if (scrollController.hasClients == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients == true) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        });      }
    } catch (e) {
      // Show error feedback
      if(context.mounted) {  ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message',style: Omnes.w400.getStyle(fontSize: 14),),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );}
      emit(ErrorChatState());
    }
  }

}

abstract class ChatState {}

class InitChatState extends ChatState {}

class LoadingChatState extends ChatState {}

class SuccessChatState extends ChatState {}

class ErrorChatState extends ChatState {}
class ReloadState extends ChatState {}

