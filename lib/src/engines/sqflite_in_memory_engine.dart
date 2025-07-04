import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/flora_orm.dart';

import 'package:flora_orm/src/engines/base_orm_engine.dart';

class SqfliteInMemoryEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends BaseOrmEngine<TEntity, TMeta, SqfliteInMemoryDbContext<TEntity>> {
  const SqfliteInMemoryEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true,});
}
