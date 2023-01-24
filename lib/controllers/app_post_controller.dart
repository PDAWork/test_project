import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:project_lesson/model/author.dart';
import 'package:project_lesson/model/model_response.dart';
import 'package:project_lesson/model/post.dart';
import 'package:project_lesson/utils/app_response.dart';
import 'package:project_lesson/utils/app_utils.dart';

class AppPostController extends ResourceController {
  AppPostController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getPosts(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      // Получаем id пользователя из header
      final id = AppUtils.getIdFromHeader(header);

      final qCreatePost = Query<Post>(managedContext)
        ..where((x) => x.author!.id).equalTo(id);

      final List<Post> list = await qCreatePost.fetch();

      if (list.isEmpty)
        return Response.notFound(
            body: ModelResponse(data: [], message: "Нет ни одного поста"));

      return Response.ok(list);
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.post()
  Future<Response> createPost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Post post) async {
    try {
      // Получаем id пользователя из header
      final id = AppUtils.getIdFromHeader(header);
      // запрашиваем из базы данных автора по его id
      final author = await managedContext.fetchObjectWithID<Author>(id);

      // Если такого автора нет то мы создаем данного автора по его id
      if (author == null) {
        // Создаем автора с id пользователя
        final qCreateAuthor = Query<Author>(managedContext)..values.id = id;
        await qCreateAuthor.insert();
      }
      // Создаем запрос для создания поста передаем id пользователя контент берем из body
      final qCreatePost = Query<Post>(managedContext)
        ..values.author!.id = id
        ..values.content = post.content;

      await qCreatePost.insert();

      return AppResponse.ok(message: 'Успешное создание поста');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Ошибка создания поста');
    }
  }

  @Operation.put('id')
  Future<Response> updatePost(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() Post bodyPost) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }

      final qUpdatePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.content = bodyPost.content;

      await qUpdatePost.update();

      return AppResponse.ok(message: 'Пост успешно обновлен');

    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete("id")
  Future<Response> deletePost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      final qDeletePost = Query<Post>(managedContext)
        ..where((x) => x.id).equalTo(id);
      await qDeletePost.delete();
      return AppResponse.ok(message: "Успешное удаление поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка удаления поста");
    }
  }

  @Operation.get("id")
  Future<Response> getPost(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.path("id") int id,
  ) async {
    try {
      final currentAuthorId = AppUtils.getIdFromHeader(header);
      final post = await managedContext.fetchObjectWithID<Post>(id);
      if (post == null) {
        return AppResponse.ok(message: "Пост не найден");
      }
      if (post.author?.id != currentAuthorId) {
        return AppResponse.ok(message: "Нет доступа к посту");
      }
      post.backing.removeProperty("author");
      return AppResponse.ok(
          body: post.backing.contents, message: "Успешное создание поста");
    } catch (error) {
      return AppResponse.serverError(error, message: "Ошибка создания поста");
    }
  }
}

//@Operation.get()
// Future<Response> getPost({@Bind.query("limit") int limit = 1}) async {

//   return Response.ok(limit);
// }

// @Operation.get('id')
// Future<Response> getFindPost(
//     @Bind.path('id') int id, @Bind.query("limit") int limit) async {
//   return Response.ok("$limit  id : $id");
// }
