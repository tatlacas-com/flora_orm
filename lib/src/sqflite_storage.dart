import 'package:tatlacas_orm/src/base_storage.dart';
import '../tatlacas_orm.dart';

import 'sqflite_db_context.dart';

class SqfliteStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, SqfliteDbContext> {
  const SqfliteStorage(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
