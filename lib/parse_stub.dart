// lib/parse_stub.dart
// Simple in-memory stub to emulate the small Parse API your app uses.
// Good for local development and offline UI testing.

import 'dart:async';
import 'dart:collection';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

class Parse {
  // Singleton-ish behavior by returning a new instance is fine for stub.
  Future<void> init() async => Future<void>.value();
  static Future<void> initialize(String appId, String serverUrl,
          {String? clientKey, bool debug = false}) =>
      Future<void>.value();
}

class ParseResponse {
  final bool success;
  final dynamic result;
  final List<dynamic>? results;
  final ParseError? error;

  ParseResponse({required this.success, this.result, this.results, this.error});
}

class ParseError {
  final String message;
  ParseError(this.message);
  @override
  String toString() => message;
}

/// -------------------- Users --------------------
class _UserRecord {
  String objectId;
  String username;
  String password;
  String? sessionToken;
  _UserRecord(
      {required this.objectId, required this.username, required this.password});
}

class ParseUser {
  String? objectId;
  String? username;
  String? password;
  String? sessionToken;

  ParseUser({this.objectId, this.username, this.password, this.sessionToken});

  // mimic convenience constructors used by some code
  static ParseUser createUser(String username, String password, String email) {
    return ParseUser(username: username, password: password);
  }

  // in-memory "database" for users
  static final Map<String, _UserRecord> _usersById = {};
  static final Map<String, _UserRecord> _usersByUsername = {};
  static _UserRecord? _currentUser;

  // signUp - create new user
  Future<ParseResponse> signUp() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final uname = username ?? '';
    final pwd = password ?? '';
    if (uname.isEmpty || pwd.isEmpty) {
      return ParseResponse(
          success: false, error: ParseError('username/password required'));
    }
    if (_usersByUsername.containsKey(uname)) {
      return ParseResponse(
          success: false, error: ParseError('user already exists'));
    }
    final id = _uuid.v4();
    final rec = _UserRecord(objectId: id, username: uname, password: pwd)
      ..sessionToken = _uuid.v4();
    _usersById[id] = rec;
    _usersByUsername[uname] = rec;
    _currentUser = rec;
    final pu = ParseUser(
        objectId: rec.objectId, username: rec.username, password: null)
      ..sessionToken = rec.sessionToken;
    return ParseResponse(success: true, result: pu);
  }

  // login
  Future<ParseResponse> login() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final uname = username ?? '';
    final pwd = password ?? '';
    final rec = _usersByUsername[uname];
    if (rec == null || rec.password != pwd) {
      return ParseResponse(success: false, error: ParseError('Invalid creds'));
    }
    rec.sessionToken = _uuid.v4();
    _currentUser = rec;
    final pu = ParseUser(objectId: rec.objectId, username: rec.username)
      ..sessionToken = rec.sessionToken;
    return ParseResponse(success: true, result: pu);
  }

  Future<ParseResponse> logout({bool deleteLocalSession = false}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_currentUser != null) {
      if (deleteLocalSession) _currentUser!.sessionToken = null;
      _currentUser = null;
      return ParseResponse(success: true, result: true);
    }
    return ParseResponse(success: false, error: ParseError('No current user'));
  }

  static Future<ParseResponse> currentUser() async {
    await Future.delayed(const Duration(milliseconds: 50));
    final rec = _currentUser;
    if (rec == null) return ParseResponse(success: true, result: null);
    final pu = ParseUser(objectId: rec.objectId, username: rec.username)
      ..sessionToken = rec.sessionToken;
    return ParseResponse(success: true, result: pu);
  }
}

/// -------------------- Objects & Query --------------------
class ParseObject {
  final String className;
  String? objectId;
  final Map<String, dynamic> _data = {};

  ParseObject(this.className);

  void set(String key, dynamic value) => _data[key] = value;
  dynamic get(String key) => _data[key];

  // in-memory store: className -> ordered list of ParseObject-like maps
  static final Map<String, List<Map<String, dynamic>>> _store = {};

  Future<ParseResponse> save() async {
    await Future.delayed(const Duration(milliseconds: 160));
    final store = _store.putIfAbsent(className, () => []);
    if (objectId == null) {
      objectId = _uuid.v4();
      final map = Map<String, dynamic>.from(_data);
      map['objectId'] = objectId;
      // ensure createdAt if present is a string or add timestamp
      map.putIfAbsent('createdAt', () => DateTime.now().toIso8601String());
      store.insert(0, map); // newest first
      final po = ParseObject(className)
        ..objectId = objectId
        .._data.addAll(map);
      return ParseResponse(success: true, result: po);
    } else {
      // update existing
      final idx = store.indexWhere((m) => m['objectId'] == objectId);
      if (idx == -1) {
        return ParseResponse(
            success: false, error: ParseError('object not found'));
      }
      store[idx].addAll(_data);
      store[idx]['updatedAt'] = DateTime.now().toIso8601String();
      final po = ParseObject(className)
        ..objectId = store[idx]['objectId']
        .._data.addAll(store[idx]);
      return ParseResponse(success: true, result: po);
    }
  }

  Future<ParseResponse> delete() async {
    await Future.delayed(const Duration(milliseconds: 120));
    final store = _store[className];
    if (store == null) return ParseResponse(success: false, error: ParseError('no class'));
    final idx = store.indexWhere((m) => m['objectId'] == objectId);
    if (idx == -1) return ParseResponse(success: false, error: ParseError('not found'));
    store.removeAt(idx);
    return ParseResponse(success: true, result: true);
  }
}

class QueryBuilder<T> {
  final ParseObject _template;
  final Map<String, dynamic> _where = {};
  String? _orderField;
  bool _orderDesc = false;

  QueryBuilder(ParseObject template) : _template = template;

  QueryBuilder<T> whereEqualTo(String key, dynamic value) {
    _where[key] = value;
    return this;
  }

  QueryBuilder<T> orderByDescending(String field) {
    _orderField = field;
    _orderDesc = true;
    return this;
  }

  Future<ParseResponse> query() async {
    await Future.delayed(const Duration(milliseconds: 160));
    final className = _template.className;
    final list = ParseObject._store[className] ?? <Map<String, dynamic>>[];
    Iterable<Map<String, dynamic>> results = list;
    // apply where filters
    _where.forEach((k, v) {
      results = results.where((m) => m[k] == v);
    });
    // ordering
    if (_orderField != null) {
      final f = _orderField!;
      results = results.toList()
        ..sort((a, b) {
          final av = a[f];
          final bv = b[f];
          if (av == null && bv == null) return 0;
          if (av == null) return 1;
          if (bv == null) return -1;
          // try ISO date string compare, else fallback to string compare
          if (av is String && bv is String) return bv.compareTo(av);
          return 0;
        });
    }
    // map results back to ParseObject instances
    final parsed = results.map((m) {
      final po = ParseObject(className)..objectId = m['objectId'];
      po._data.addAll(m);
      return po;
    }).toList();
    return ParseResponse(success: true, results: parsed);
  }
}
