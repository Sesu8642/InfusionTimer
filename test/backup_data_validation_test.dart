import 'package:test/test.dart';
import 'package:infusion_timer/backup_data.dart';
import 'package:infusion_timer/tea.dart';

late BackupData _sut;
Tea _validTea = Tea(0.1, "Some Tea", 10, 1,
    [Infusion(60), Infusion(120)], "This is just some tea");

void main() {
  group('Validation', () {
    // test('valid backup with teas is valid', () {
    //   _sut = new BackupData(100, [_validTea], {0.1: 2});
    //   _sut.validate();
    // });

    // test('valid backup without teas is valid', () {
    //   _sut = new BackupData(100, [], {});
    //   _sut.validate();
    // });

    // test('null tea vessel size is invalid', () {
    //   _sut = new BackupData(null, [], {});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('null teas is invalid', () {
    //   _sut = new BackupData(100, null, {});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('invalid tea is invalid', () {
    //   _sut = new BackupData(
    //       100, [new Tea(null, null, null, null, null, null)], {});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('non-unique tea id is invalid', () {
    //   _sut = new BackupData(100, [
    //     new Tea(0.1, "Some other Tea", 10, 1, [new Infusion(60)],
    //         "Some other tea with the same id"),
    //     _validTea
    //   ], {});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('null session tea id is invalid', () {
    //   _sut = new BackupData(100, [_validTea], {null: 1});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('null session index is invalid', () {
    //   _sut = new BackupData(100, [_validTea], {0.1: null});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('negative session index is invalid', () {
    //   _sut = new BackupData(100, [_validTea], {0.1: -1});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('positive but too small session index is invalid', () {
    //   _sut = new BackupData(100, [_validTea], {0.1: 1});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('too large session index is invalid', () {
    //   _sut = new BackupData(100, [_validTea], {0.1: 3});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });

    // test('session without matching tea is invalid', () {
    //   _sut = new BackupData(100, [_validTea], {0.2: 2});
    //   expect(() => _sut.validate(), throwsA(isA<FormatException>()));
    // });
  });
}
