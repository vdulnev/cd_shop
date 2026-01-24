import 'package:floor/floor.dart';

import 'package:cd_shop/features/address/domain/entities/address.dart';

/// Database entity for user addresses
@Entity(tableName: 'addresses')
class AddressEntity {
  AddressEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  /// Convert from domain entity to database entity
  factory AddressEntity.fromDomain(Address address) {
    return AddressEntity(
      id: address.id,
      userId: address.userId,
      name: address.name,
      street: address.street,
      city: address.city,
      state: address.state,
      zipCode: address.zipCode,
      country: address.country,
    );
  }

  @primaryKey
  final String id;

  @ColumnInfo(name: 'user_id')
  final String userId;

  final String name;
  final String street;
  final String city;
  final String state;

  @ColumnInfo(name: 'zip_code')
  final String zipCode;

  final String country;

  /// Convert to domain entity
  Address toDomain() {
    return Address(
      id: id,
      userId: userId,
      name: name,
      street: street,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );
  }
}
