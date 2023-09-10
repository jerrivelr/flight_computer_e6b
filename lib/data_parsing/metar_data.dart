class Metar {
  Metar({
    required this.temperature,
    required this.dewpoint,
    required this.windDirection,
    required this.windSpeed,
    required this.rawMetar,
    required num? altimeter,
  })
      : _altimeter = (altimeter != null) ? altimeter / 33.864 : null;

  factory Metar.fromJson(List<dynamic> jsonMap) {
    if (jsonMap[0]['wdir'] == 'VRB') {
      jsonMap[0]['wdir'] = null;
    }

    return Metar(
        temperature: jsonMap[0]['temp'] as num?,
        dewpoint: jsonMap[0]['dewp'] as num?,
        windDirection: jsonMap[0]['wdir'] as num?,
        windSpeed: jsonMap[0]['wspd'] as num?,
        altimeter: jsonMap[0]['altim'] as num?,
        rawMetar: jsonMap[0]['rawOb'] as String
    );
  }

  final num? temperature;
  final num? dewpoint;
  final num? windDirection;
  final num? windSpeed;
  final String rawMetar;
  num? _altimeter;

  num get altimeterInHg => _altimeter ?? 0;



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
