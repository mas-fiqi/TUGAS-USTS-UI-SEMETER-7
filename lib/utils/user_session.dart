class UserSession {
  static final UserSession _instance = UserSession._internal();
  
  factory UserSession() {
    return _instance;
  }
  
  UserSession._internal();

  String? _nim;
  String? _name;
  String? _classId;
  String? _className;
  bool _isLoggedIn = false;

  // Getters
  String get nim => _nim ?? '';
  String get name => _name ?? 'Siswa';
  String get classId => _classId ?? '';
  String get className => _className ?? '';
  bool get isLoggedIn => _isLoggedIn;

  // Setters
  void saveSession({
    required String nim,
    required String name,
    required String classId,
    required String className,
  }) {
    _nim = nim;
    _name = name;
    _classId = classId;
    _className = className;
    _isLoggedIn = true;
  }

  void clearSession() {
    _nim = null;
    _name = null;
    _classId = null;
    _className = null;
    _isLoggedIn = false;
  }
}
