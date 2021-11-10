import 'package:tatlacas_sqflite_storage/src/base_storage.dart';
import '../sql.dart';

import 'sqflite_db_context.dart';

class SqfliteStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, SqfliteDbContext> {
  const SqfliteStorage({required SqfliteDbContext dbContext})
      : super(dbContext: dbContext);

}
