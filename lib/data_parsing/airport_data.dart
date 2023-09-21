import 'dart:convert';
import 'dart:io';

import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:http/http.dart' as http;

final airportJson = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\lib\airport_database\airports.json');
final content = airportJson.readAsStringSync();
final contentDecoded = jsonDecode(content);

String? retrieveAirport() {
  final idInput = input('Airport ID: ')?.toUpperCase();

  // If user inputs something inside the optionList global variable, it will exit the option and jump to the selected
  // option without creating any instance.
  if (comm.optionList.contains(idInput?.toLowerCase())) {
    comm.selectedOption = idInput?.toLowerCase();
    return null;
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

int? airportElevation(String airportId) {
  final elevation = contentDecoded?[airportId]?['elevation'] as int?;

  if (elevation != null) {
    return elevation;
  }

  return null;
}

String? airportName(String airportId) {
  final icao = contentDecoded?[airportId]?['name'] as String?;

  if (icao != null) {
    return icao;
  }

  return null;
}

Future<List<dynamic>> metar(String airportId, {bool includeTaf = false}) async {
  // returns the data downloaded from aviationweather.gov in List<dynamic>
  final queryParameters = {
    'ids': airportId,
    'format': 'json',
    'taf': includeTaf.toString()
  };

  final url = Uri.https('beta.aviationweather.gov', '/cgi-bin/data/metar.php', queryParameters);

  try {
    final response = await http.get(url);
    final jsonMap = jsonDecode(response.body);
    comm.noInternet = false;

    return jsonMap;

  } on SocketException {
    comm.noInternet = true;
    return <dynamic>[];

  } on HandshakeException {
    return <dynamic>[];

  } on FormatException {
    comm.error = 'Downloaded data is corrupt. Trying again.';
    comm.formatError = true;
    return <dynamic>[];

  } on HttpException {
    return <dynamic>[];
  }
}

List<dynamic> testMetar() {
  final jsonFile = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\lib\test_response.json');
  final decodedMetar = jsonDecode(jsonFile.readAsStringSync());

  return decodedMetar;
}