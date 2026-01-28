/// Repository-level events for UI-level notifications (success/error messages)
sealed class RepositoryEvent {
  const RepositoryEvent({required this.message});
  final String message;
}

class SuccessEvent extends RepositoryEvent {
  const SuccessEvent({required super.message});
}

class ErrorEvent extends RepositoryEvent {
  const ErrorEvent({required super.message});
}
