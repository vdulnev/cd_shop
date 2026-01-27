import 'package:equatable/equatable.dart';

sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted({
    required this.email,
    required this.password,
    required this.name,
  });

  final String email;
  final String password;
  final String name;

  @override
  List<Object?> get props => [email, password, name];
}
