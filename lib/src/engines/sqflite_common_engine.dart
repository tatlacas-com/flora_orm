import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/contexts/sqflite_common_db_context.dart';
import 'package:flora_orm/src/engines/base_orm_engine.dart';

class SqfliteCommonEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends BaseOrmEngine<TEntity, TMeta, SqfliteCommonDbContext<TEntity>> {
  const SqfliteCommonEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true,});
}
