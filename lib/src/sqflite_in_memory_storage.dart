import '../sql.dart';

import 'base_storage.dart';
import 'sqflite_in_memory_db_context.dart';

class SqfliteInMemoryStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, SqfliteInMemoryDbContext> {
  const SqfliteInMemoryStorage(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
