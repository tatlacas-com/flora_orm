import 'package:example/user.entity.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// we recommened you instatiate and register OrmContext as singleton
  final orm = OrmContext(
    dbVersion: 1,
    dbName: 'orm_db_test.db',
    tables: <Entity>[
      /// You must register all entities you intend to save here
      UserEntity(),
    ],
  );

  /// Get a storage instance of the Entity type you want to use.
  /// **IMPORTANT remember to specify type ([UserLocalDataSource] for this example)
  /// to make your life easier when using storage object
  late final UserEntityLocalDataSource storage =
      orm.getDataSource(UserEntity());

  Future<UserEntity> _insertUser() async {
    await storage.insertOrUpdate(
      UserEntity(
        id: 'user1',
        firstName: 'John',
        lastName: 'Doe',
      ),
    );

    final user = await storage.firstWhereOrNull(
      (t) => Filter(t.lastName, value: 'Doe'),
    );
    return user!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: _insertUser(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading...');
            }
            final user = snapshot.data!;
            return Text('Hello, ${user.firstName} ${user.lastName}');
          },
        ),
      ),
    );
  }
}
