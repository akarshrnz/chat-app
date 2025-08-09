import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email, password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email, password;
  final String phone, name;

  const RegisterRequested({required this.email, required this.password, required this.phone, required this.name});

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  @override
  List<Object> get props => [];
}
