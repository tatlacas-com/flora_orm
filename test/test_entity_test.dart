import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Test TestEntity', () {
    late TestEntity entity;
    setUp(() {
      entity = TestEntity(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1.0,
          testInt: 10,
          testString: 'Testing 123');
    });

    test('should be equal', () {
      var entity1 = TestEntity(
          testBool: true,
          testDateTime: entity.testDateTime,
          testDouble: 1.0,
          testInt: 10,
          testString: 'Testing 123');
      expect(entity, entity1);
      expect(entity.toString(), entity1.toString());
    });
  });
}
