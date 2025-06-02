import 'dart:convert';
import 'package:commun/commun.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CmlUser extends Serializable {
  /// Pseudo de l'utilisateur
  final String? userName;

  /// Id de l'utilisateur
  final int? id;

  /// Url de la photo de profil
  String? urlProfilPicture;

  CmlUser({
    this.userName,
    this.id,
    this.urlProfilPicture,
  });

  static final _secureStorage = const FlutterSecureStorage();

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': userName,
      'urlProfilPicture': urlProfilPicture,
    };
  }

  static CmlUser fromMap(Map<String, dynamic> map) {
    return CmlUser(
      id: map['id'],
      userName: map['name'],
      urlProfilPicture: map['urlProfilPicture'],
    );
  }

  static Future<CmlUser?> get() async {
    final userData = await _secureStorage.read(key: 'secure_user');
    if (userData != null) {
      return CmlUser.fromMap(jsonDecode(userData));
    }

    return null;
  }

  static Future<bool> save(CmlUser user) async {
    try {
      final userJson = jsonEncode(user.toMap());
      await _secureStorage.write(key: 'secure_user', value: userJson);

      return true;
    } catch (e) {
      return false;
    }
  }
}
