import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';

import 'base_storage.dart';
import 'in_memory_db_context.dart';

class InMemoryStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, InMemoryDbContext> {
  const InMemoryStorage({required InMemoryDbContext dbContext})
      : super(dbContext: dbContext);
}
