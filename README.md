# flora_orm

[![pub package](https://img.shields.io/pub/v/flora_orm.svg)](https://pub.dev/packages/flora_orm)

Database ORM (Object-Relational Mapping) for [Flutter](https://flutter.io).

The ORM supports:
* [shared_preferences](https://pub.dev/packages/shared_preferences) - All platforms support
* [sqflite](https://pub.dev/packages/sqflite) - iOS/Android/MacOS support
* [sqflite_common_ffi on disk](https://pub.dev/packages/sqflite_common_ffi) - iOS/Android/MacOS/Linux/Windows support
* [sqflite_common_ffiin memory](https://pub.dev/packages/sqflite_common_ffi) - iOS/Android/MacOS/Linux/Windows support

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

To use `flora_orm`, you need to create entity classes that satisfy the following:

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
  @OrmColumn(isEnum: true)
  final OAuthProvider? provider;

  @override
  @column
  final String? photoURL;
}

enum OAuthProvider { google, apple, facebook }
```

Once you have created or updated your entity files, open terminal and directory run the following from the root:
```bash
dart run build_runner build
```
#### OrmManager

You need an instance of `OrmManager` to interact with the storage.  
Create an instance of `OrmManager` as early as possible.  
  
We recommend registering it as singleton during app start-up using [get_it](https://pub.dev/packages/get_it) or any DI you prefer.

For example, in your `void main()` function before `runApp()`,  you can have the following:

```dart
final ormManager = OrmManager(
     /// update this version number whenever you update your entities
     /// such as adding new properties/fields.
      dbVersion: 1,
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

The `dbEngine` value defaults to `DbEngine.sqflite`, and may be one of the following:

```yaml
  inMemory: 
  sqfliteCommon:
  sqflite:
  sharedPreferences: 
```
However, not all engines are available on all platforms. Here is a breakdown of each platform and supported engines:

```yaml
Andoid: all (we recommend sqflite)
iOS: all (we recommend sqflite)
macOS: all (we recommend sqflite)
Linux: inMemory, sqfliteCommon, sharedPreferences (defaults to sqfliteCommon)
Windows: inMemory, sqfliteCommon, sharedPreferences (defaults to sqfliteCommon)
web: sharedPreferences (defaults to sharedPreferences)
```
If you provide a `dbEngine` value not supported by a platform, then the default for that platform is used.

Once your `OrmManager` is set, you can use it from anywhere in your code. If you are using [get_it](https://pub.dev/packages/get_it), you can get your `storage` instance as:

```dart
final orm = GetIt.I<OrmManager>();
final storage = orm.getStorage(/* Instance of your Entity here */);
```
For example, for `UserEntity`:

```dart
final orm = GetIt.I<OrmManager>();
final storage = orm.getStorage(const UserEntity())
```

### CRUD functions

#### Create
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
An equivalent for insertOrUpdate exists:
```dart
final entities = await storage.insertOrUpdateList([
                                UserEntity(id: 'user1',   
                                displayName: 'Test User'), 
                                ...,
                                ]);
```

### Read
Get single record:

```dart
final entity = await storage.firstWhereOrNull(...);
```
More than one record:


```dart
final entities = await storage.where(...);
```

### Update

You can use the insertOrUpdate options as explained before for inserting record  
if it doesn't exist. But, if all you want is to update, then:


```dart
final entities = await storage.update(where: ...);
```

### Delete


```dart
final entities = await storage.delete(where: ...);
```

### The `Filter` function

Most of the queries will need a `where` parameter which is a function that must return a `Filter`.  
The function has a parameter `t` which is meta description your properties of `ColumnDefinition`s.  

Here are some examples:

#### Get `UserEntity` with `id = 'user1'`
```dart
final user = await storage.firstWhereOrNull(
      where: (t) => Filter(
        t.id,
        value: 'user1',
      ),
    );
```

#### Delete all `UserEntity`s with `uid NOT NULL`
```dart
await storage.delete(
      where: (t) => Filter(
        t.uid,
        condition: OrmCondition.notNull,
      ),
    );
```
#### Get all `UserEntity`s with `rating >= 20`
```dart
final users = await storage.where(
      where: (t) => Filter(
        t.rating,
        condition: OrmCondition.greaterThanOrEqual,
        value: 20,
      ),
    );
```
#### Get all `UserEntity`s with `rating between 10 and 100`
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
#### Chaining and grouping filters

You can have complex filters that meet your needs.  
Use utility functions such as `startGroup()`, `endGroup()`, `filter()` `and()`, and `or()`.  

The above functions also take `openGroup` and `closeGroup` to simplify the grouping so that you may not need `startGroup()` and `endGroup()` However, we recommend using `startGroup()` and `endGroup()` since they are easy to read and understand their effects.  

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
`startGroup()` must usually be followed by `filter()` before chaining additional filters. Remember to `endGroup()`.
### Migrations

If you add columns, increment  `OrmManager`'s `dbVersion` then add the migrations for that version on the respective `{entity_name}.entity.migrations.dart` files.  

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
  List<ColumnDefinition> addColumnsAt(int newVersion) {
    return switch (newVersion) {
        /// Here we are saying we added property 
        /// named provider on version 2.
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

As a reminder, when you update your entity files, run:
```bash
dart run build_runner build
```

### Supported data types

* String
* bool
* int
* double
* DateTime
* enums (needs `@OrmColumn(isEnum: true)` to be specified)
* Lists of above types (e.g `List<String>`)

