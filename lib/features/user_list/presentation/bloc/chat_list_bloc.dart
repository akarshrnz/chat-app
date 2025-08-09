import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_all_users_usecase.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetAllUsersUseCase getAllUsersUseCase;

  ChatListBloc(this.getAllUsersUseCase) : super(ChatListInitial()) {
    on<LoadUsersEvent>((event, emit) {
      emit(ChatListLoading());

      getAllUsersUseCase(event.currentUserId).listen(
        (users) => add(UsersUpdatedEvent(users)),
        onError: (e) => emit(ChatListError("Failed to load users")),
      );
    });

    on<UsersUpdatedEvent>((event, emit) {
      emit(ChatListLoaded(event.users));
    });
  }
}
