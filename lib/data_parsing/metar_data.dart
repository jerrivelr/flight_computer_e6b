class Metar {
  Metar({
    required this.temperature,
    required this.dewpoint,
    required this.windDirection,
    required this.windSpeed,
    required this.rawMetar,
    required this.altimeterInHg,
  });

  factory Metar.fromJson(List<dynamic> jsonMap) {
    if (jsonMap[0]['wdir'] == 'VRB') {
      jsonMap[0]['wdir'] = null;
    }

    // In the rare case the altimeter setting is received in Inches of Mercury already, the conversion will not be
    // be performed unless the altimeter setting is in millibars.
    final altimeterInMillibars = RegExp(r'^\d{3,4}'); // to check the altimeter setting is millibar.
    if (altimeterInMillibars.hasMatch(jsonMap[0]['altim'].toString())) {
      final altimeter = jsonMap[0]['altim'];
      jsonMap[0]['altim'] = num.tryParse(altimeter.toString())! / 33.864;
    }

    return Metar(
        temperature: jsonMap[0]['temp'] as num?,
        dewpoint: jsonMap[0]['dewp'] as num?,
        windDirection: jsonMap[0]['wdir'] as num?,
        windSpeed: jsonMap[0]['wspd'] as num?,
        altimeterInHg: jsonMap[0]['altim'] as num?,
        rawMetar: jsonMap[0]['rawOb'] as String?
    );
  }

  num? temperature;
  num? dewpoint;
  num? windDirection;
  num? windSpeed;
  num? altimeterInHg;
  String? rawMetar;

  @override
  String toString() {
    return
      'Temperature: $temperature\n'
      'Dewpoint: $dewpoint\n'
      'Wind Direction: $windDirection\n'
      'Wind Speed: $windSpeed\n'
      'Altimeter: $altimeterInHg\n'
      'METAR: $rawMetar';
  }
}
