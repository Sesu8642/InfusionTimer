import 'package:test/test.dart';
import 'package:infusion_timer/tea.dart';

Tea _sut;

void main() {
  setUp(() {
    // start with a valid tea
    _sut = new Tea(0.012345, "Some Tea", 10, 1, [new Infusion(60)],
        "This is just some tea");
  });

  group('Validation', () {
    test('valid tea is valid', () {
      _sut.validate();
    });

    test('null id is invalid', () {
      _sut.id = null;
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('null name is invalid', () {
      _sut.name = null;
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('null temperature is invalid', () {
      _sut.temperature = null;
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('null gPer100Ml is invalid', () {
      _sut.gPer100Ml = null;
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('null infusions is invalid', () {
      _sut.infusions = null;
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('empty infusions is invalid', () {
      _sut.infusions = [];
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('null infusion time is invalid', () {
      _sut.infusions = [new Infusion(null)];
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('negative infusion time is invalid', () {
      _sut.infusions = [new Infusion(-1)];
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('null notes is invalid', () {
      _sut.notes = null;
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });
  });
}
