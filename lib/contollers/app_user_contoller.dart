import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:test_project/model/user.dart';
import 'package:test_project/utils/app_response.dart';
import 'package:test_project/utils/app_utils.dart';

class AppUserConttolelr extends ResourceController {
  AppUserConttolelr(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      // Получаем id пользователя
      // Была создана новая функция ее нужно реализоваться для просмотра функции нажмите на картинку
      final id = AppUtils.getIdFromHeader(header);
      // Получаем данные пользователя по его id
      final user = await managedContext.fetchObjectWithID<User>(id);
      // Удаляем не нужные параметры для красивого вывода данных пользователя
      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
          message: 'Успешное получение профиля', body: user.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка получения профиля');
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() User user,
  ) async {
    try {
      // Получаем id пользователя
      // Была создана новая функция ее нужно реализоваться для просмотра функции нажмите на картинку
      final id = AppUtils.getIdFromHeader(header);
      // Получаем данные пользователя по его id
      final fUser = await managedContext.fetchObjectWithID<User>(id);
      // Запрос для обновления данных пользователя
      final qUpdateUser = Query<User>(managedContext)
        ..where((element) => element.id)
            .equalTo(id) // Поиск пользователя осущетсвляется по id
        ..values.userName = user.userName ?? fUser!.userName
        ..values.userName = user.email ?? fUser!.email;
      // Вызов функция для обновления данных пользователя
      await qUpdateUser.updateOne();
      // Получаем обновленного пользователя
      final findUser = await managedContext.fetchObjectWithID<User>(id);
      // Удаляем не нужные параметры для красивого вывода данных пользователя
      findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
        message: 'Успешное обновление данных',
        body: findUser.backing.contents,
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления данных');
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() String newPassword,
    @Bind.body() String oldPassword,
  ) async {
    try {
      // Получаем id пользователя
      // Была создана новая функция ее нужно реализоваться для просмотра функции нажмите на картинку
      final id = AppUtils.getIdFromHeader(header);
      // Получаем данные пользователя по его id
      // Поиск пользователя по имени в базе данных
      final qFindUser = Query<User>(managedContext)
        ..where((element) => element.id).equalTo(id)
        ..returningProperties(
          (element) => [
            element.salt,
            element.hashPassword,
          ],
        );

      // Получаем данные только одного пользователя
      final fUser = await qFindUser.fetchOne();

      // Создаем hash старого пароля
      final oldHashPassword =
          generatePasswordHash(oldPassword, fUser!.salt ?? "");

      // Проваряем старый пароль с паролем в базе данных
      if (oldHashPassword != fUser.hashPassword) {
        return AppResponse.badrequest(
          message: 'Неверный старый пароль',
        );
      }

      // Создаем hash нового пароля
      final newHashPassword =
          generatePasswordHash(newPassword, fUser.salt ?? "");

      // Создаем запрос на обнолвения пароля
      final qUpdateUser = Query<User>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.hashPassword = newHashPassword;

      // Обновляем пароль
      await qUpdateUser.fetchOne();

      return AppResponse.ok(body: 'Пароль успешно обновлен');
    } catch (e) {
      return AppResponse.serverError(e, message: 'Ошибка обновления пароля');
    }
  }
}
