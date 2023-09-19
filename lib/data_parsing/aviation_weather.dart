import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flight_e6b/communication_var.dart' as comm;

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