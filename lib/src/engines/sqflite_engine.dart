import 'package:flora_orm/src/engines/base_orm_engine.dart';
import '../../flora_orm.dart';

import '../contexts/sqflite_db_context.dart';

class SqfliteEngine<TEntity extends IEntity, TMeta extends EntityMeta<TEntity>>
    extends BaseOrmEngine<TEntity, TMeta, SqfliteDbContext<TEntity>> {
  const SqfliteEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
