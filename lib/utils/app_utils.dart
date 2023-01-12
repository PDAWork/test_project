import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdFromToken(String token) {
    try {
      final key = Platform.environment["SECRET_KEY"] ?? 'SECRET_KEY';
      final jwtCLaim = verifyJwtHS256Signature(token, key);
      return int.parse(jwtCLaim["id"].toString());
    } catch (e) {
      rethrow;
    }
  }

  static int getIdFromHeader(String header) {
    try {
      final token = const AuthorizationBearerParser().parse(header);
      final id = getIdFromToken(token ?? "");
      return id;
    } catch (e) {
      rethrow;
    }
  }
}
