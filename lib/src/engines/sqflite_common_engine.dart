import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/contexts/sqflite_common_store_context.dart';
import 'package:flora_orm/src/engines/base_orm_engine.dart';

class SqfliteCommonEngine<TEntity extends EntityBase,
        TMeta extends EntityMeta<TEntity>>
    extends BaseOrmEngine<TEntity, TMeta, SqfliteCommonStoreContext<TEntity>> {
  const SqfliteCommonEngine(
    super.t, {
    required super.dbContext,
    super.useIsolateDefault = true,
  });
}
