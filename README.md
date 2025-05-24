# flora_orm

[![pub package](https://img.shields.io/pub/v/flora_orm.svg)](https://pub.dev/packages/flora_orm)

Database ORM (Object-Relational Mapping) for [Flutter](https://flutter.io).

The ORM supports:
* [shared_preferences](https://pub.dev/packages/shared_preferences) - All platforms
* [sqflite](https://pub.dev/packages/sqflite) - iOS/Android/MacOS
* [sqflite_common_ffi - on disk](https://pub.dev/packages/sqflite_common_ffi) - iOS/Android/MacOS/Linux/Windows
* [sqflite_common_ffi - in memory](https://pub.dev/packages/sqflite_common_ffi) - iOS/Android/MacOS/Linux/Windows

## Getting Started

To get started, you need to add `flora_orm` to your project. Follow the steps below:

1. Open the terminal in your project root. You can do this by pressing `Alt+F12` in Android Studio or `` Ctrl+` `` in VS Code.

2. Run the following command:

```bash
flutter pub add flora_orm
```


This command will add a line to your package's `pubspec.yaml` file and run an implicit `flutter pub get`.  
The added line will look like this:

```yaml
dependencies:
  flora_orm: 
```

## Usage example

Import `flora_orm.dart`

```dart
import 'package:flora_orm/flora_orm.dart';
```

### Initializing

To use `flora_orm`, you need to create entity classes.  

For VS Code users, we have a snippet for you so that you don't have to type the boilerplate code.  
See [more infomation on how to add and use the snippet](https://github.com/tatlacas-com/flora_orm/tree/main/doc/vscode_snippet.md).

Your entity class must satisfy the following:

* Naming conversion is `{entity_name}.entity.dart`. For example `user.entity.dart` _(recommended)_.
* You **must** add 2 `part`s to the top of the entity file: `{entity_name}.entity.g.dart` and `{entity_name}.entity.migrations.dart`.
* You **must** annotate the class with `@entity` (or `@OrmEntity()` for granular control).
* Your entity class **must** extend `Entity<{YourEntityName}, {YourEntityName}Meta> with _{YourEntityName}Mixin, {YourEntityName}Migrations`.


#### Example Entity

```dart
import 'package:flora_orm/flora_orm.dart';

part 'user.entity.g.dart';
part 'user.entity.migrations.dart';

@OrmEntity(tableName: 'user')
class UserEntity extends Entity<UserEntity, UserEntityMeta>
    with _UserEntityMixin, UserEntityMigrations {

  const UserEntity({
    super.id,
    super.collectionId,
    super.createdAt,
    super.updatedAt,
    this.claims,
    this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.provider,
  });

  @override
  @column
  final List<String>? claims;

  @override
  @column
  final String? uid;

  @override
  @column
  final String? email;
  @override
  @column
  final String? phoneNumber;
  
  @override
  @column
  final String? displayName;
  
  @override
  @column
  final OAuthProvider? provider;

  @override
  @column
  final String? photoURL;
}

enum OAuthProvider { google, apple, facebook }
```

Once you have created or updated your entity files, open terminal and run the following from the root directory of your project:
```bash
dart run build_runner build
```

## OrmManager

You need an instance of `OrmManager` to interact with the storage.  

Create an instance of `OrmManager` as early as possible.  
  
We recommend registering it as a singleton during app start-up using [get_it](https://pub.dev/packages/get_it) or any DI you prefer.

For example, in your `void main()` function before `runApp()`,  you can have the following:

```dart
final ormManager = OrmManager(
     /// update this version number whenever you add or update your entities
     /// such as adding new properties/fields.
      dbVersion: 1,
      /// dbEngine defaults to DbEngine.sqflite if not specified
      dbEngine: DbEngine.sqflite,
      dbName: 'your_db_name_here.db',
      tables: <Entity>[
        /// instatiate all your entities that must be saved in db here
        const UserEntity(),
      ],
    );
GetIt.I.registerSingleton(ormManager);
```
To keep your code clean, we recommend you have the above code in a seperate file. For example in `src/orm.init.dart`  

**IMPORTANT**: After adding entity classes (and updating existing entities), don't forget to:

1. Run from terminal:
```bash
dart run build_runner build
```
2. Update `dbVersion` in `OrmManager`  - if you changed columns or added new Entity classes.
3. **REGISTER** any new entities in `OrmManager`'s `tables: []`.

The `dbEngine` value defaults to `DbEngine.sqflite`, and may be one of the following:

```dart
  inMemory,
  sqfliteCommon,
  sqflite,
  sharedPreferences,
```
However, not all engines are available on all platforms. Here is a breakdown of each platform and supported engines:
** If you provide a `dbEngine` value not supported by a platform, then the default for that platform is used.

```yaml
Andoid: all (we recommend sqflite)
iOS: all (we recommend sqflite)
macOS: all (we recommend sqflite)
Linux: inMemory, sqfliteCommon, sharedPreferences (defaults to sqfliteCommon)
Windows: inMemory, sqfliteCommon, sharedPreferences (defaults to sqfliteCommon)
web: sharedPreferences (defaults to sharedPreferences)
```

Once your `OrmManager` is set, you can use it from anywhere in your code. If you are using [get_it](https://pub.dev/packages/get_it) for example, you can get your `storage` instance as:

```dart
final orm = GetIt.I<OrmManager>();
final {EntityType}Orm storage = orm.getStorage(/* Instance of your Entity here */);
```
For example, to get `storage` for `UserEntity`:

```dart
final orm = GetIt.I<OrmManager>();
final UserEntityOrm storage = orm.getStorage(const UserEntity())
```
**IMPORTANT**: You **NEED** to specify type (e.g `UserEntityOrm` above) for you to get `ColumnDefition`s on your `Filter`s later. The type class is auto-generated when you run `dart run build_runner build`

## CRUD operations

### C~~RUD~~ - Create
Will throw error if record with same `id` already exists:
```dart
final entity = await storage.insert(
                                UserEntity(id: 'user1',   
                                displayName: 'Test User',
                                ));
```
We recommend using [uuid](https://pub.dev/packages/uuid) for generating ids.  
  
You can `insertOrUpdate` instead, which will update record if it exists:
```dart
final entity = await storage.insertOrUpdate(
                                UserEntity(id: 'user1',   
                                displayName: 'Test User',
                                ));
```

You can insert more than one record at a time:

```dart
final entities = await storage.insertList([
                                UserEntity(id: 'user1',   
                                displayName: 'Test User'), 
                                ...,
                                ]);
```
An equivalent for insertOrUpdate for more that one record exists:
```dart
final entities = await storage.insertOrUpdateList([
                                UserEntity(id: 'user1',   
                                displayName: 'Test User'), 
                                ...,
                                ]);
```

### ~~C~~R~~UD~~ - Read
Get single record:

```dart
final entity = await storage.firstWhereOrNull(...);
```
More than one record:


```dart
final entities = await storage.where(...);
```

### ~~CR~~U~~D~~ - Update

You can  use the insertOrUpdate options as explained before, which will insert records  
if they do not exist. But, if all you want is to strictly update existing records, then:


```dart
final updatedCount = await storage.update(where: ...);
```

### ~~CRU~~D - Delete


```dart
final deletedCount = await storage.delete(where: ...);
```

## The `Filter` function

Most of the queries will need a `where` parameter which is a function that must return a `Filter`.  
The function has a parameter `t` which is meta description of your properties as `ColumnDefinition`s.  

Here are some examples:

##### Get `UserEntity` with `id = 'user1'`
```dart
final user = await storage.firstWhereOrNull(
      where: (t) => Filter(
        t.id,
        value: 'user1',
      ),
    );
```

##### Delete all `UserEntity`s with `uid != null`
```dart
await storage.delete(
      where: (t) => Filter(
        t.uid,
        condition: OrmCondition.notNull,
      ),
    );
```
##### Get all `UserEntity`s with `rating >= 20`
```dart
final users = await storage.where(
      where: (t) => Filter(
        t.rating,
        condition: OrmCondition.greaterThanOrEqual,
        value: 20,
      ),
    );
```
##### Get all `UserEntity`s with `rating between 10 and 100`
```dart
final users = await storage.where(
      where: (t) => Filter(
        t.rating,
        condition: OrmCondition.between,
        value: 10,
        secondaryValue: 100,
      ),
    );
```
### Chaining and grouping filters

You can have complex filters that meet your needs.  
Use utility functions such as `startGroup()`, `endGroup()`, `filter()` `and()`, and `or()`.  

`filter()` `and()`, and `or()` also have parameters `openGroup` and `closeGroup` to simplify the grouping so that you may not need `startGroup()` and `endGroup()`. However, we recommend using `startGroup()` and `endGroup()` since they are easy to read and understand their effects.  

Think of grouping as opening and closing brackets, and putting the operations in-between the `openGroup`...`closeGroup` into those brackets.

In the example below, the last `or()` and `and()` filters will be grouped into `(...)`.
  
Example:
```dart
final users = await storage.where(
      where: (t) => Filter.startGroup()
          .filter(
            t.displayName,
            condition: OrmCondition.like,
            value: '%flu%',
          )
          .and(
            t.rating,
            value: 10,
          )
          .endGroup()
          .or(
            openGroup: true,
            t.displayName,
            value: 'Loveable',
          )
          .and(
            t.rating,
            value: 11002,
            closeGroup: true,
          ),
    );
```
`startGroup()` must usually be followed by `filter()` before chaining additional filters. Remember to `endGroup()`/`closeGroup`.

## Migrations - Changes to Entity classes and Database updates

If you update any of your `Entity` classes, you need to run `dart run build_runner build` again.  

If you add/remove `@column` or any annotated item in your `Entity`  classes then **increment**  `OrmManager`'s `dbVersion`, **register** new Entity classes in `OrmManager`'s `tables: []`, and add the migrations in the respective `{entity_name}.entity.migrations.dart` files.  

The simplest way to migrate is either to drop and recreate the entity table (losing all data in that table), or specifying the added columns:  

Example `UserEntity` migration: _(the file itself is auto-generated the first time you run `dart run build_runner build`)_:

```dart
mixin UserEntityMigrations on Entity<UserEntity, UserEntityMeta> {
  @override
  bool recreateTableAt(int newVersion) {
    return switch (newVersion) {
        /// when dbVersion = 3, drop and recreate table
        3 => true,
      _ => false,
    };
  }

  @override
  List<ColumnDefinition<UserEntity, dynamic>> addColumnsAt(int newVersion) {
    return switch (newVersion) {
        /// Here we are saying we added property 
        /// named provider when we set dbVersion = 2.
        /// All [@column] properties in your entity class 
        /// are available in [meta] object as [ColumnDefinition]s
      2 => [meta.provider],
      _ => [],
    };
  }
}
```

In `{entity_name}.entity.migrations.dart` You can also override `downgradeTable()` and `additionalUpgradeQueries()`, returning queries that must be run during that operation.  

You can also override `onUpgradeComplete` and `onDowngradeComplete` to return custom queries that will be run after completion of upgrade/downgrade.  

There is also `onCreateComplete` which you can return queries that will be run the first time the database is created.

**IMPORTANT**: As a reminder, after adding Entity classes (and edited existing Entity classes), don't forget to:

1. Run from terminal:
```bash
dart run build_runner build
```
2. Update `dbVersion` in `OrmManager` - if you changed columns or added new Entity classes.
3. **REGISTER** the new entity in `OrmManager`'s `tables: []`.

## Supported data types

* String
* bool
* int
* double
* DateTime
* enums
* Custom classes (Objects) - they need to have factory `fromMap(map)` and function `toMap()`
* Lists of above types (e.g `List<String>`)

All entity classes will already have toMap implemented. You need to define the factory `fromMap(map)` if you want to have the class as a column in another entity.   
For convenience, you can call the `load()` function that will do the rest.

Example factory for `UserEntity`:

```dart
@OrmEntity(tableName: 'user')
class UserEntity extends Entity<UserEntit... {
  
  /// default constructor here

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return const UserEntity().load(map);
  }

  /// rest of the class here
}
```

