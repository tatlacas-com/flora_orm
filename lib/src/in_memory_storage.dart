import '../sql.dart';

import 'base_storage.dart';
import 'in_memory_db_context.dart';

class InMemoryStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, InMemoryDbContext> {
  const InMemoryStorage({required InMemoryDbContext dbContext})
      : super(dbContext: dbContext);
}
