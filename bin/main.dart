import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:test_project/project_lesson.dart';

void main() async {
  // Указываем порт на котором у нас будет запущен сервис в данном случае API
  final port = int.parse(Platform.environment["PORT"] ?? '8080');
  // Иницилизируем переменную и назначаем порт на котором будет развернут наш сервис
  final service = Application<AppService>()..options.port = port;
  // Запускаем наш сервис. Создаем логирование и указываем что будет запущено 3 изолята
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
