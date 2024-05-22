import 'package:tatlacas_orm/src/engines/base_engine.dart';
import '../../tatlacas_orm.dart';

import '../contexts/sqflite_db_context.dart';

class SqfliteEngine<TEntity extends IEntity>
    extends BaseEngine<TEntity, SqfliteDbContext> {
  const SqfliteEngine(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
}
