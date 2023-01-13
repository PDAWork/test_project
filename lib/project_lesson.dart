import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:project_lesson/contollers/app_auth_contoller.dart';
import 'package:project_lesson/contollers/app_token_contoller.dart';
import 'package:project_lesson/contollers/app_user_contoller.dart';

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
    final username = Platform.environment['DB_USERNAME'];
    final password = Platform.environment['DB_PASSWORD'];
    final host = Platform.environment['DB_HOST'];
    final port = int.parse(Platform.environment['DB_PORT'] ?? '0');
    final databaseName = Platform.environment['DB_NAME'];
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
