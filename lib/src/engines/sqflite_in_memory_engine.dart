import '../../tatlacas_orm.dart';

import 'base_engine.dart';
import '../contexts/sqflite_in_memory_db_context.dart';

class SqfliteInMemoryEngine<TEntity extends IEntity>
    extends BaseEngine<TEntity, SqfliteInMemoryDbContext> {
  const SqfliteInMemoryEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
