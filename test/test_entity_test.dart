import 'package:flora_orm/src/bloc/test_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Test TestModel', () {
    late TestModel model;
    setUp(() {
      model = TestModel(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1,
        testInt: 10,
        testString: 'Testing 123',
      );
    });

    test('should be equal', () {
      final model1 = TestModel(
        testBool: true,
        testDateTime: model.testDateTime,
        testDouble: 1,
        testInt: 10,
        testString: 'Testing 123',
      );
      expect(model, model1);
      expect(model.toString(), model1.toString());
    });
  });
}
