/// Repository-level events for UI-level notifications (success/error messages)
abstract class RepositoryEvent {
  const RepositoryEvent();
}

class AuthSuccessEvent extends RepositoryEvent {
  const AuthSuccessEvent({required this.message});
  final String message;
}

class AuthErrorEvent extends RepositoryEvent {
  const AuthErrorEvent({required this.message});
  final String message;
}

class CartSuccessEvent extends RepositoryEvent {
  const CartSuccessEvent({required this.message});
  final String message;
}

class CartErrorEvent extends RepositoryEvent {
  const CartErrorEvent({required this.message});
  final String message;
}

class ProductSuccessEvent extends RepositoryEvent {
  const ProductSuccessEvent({required this.message});
  final String message;
}

class ProductErrorEvent extends RepositoryEvent {
  const ProductErrorEvent({required this.message});
  final String message;
}

class AddressSuccessEvent extends RepositoryEvent {
  const AddressSuccessEvent({required this.message});
  final String message;
}

class AddressErrorEvent extends RepositoryEvent {
  const AddressErrorEvent({required this.message});
  final String message;
}
