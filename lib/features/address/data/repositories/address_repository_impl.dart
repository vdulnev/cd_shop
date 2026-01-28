// ignore_for_file: close_sinks
import 'dart:async';

import 'package:cd_shop/core/database/daos/address_dao.dart';
import 'package:cd_shop/core/database/entities/address_entity.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this.addressDao);

  final AddressDao addressDao;
  final _eventController = StreamController<RepositoryEvent>.broadcast();

  @override
  Stream<RepositoryEvent> eventStream() => _eventController.stream;

  @override
  Stream<List<Address>> watchAddresses(String userId) {
    return addressDao
        .watchAddressesByUserId(userId)
        .map((entities) => entities.map((e) => e.toDomain()).toList());
  }

  @override
  Future<Address> addAddress(Address address) async {
    final entity = AddressEntity.fromDomain(address);
    await addressDao.insertAddress(entity);
    _eventController.add(
      SuccessEvent(message: '${address.name} address added'),
    );
    return address;
  }

  @override
  Future<Address> updateAddress(Address address) async {
    final entity = AddressEntity.fromDomain(address);
    await addressDao.updateAddress(entity);
    _eventController.add(
      const SuccessEvent(message: 'Address updated'),
    );
    return address;
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await addressDao.deleteAddress(addressId);
    _eventController.add(
      const SuccessEvent(message: 'Address deleted'),
    );
  }
}
