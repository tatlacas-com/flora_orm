import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';

import 'base_storage.dart';
import 'sqflite_common_db_context.dart';

class SqfliteCommonStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, SqfliteCommonDbContext> {
  const SqfliteCommonStorage({required SqfliteCommonDbContext dbContext})
      : super(dbContext: dbContext);

}
