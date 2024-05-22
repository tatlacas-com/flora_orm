import '../../tatlacas_orm.dart';

import 'base_engine.dart';
import '../contexts/sqflite_common_db_context.dart';

class SqfliteCommonEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends BaseEngine<TEntity, TMeta, SqfliteCommonDbContext> {
  const SqfliteCommonEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
