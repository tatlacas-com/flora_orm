import '../../flora_orm.dart';

import 'base_orm_engine.dart';
import '../contexts/sqflite_common_db_context.dart';

class SqfliteCommonEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends BaseOrmEngine<TEntity, TMeta, SqfliteCommonDbContext<TEntity>> {
  const SqfliteCommonEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
