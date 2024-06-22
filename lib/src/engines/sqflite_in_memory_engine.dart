import '../../flora_orm.dart';

import 'base_orm_engine.dart';
import '../contexts/sqflite_in_memory_db_context.dart';

class SqfliteInMemoryEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends BaseOrmEngine<TEntity, TMeta, SqfliteInMemoryDbContext<TEntity>> {
  const SqfliteInMemoryEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
