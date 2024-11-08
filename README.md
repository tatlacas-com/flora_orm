# flora_orm

[![pub package](https://img.shields.io/pub/v/flora_orm.svg)](https://pub.dev/packages/flora_orm)

Database ORM (Object-Relational Mapping) for [Flutter](https://flutter.io).

The ORM supports:
* [shared_preferences](https://pub.dev/packages/shared_preferences) - All platforms support
* [sqflite](https://pub.dev/packages/sqflite) - iOS, Android and MacOS support
* [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi) - Linux/Windows/DartVM support

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

To use `flora_orm`, you need to create entity classes that meets the following:

* Recommended naming conversion is `{entity_name}.entity.dart`. For example `user.entity.dart`.
* You must add 2 `parts` to the top of the entity file: `{entity_name}.entity.dart` and `{entity_name}.entity.migrations.dart`.
* You must annotate the class as `@entity` (or `@OrmEntity()` for granular control) 
* Your entity class **must** extend `Entity<{YourEntityName}, {YourEntityName}Meta> with _{YourEntityName}Mixin, {YourEntityName}Migrations`.

#### Example Entity

```dart
import 'package:flora_orm/flora_orm.dart';

part 'user.entity.g.dart';
part 'user.entity.migrations.dart';

@OrmEntity(tableName: 'user')
class UserEntity extends Entity<UserEntity, UserEntityMeta>
    with _UserEntityMixin, UserEntityMigrations{

  const AppUserEntity({
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
  final AppOAuthProvider? provider;

  @override
  @column
  final String? photoURL;
}

enum AppOAuthProvider { google, apple, facebook }
```

Once you have created or updated your entity files, open terminal and from the root directory run:
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
      dbName: 'your_db_name_here.db',
      tables: <Entity>[
        /// instatiate all your entities that must be saved in db here
        const UserEntity(),
      ],
    );
GetIt.I.registerSingleton(ormManager);
```
To keep your code clean, we recommend you have the above code in a seperate file. For example in `src/orm.init.dart`

Once your `OrmManager` is set, you can use it from anywhere in your code. If you are using [get_it](https://pub.dev/packages/get_it), you can get your storage instance as:

```dart
final storage = GetIt.I<OrmManager>().getStorage(const UserEntity())
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
  
You can insert or update instead, which will update record if it exists:
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
The function has a parameter `t` which is meta description of columns.  
Here is some examples of the filter:

#### Get User with id = 'user1'
```dart
final user = await _repo.firstWhereOrNull(
      where: (t) => Filter(
        t.id,
        value: 'user1',
      ),
    );
```

#### Delete all Users with id NOT NULL
```dart
await _repo.delete(
      where: (t) => Filter(
        t.uid,
        condition: OrmCondition.notNull,
      ),
    );
```
#### Get all Users with rating >= 20
```dart
final users = await _repo.where(
      where: (t) => Filter(
        t.rating,
        condition: greaterThanOrEqual,
        value: 20,
      ),
    );
```
#### Get all Users with rating between 10 and 100
```dart
final users = await _repo.where(
      where: (t) => Filter(
        t.rating,
        condition: between,
        value: 10,
        secondaryValue: 100,
      ),
    );
```
#### Chaining and grouping filters

You can have complex filters that meet your needs.  
Use utility functions such as `startGroup()`, `endGroup()`, `filter()` `and()`, `and or()`.  

The above functions functions also take `openGroup` and `closeGroup` to simplify the grouping so that you may not need `startGroup()` and `endGroup()`, but using `startGroup()` and `endGroup()` is advisable since they are easy to understand their effects.  

In the example below, the last `or()` and `and()` filters will be grouped into `(...)`.
  
Example:
```dart
final users = await _repo.where(
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

### Migrations

If you add columns, increment  `OrmManager`'s `dbVersion` then add the migrations for that version on the respective `{entity_name}.entity.migrations.dart` files.  

The simplest way is either to drop and recreate the entity, or specify the added columns:  

Example UserEntity migration (this file is auto-generated the first time):

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
        /// Here we are saying we added column property 
        /// provider on version 2.
        /// All [@column] properties in your entity class 
        /// are available in [meta] object as [ColumnDefinition]s
      2 => [meta.provider],
      _ => [],
    };
  }
}
```

In `migrations.dart` You can also override `downgradeTable()` and `additionalUpgradeQueries()`.  

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
* Lists of above types

