# VSCode Snippets

### Generate boilerplate code for Entity classes

In VSCode click on __Settings__ icon then __Snippets__. Create new snippet then paste the following:

```json
{
	"Flora ORM Entity Snippet": {
	  "prefix": "entity",
	  "body": [
		"import 'package:flora_orm/flora_orm.dart';",
		"",
		"part '${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/lowercase}/}.entity.g.dart';",
		"part '${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/lowercase}/}.entity.migrations.dart';",
		"",
		"@OrmEntity(tableName: '${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/lowercase}/}')",
		"class ${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/pascalcase}/}Entity extends Entity<${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/pascalcase}/}Entity, ${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/pascalcase}/}EntityMeta>",
		"    with _${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/pascalcase}/}EntityMixin, ${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/pascalcase}/}EntityMigrations {",
		"",
		"  const ${TM_FILENAME_BASE/^(.*)\\.entity$/${1:/pascalcase}/}Entity({",
		"    super.id,",
		"    super.createdAt,",
		"    super.updatedAt,",
		"  });",
		"}"
	  ],
	  "description": "Snippet for creating a Flora ORM entity class"
	}
  }
```

Now you can create your entity files as follows:
* Create file in format `{entity}.entity.dart` for example `notification.entity.dart`
* Start typing then word `entity` and press tab. This will put something like the following boilerplate code in your file:

```dart
import 'package:flora_orm/flora_orm.dart';

part 'notification.entity.g.dart';
part 'notification.entity.migrations.dart';

@OrmEntity(tableName: 'notification')
class NotificationEntity
    extends Entity<NotificationEntity, NotificationEntityMeta>
    with _NotificationEntityMixin, NotificationEntityMigrations {
  const NotificationEntity({
    super.id,
    super.createdAt,
    super.updatedAt,
  });
}
```

You can then begin adding your properties such as `@column`s.   

**IMPORTANT**: After adding Entity classes (and updating existing entities), don't forget to:

1. Run from terminal:
```bash
dart run build_runner build
```
2. Update `dbVersion` in `OrmManager` - if you changed columns or added new Entity classes.
3. **REGISTER** the new entity in `OrmManager`'s `tables: []`.