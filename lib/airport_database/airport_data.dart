import 'dart:convert';
import 'dart:io';

final airportJson = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\lib\airport_database\airports.json');

int? airportElevation(String airportId) {
  final content = airportJson.readAsStringSync();
  final mapContent = jsonDecode(content);

  try {
    return mapContent[airportId]['elevation'] as int;
  } on NoSuchMethodError {
    return null;
  }
}

String? airportName(String airportId) {
  final content = airportJson.readAsStringSync();
  final mapContent = jsonDecode(content);

  try {
    return mapContent[airportId]['name'] as String;
  } on NoSuchMethodError {
    return null;
  }
}
