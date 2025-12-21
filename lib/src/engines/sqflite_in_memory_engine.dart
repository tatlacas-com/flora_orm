import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/flora_orm.dart';

import 'package:flora_orm/src/engines/base_orm_engine.dart';

class SqfliteInMemoryEngine<
  TModel extends ModelBase,
  TMeta extends ModelMeta<TModel>
>
    extends BaseOrmEngine<TModel, TMeta, SqfliteInMemoryStoreContext<TModel>> {
  const SqfliteInMemoryEngine(
    super.t, {
    required super.dbContext,
    super.useIsolateDefault = true,
  });
}
