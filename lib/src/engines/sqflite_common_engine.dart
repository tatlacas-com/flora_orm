import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/context/sqflite_common_store_context.dart';
import 'package:flora_orm/src/engines/base_orm_engine.dart';

class SqfliteCommonEngine<TModel extends ModelBase,
        TMeta extends ModelMeta<TModel>>
    extends BaseOrmEngine<TModel, TMeta, SqfliteCommonStoreContext<TModel>> {
  const SqfliteCommonEngine(
    super.t, {
    required super.dbContext,
    super.useIsolateDefault = true,
  });
}
