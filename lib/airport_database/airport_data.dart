import 'dart:convert';
import 'dart:io';

import 'package:flight_e6b/simple_io.dart';

class AirportData {
  static final _airportJson = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\lib\airport_database\airports.json');
  static final _content = _airportJson.readAsStringSync();
  static final _mapContent = jsonDecode(_content);

  AirportData(this._airportId);
  final String _airportId;

  String get airportId => _airportId;

  factory AirportData.inputCheck() {
    final idInput = input('Airport ID: ')?.toUpperCase();
    final iataInput = RegExp(r'"icao": "(\w{4})",\n\s{8}"iata": "' + (idInput ?? '') + r'",');

    if (iataInput.hasMatch(_content)) {
      final icao = iataInput.firstMatch(_content)?.group(1);
      return AirportData(icao ?? '');
    }

    return AirportData(idInput ?? '');
  }

  Future<int?> airportElevation() async {
    try {
      return _mapContent[_airportId]['elevation'] as int;
    } on NoSuchMethodError {
      return null;
    }
  }

  Future<String?> airportName() async {
    final icao = _mapContent[_airportId]?['name'];

    if (icao != null) {
      return icao;
    }

    return null;
  }
}
