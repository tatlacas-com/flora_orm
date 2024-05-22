import '../../tatlacas_orm.dart';

import 'base_engine.dart';
import '../contexts/sqflite_common_db_context.dart';

class SqfliteCommonEngine<TEntity extends IEntity>
    extends BaseEngine<TEntity, SqfliteCommonDbContext> {
  const SqfliteCommonEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
