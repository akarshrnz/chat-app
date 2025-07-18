// lib/features/home/presentation/bloc/home_bloc.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatapp/features/home/domain/usecases/home_usecases.dart';
import 'package:chatapp/features/home/presentation/bloc/home_event.dart';
import 'package:chatapp/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseAuth _auth;
  final HomeUseCases useCases;

  StreamSubscription? _mirrorSubscription;
  StreamSubscription? _scrollSubscription;
  StreamSubscription? _messagesSubscription;

  String? _mirroredToUserId;

  HomeBloc({required this.useCases, FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(HomeInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadUsers>(_onLoadUsers);
    on<SendMessage>(_onSendMessage);
    on<GetMessages>(_onGetMessages);
    on<MirrorUser>(_onMirrorUser);
    on<CancelMirror>(_onCancelMirror);
    on<SendScrollOffset>(_onSendScrollOffset);
    on<ListenToScroll>(_onListenToScroll);
    on<ListenToMirror>(_onListenToMirror);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<HomeState> emit) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(HomeError("User not logged in"));
      return;
    }

    await emit.forEach(
      useCases.getProducts(),
      onData: (products) => ProductsLoaded(products, user.uid),
      onError: (_, __) => HomeError("Failed to load products"),
    );
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<HomeState> emit) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(HomeError("User not logged in"));
      return;
    }

    await emit.forEach(
      useCases.getUsers(),
      onData: (users) =>
          UsersLoaded(users.where((u) => u.uid != user.uid).toList(), user.uid),
      onError: (_, __) => HomeError("Failed to load users"),
    );
  }

  Future<void> _onMirrorUser(MirrorUser event, Emitter<HomeState> emit) async {
    try {
      _mirroredToUserId = event.toUserId;
      await useCases.mirrorUser(event.fromUserId, event.toUserId);
      emit(MirrorStatusChanged(_mirroredToUserId));
    } catch (e) {
      emit(HomeError("Failed to start mirroring"));
    }
  }

  Future<void> _onCancelMirror(CancelMirror event, Emitter<HomeState> emit) async {
    try {
      await useCases.cancelMirror(event.userId);
      _mirroredToUserId = null;
      emit(MirrorStatusChanged(null));
    } catch (e) {
      emit(HomeError("Failed to cancel mirroring"));
    }
  }

  Future<void> _onSendScrollOffset(SendScrollOffset event, Emitter<HomeState> emit) async {
    if (_mirroredToUserId == null) return;

    try {
      await useCases.sendScrollOffset(event.fromUserId, event.offset);
    } catch (e) {
      emit(HomeError("Failed to send scroll offset"));
    }
  }

  Future<void> _onListenToScroll(ListenToScroll event, Emitter<HomeState> emit) async {
    _scrollSubscription?.cancel();
    _scrollSubscription = useCases.listenToScroll(event.userId).listen(
      (offset) => emit(ScrollOffsetUpdated(offset)),
      onError: (e) => emit(HomeError("Scroll listener error: ${e.toString()}")),
    );
  }

  Future<void> _onListenToMirror(ListenToMirror event, Emitter<HomeState> emit) async {
    _mirrorSubscription?.cancel();
    _mirrorSubscription = useCases.listenToMirror(event.userId).listen(
      (toUserId) {
        _mirroredToUserId = toUserId;
        emit(MirrorStatusChanged(toUserId));
      },
      onError: (e) => emit(HomeError("Mirror listener error: ${e.toString()}")),
    );
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<HomeState> emit) async {
    try {
      await useCases.sendMessage(event.fromUserId, event.toUserId, event.message,event.id);
    } catch (e) {
      emit(HomeError("Failed to send message"));
    }
  }

  Future<void> _onGetMessages(GetMessages event, Emitter<HomeState> emit) async {
    _messagesSubscription?.cancel();
    _messagesSubscription = useCases.getMessages(event.fromUserId, event.toUserId).listen(
      (messages) => emit(MessagesLoaded(messages)),
      onError: (e) => emit(HomeError("Failed to load messages")),
    );
  }

  @override
  Future<void> close() {
    _mirrorSubscription?.cancel();
    _scrollSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
