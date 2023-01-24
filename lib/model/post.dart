import 'package:conduit/conduit.dart';
import 'package:project_lesson/model/author.dart';

class Post extends ManagedObject<_Post> implements _Post {}

class _Post {

  @primaryKey
  int? id; // Номер поста

  String? content; // Содержание поста

  //Анотация для связи (#переменная с которой хотим сделать связь; обязательная ли это связь; что делать при удаление записи)
  @Relate(#postList, isRequired: true, onDelete: DeleteRule.cascade)
  Author? author; // Создаем связь с моделью автор
}
