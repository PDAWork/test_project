import 'package:conduit/conduit.dart';
import 'package:project_lesson/model/post.dart';

class Author extends ManagedObject<_Author> implements _Author {}

class _Author {
  @primaryKey
  int? id;

  // При помощи класса ManagedSet указывам что переменная будет иметь Relation
  ManagedSet<Post>? postList;
}
