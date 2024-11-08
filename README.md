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


This command will add a line to your package's `pubspec.yaml` file and run an implicit `flutter pub get`. The added line will look like this:

```yaml
dependencies:
  flora_orm: 
```