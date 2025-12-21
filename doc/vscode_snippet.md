# VSCode Snippets

### Generate boilerplate code for Model classes

In VSCode click on __Settings__ icon then __Snippets__. Create new snippet then paste the following:

```json
{
	"Flora ORM Model Snippet": {
	  "prefix": "model",
	  "body": [
		"import 'package:flora_orm/flora_orm.dart';",
		"",
		"part '${TM_FILENAME_BASE/^(.*)\\_model$/${1:/lowercase}/}_model.g.dart';",
		"part '${TM_FILENAME_BASE/^(.*)\\_model$/${1:/lowercase}/}_model.migrations.dart';",
		"",
		"@OrmModel(tableName: '${TM_FILENAME_BASE/^(.*)\\_model$/${1:/lowercase}/}')",
		"class ${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}Model extends Model<${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}Model, ${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}ModelMeta>",
		"    with _${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}ModelMixin, ${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}ModelMigrations {",
		"",
		"  const ${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}Model({",
		"    super.id,",
		"    super.collectionId,",
		"    super.createdAt,",
		"    super.updatedAt,",
		"  });",
		"  factory ${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}Model.fromMap(Map<String, dynamic> map) {",
		"    return const ${TM_FILENAME_BASE/^(.*)\\_model$/${1:/pascalcase}/}Model().load(map);",
		"  }",
		"${0://Press space then RUN `dart run build_runner build` from terminal.}",
		"}"
	  ],
	  "description": "Snippet for creating a Flora ORM model class"
	}
  }
```

Now you can create your model files as follows:
* Create file in format `{model}_model.dart` for example `notification_model.dart`
* Start typing then word `model` and press tab. This will put something like the following boilerplate code in your file:

```dart
import 'package:flora_orm/flora_orm.dart';

part 'notification_model.g.dart';
part 'notification_model.migrations.dart';

@OrmModel(tableName: 'notification')
class NotificationModel
    extends Model<NotificationModel, NotificationModelMeta>
    with _NotificationModelMixin, NotificationModelMigrations {
  const NotificationModel({
    super.id,
    super.collectionId,
    super.createdAt,
    super.updatedAt,
  });
}
```
after boilerplate code is inserted, run `dart run build_runner build` to generate files and resolve errors.  
You can then begin adding your properties such as `@column`s.   

**IMPORTANT**: After adding Model classes (and updating existing entities), don't forget to:

1. Run from terminal:
```bash
dart run build_runner build
```
2. Update `dbVersion` in `OrmContext` - if you changed columns or added new Model classes.
3. **REGISTER** the new model in `OrmContext`'s `tables: []`.