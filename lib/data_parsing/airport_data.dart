import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:http/http.dart' as http;

final airportJson = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\lib\airport_database\airports.json');
final content = airportJson.readAsStringSync();
final contentDecoded = jsonDecode(content);

String? retrieveAirport() {
  final idInput = input(null, onlyNumbers: false, charLimit: 4)?.toUpperCase();

  // If user inputs something inside the optionList global variable, it will exit the option and jump to the selected
  // option without creating any instance.
  if (idInput?.isEmpty ?? true) {
    return idInput ?? '';
  }

  // This is for when user inputs the airport ID in IATA so the output is in ICAO because the weather API only accepts
  // airport in ICAO.
  final iataInput = RegExp(r'"icao": "(\w{4})",\n\s{8}"iata": "' + (idInput ?? '') + r'",');
  if (iataInput.hasMatch(content)) {
    final icao = iataInput.firstMatch(content)?.group(1);
    return icao;
  }

  return idInput;
}

int? airportElevation(String? airportId) {
  final elevation = contentDecoded?[airportId]?['elevation'] as int?;

  if (elevation != null) {
    return elevation;
  }

  return null;
}

String? airportName(String? airportId) {
  final icao = contentDecoded?[airportId]?['name'] as String?;

  if (icao != null) {
    return icao;
  }

  return null;
}

Future<List<dynamic>?> metar(String? airportId, {bool includeTaf = false}) async {
  if (airportId == null || airportId.isEmpty) {
    return null;
  }

  // returns the data downloaded from aviationweather.gov in List<dynamic>
  final queryParameters = {
    'ids': airportId,
    'format': 'json',
    'taf': includeTaf.toString()
  };

  final url = Uri.https('aviationweather.gov', '/api/data/metar.php', queryParameters);

  try {
    _downloadingText();

    final response = await http.get(url);
    final jsonMap = jsonDecode(response.body);

    comm.noInternet = false;
    comm.formatError = false;
    comm.screenCleared = true;

    comm.console.clearScreen();

    return jsonMap;

  } on SocketException {

    comm.noInternet = true;
    return null;

  } on HandshakeException {
    comm.handShakeError = true;
    return null;

  } on FormatException {
    comm.formatError = true;
    return null;

  } on HttpException {
    comm.httpError = true;
    return null;

  } on TimeoutException {
    comm.timeoutError = true;
    return null;
  }
}

void _downloadingText() {
  final row = (comm.console.windowHeight / 2).round() - 1;

  comm.console.resetColorAttributes();
  comm.console.cursorPosition = Coordinate(row - 2, 0);
  comm.console.hideCursor();
  comm.console.setTextStyle(bold: true, italic: true);
  comm.console.writeLine('Downloading...', TextAlignment.center);
  comm.console.setTextStyle();
}


List<dynamic>? testMetar() {
  try {
    final jsonFile = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\lib\test_response.json');
    final decodedMetar = jsonDecode(jsonFile.readAsStringSync());

    return decodedMetar;
  } on FormatException {
    comm.formatError = true;
    return null;
  }
}