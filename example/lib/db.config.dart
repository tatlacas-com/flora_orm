import 'package:example/user.entity.dart';
import 'package:flora_orm/flora_orm.dart';

abstract class DbConfig {
  static const int dbVersion = 1;
  static const String dbName = 'test_flora_orm.db';
  static List<Entity> get tables => <Entity>[
        const UserEntity(),
      ];
}
