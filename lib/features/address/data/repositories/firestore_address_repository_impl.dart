import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talker/talker.dart';
import 'package:uuid/uuid.dart';

import 'package:cd_shop/core/models/disposable.dart';
import 'package:cd_shop/core/models/event_emitter.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/features/address/domain/entities/address.dart';
import 'package:cd_shop/features/address/domain/repositories/address_repository.dart';
import 'package:cd_shop/injection_container.dart';

/// Firestore implementation of [AddressRepository].
///
/// Stores addresses in Firestore subcollections under each user.
/// Structure: addresses/{userId}/items/{addressId}
class FirestoreAddressRepositoryImpl
  with EventEmitterMixin
  implements AddressRepository, Disposable {
  FirestoreAddressRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();
  Talker get _log => sl<Talker>();

  CollectionReference<Map<String, dynamic>> _addressesRef(String userId) =>
      _firestore.collection('addresses').doc(userId).collection('items');

  Address _documentToAddress(
      DocumentSnapshot<Map<String, dynamic>> doc, String userId) {
    final data = doc.data()!;
    return Address(
      id: doc.id,
      userId: userId,
      name: data['name'] as String? ?? '',
      street: data['street'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      zipCode: data['zipCode'] as String? ?? '',
      country: data['country'] as String? ?? '',
    );
  }

  Map<String, dynamic> _addressToMap(Address address) {
    return {
      'name': address.name,
      'street': address.street,
      'city': address.city,
      'state': address.state,
      'zipCode': address.zipCode,
      'country': address.country,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  Stream<List<Address>> watchAddresses(String userId) {
    _log.info('Watching addresses for user $userId');
    return _addressesRef(userId).snapshots().map((snapshot) {
      final addresses = snapshot.docs
          .map((doc) => _documentToAddress(doc, userId))
          .toList();
      _log.info('Received ${addresses.length} addresses for user $userId');
      return addresses;
    });
  }

  @override
  Future<Address> addAddress(Address address) async {
    _log.info('Adding address "${address.name}" for user ${address.userId}');
    try {
      final addressId = address.id.isNotEmpty ? address.id : _uuid.v4();
      final addressWithId = Address(
        id: addressId,
        userId: address.userId,
        name: address.name,
        street: address.street,
        city: address.city,
        state: address.state,
        zipCode: address.zipCode,
        country: address.country,
      );

      await _addressesRef(address.userId).doc(addressId).set({
        ..._addressToMap(addressWithId),
        'createdAt': FieldValue.serverTimestamp(),
      });

      emitEvent(SuccessEvent(message: '${address.name} address added'));
      _log.info('Address added: $addressId');

      return addressWithId;
    } catch (e) {
      _log.error('Failed to add address', e);
      emitEvent(const ErrorEvent(message: 'Failed to add address'));
      rethrow;
    }
  }

  @override
  Future<Address> updateAddress(Address address) async {
    _log.info('Updating address ${address.id}');
    try {
      await _addressesRef(address.userId).doc(address.id).update(
            _addressToMap(address),
          );

      emitEvent(const SuccessEvent(message: 'Address updated'));
      _log.info('Address updated: ${address.id}');

      return address;
    } catch (e) {
      _log.error('Failed to update address ${address.id}', e);
      emitEvent(const ErrorEvent(message: 'Failed to update address'));
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    _log.info('Deleting address $addressId');
    try {
      // We need to find the address first to get the userId
      // This is a limitation of the current interface design
      // In practice, you'd pass userId as well or store it differently

      // Search across all users' addresses (not ideal but works for now)
      final usersSnapshot = await _firestore.collection('addresses').get();

      for (final userDoc in usersSnapshot.docs) {
        final addressDoc = await _firestore
            .collection('addresses')
            .doc(userDoc.id)
            .collection('items')
            .doc(addressId)
            .get();

        if (addressDoc.exists) {
          await addressDoc.reference.delete();
          emitEvent(const SuccessEvent(message: 'Address deleted'));
          _log.info('Address deleted: $addressId');
          return;
        }
      }

      _log.warning('Address not found: $addressId');
      emitEvent(const ErrorEvent(message: 'Address not found'));
    } catch (e) {
      _log.error('Failed to delete address $addressId', e);
      emitEvent(const ErrorEvent(message: 'Failed to delete address'));
      rethrow;
    }
  }

  @override
  void dispose() {
    disposeEventEmitter();
  }
}
