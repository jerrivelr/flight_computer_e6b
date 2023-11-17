import 'package:flight_e6b/conversion/conversion_func.dart';
import 'package:flight_e6b/enums.dart';
import 'package:test/test.dart';

void main() {
  group('Conversions', () {
    test('Altitude Conversion', () {
      final altConv = altitudeConv(inputUnit: Conversion.feet, alt: 2000);

      expect(altConv.round(), 6562);

      final result = altitudeConv(inputUnit: Conversion.feet, alt: altConv, convResult: true);
      expect(result.round(), 2000);
    });

    test('Pressure Conversion: MB to IngHg', () {
      final pressureInHg = pressConv(inputUnit: Conversion.inchesMercury, pressUnit: 30.05);
      expect(pressureInHg, equals(30.05));

      final pressureMb = pressConv(inputUnit: Conversion.millibars, pressUnit: 29.68);
      expect(pressureMb.round(), 1005);
    });
  });


}