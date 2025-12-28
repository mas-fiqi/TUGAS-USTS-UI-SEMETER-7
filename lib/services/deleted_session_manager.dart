class DeletedSessionManager {
  static final DeletedSessionManager _instance = DeletedSessionManager._internal();
  factory DeletedSessionManager() => _instance;
  DeletedSessionManager._internal();

  final Set<String> _deletedIds = {};

  void add(dynamic id) {
    if (id != null) {
      _deletedIds.add(id.toString());
      print("DeletedSessionManager: Added $_deletedIds");
    }
  }

  bool contains(dynamic id) {
    if (id == null) return false;
    return _deletedIds.contains(id.toString());
  }
}
