import 'dart:async';
import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:project_lesson/controllers/app_auth_controller.dart';
import 'package:project_lesson/controllers/app_post_controller.dart';
import 'package:project_lesson/controllers/app_token_controller.dart';
import 'package:project_lesson/controllers/app_user_controller.dart';
import 'model/author.dart';
import 'model/post.dart';

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
      () => AppAuthController(managedContext),
    )
    ..route('user')
        .link(AppTokenController.new)!
        .link(() => AppUserController(managedContext))
    ..route('post/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppPostController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment['DB_USERNAME'] ?? 'admin';
    final password = Platform.environment['DB_PASSWORD'] ?? 'root';
    final host = Platform.environment['DB_HOST'] ?? '127.0.0.1';
    final port = int.parse(Platform.environment['DB_PORT'] ?? '6101');
    final databaseName = Platform.environment['DB_NAME'] ?? 'postgres';
    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
