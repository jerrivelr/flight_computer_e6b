import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flight_e6b/menu_logic.dart';

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
    MenuLogic.noInternet = false;

    return jsonMap;
  } on SocketException {
    MenuLogic.noInternet = true;
    await Future.delayed(Duration(seconds: 2));
    return <dynamic>[];
  } on HandshakeException {
    // TODO add an implentation
    return <dynamic>[];
  }
}