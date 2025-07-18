import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases useCases;

  AuthBloc(this.useCases) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await useCases.login(event.email, event.password);
        emit(user != null ? Authenticated(user) : const AuthError("Login failed"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await useCases.register(event.email, event.password);
        emit(user != null ? Authenticated(user) : const AuthError("Registration failed"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await useCases.logout();
      emit(AuthInitial());
    });
  }
}
