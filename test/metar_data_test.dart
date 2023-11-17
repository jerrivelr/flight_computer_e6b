import 'dart:convert';
import 'dart:io';

import 'package:flight_e6b/communication_var.dart';
import 'package:test/test.dart';
import 'package:flight_e6b/data_parsing/metar_data.dart';

void main() {
  String jsonFile;
  List<dynamic> jsonDecoded;
  Metar metarData = Metar.fromJson([]);

  setUp(() {
    jsonFile = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\lib\test_response.json').readAsStringSync();
    jsonDecoded = jsonDecode(jsonFile) as List<dynamic>;

    metarData = Metar.fromJson(jsonDecoded);
    updateYamlFile();
  });
  
  group('METAR parsing test', () {
    test('No data', () {
      final noMetar = Metar.fromJson([]);
      expect(noMetar.temp, null);
      expect(noMetar.dew, null);
      expect(noMetar.windDirection, null);
      expect(noMetar.altimeter, null);
      expect(noMetar.rawMetar, null);
    });

    test('Value test', () {
      expect(metarData.temp, 25);
      expect(metarData.dew, 23);
      expect(metarData.windDirection, 0);
      expect(metarData.altimeter, 1013);
      expect(metarData.rawMetar, "KISP 170456Z AUTO 00000KT 10SM CLR 13/10 A2990 RMK AO2 SLP125 T01280100 402390128");
    });

    test('Wind variables', () {
      expect(metarData.windDirection, 0);
    });

    test('Conversion', () {
      expect(metarData.temperature, 25);
      expect(metarData.dewpoint, 23);
      expect(metarData.altimeterInHg, 1013);

    });
  });
}