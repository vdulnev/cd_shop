import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  final String id;
  final String userId;
  final String name;
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        street,
        city,
        state,
        zipCode,
        country,
      ];
}
