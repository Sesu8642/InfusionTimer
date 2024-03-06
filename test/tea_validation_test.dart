import 'package:test/test.dart';
import 'package:infusion_timer/tea.dart';

late Tea _sut;

void main() {
  setUp(() {
    // start with a valid tea
    _sut = Tea(0.012345, "Some Tea", 10, 1, [Infusion(60)],
        "This is just some tea", "Notes...", 2);
  });

  group('Validation', () {
    test('valid tea is valid', () {
      _sut.validate();
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

    test('empty infusions is invalid', () {
      _sut.infusions = [];
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('negative infusion time is invalid', () {
      _sut.infusions = [Infusion(-1)];
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

    test('null subtitle is invalid', () {
      _sut.subtitle = null;
      expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    });

  });
}
