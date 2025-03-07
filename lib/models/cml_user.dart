import 'dart:convert';
import 'dart:typed_data';
import 'package:commun/commun.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CmlUser implements Serializable {
  ///Pseudo de l'utilisateur
  final String? userName;

  ///Id de l'utilisateur
  final int? id;

  ///Url de la photo de profil
  String? urlProfilPicture;

  ///Photo de profil
  Uint8List? profilPicture;

  CmlUser({this.userName, this.id, this.urlProfilPicture, this.profilPicture});

  static final _secureStorage = const FlutterSecureStorage();

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': userName, 'urlProfilPicture': urlProfilPicture, 'profilPicture': profilPicture != null ? base64Encode(profilPicture!) : null};
  }

  @override
  Map<String, dynamic> toDatabaseMap() => toMap();

  static CmlUser fromMap(Map<String, dynamic> map) {
    return CmlUser(id: map['id'], userName: map['name'], urlProfilPicture: map['urlProfilPicture'], profilPicture: map['profilPicture'] != null ? base64Decode(map['profilPicture']) : null);
  }

  static Future<CmlUser?> get() async {
    final userData = await _secureStorage.read(key: 'secure_user');
    if (userData != null) {
      return CmlUser.fromMap(jsonDecode(userData));
    }
    return null;
  }

  static Future<bool> saveSecurely(CmlUser user) async {
    try {
      final userJson = jsonEncode(user.toMap());
      await _secureStorage.write(key: 'secure_user', value: userJson);
      return true;
    } catch (e) {
      return false;
    }
  }
}
