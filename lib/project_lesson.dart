import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:test_project/contollers/app_auth_contoller.dart';
import 'package:test_project/contollers/app_token_contoller.dart';
import 'package:test_project/contollers/app_user_contoller.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('token/[:refresh]').link(
      () => AppAuthContoler(managedContext),
    )
    ..route('user')
        .link(AppTokenContoller.new)!
        .link(() => AppUserConttolelr(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'postgres';
    final password = Platform.environment['DB_PASSWORD'] ?? 'lecnoe2002';
    final host = Platform.environment['DB_USERNAME'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_USERNAME'] ?? '5432');
    final databaseName = Platform.environment['DB_NAME'] ?? 'postgres';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
