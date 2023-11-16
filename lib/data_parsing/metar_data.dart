import 'package:flight_e6b/communication_var.dart' as comm;

class Metar {
  Metar({
    required this.temp,
    required this.dew,
    required this.windDirection,
    required this.windSpeed,
    required this.rawMetar,
    required this.altimeter,
  });

  num? temp;
  num? dew;
  num? windDirection;
  num? windSpeed;
  num? altimeter;
  String? rawMetar;

  num? get temperature {
    if (comm.fahrenheitTrue && temp != null) return (temp! * 9/5) + 32;

    return temp;
  }

  num? get dewpoint {
    if (comm.fahrenheitTrue && dew != null) return (dew! * 9/5) + 32;

    return dew;
  }

  num? get altimeterInHg {
    if (comm.inchesMercuryTrue && altimeter != null) return altimeter! / 33.8639;

    return altimeter;
  }

  factory Metar.fromJson(List<dynamic>? jsonMap) {
    if (jsonMap?.isEmpty ?? true) {
      return Metar(
          temp: null,
          dew: null,
          windDirection: null,
          windSpeed: null,
          altimeter: null,
          rawMetar: null,
      );
    }

    if (jsonMap?[0]?['wdir'] == 'VRB') {
      jsonMap?[0]['wdir'] = null;
    }

    return Metar(
        temp: jsonMap?[0]['temp'] as num?,
        dew: jsonMap?[0]['dewp'] as num?,
        windDirection: jsonMap?[0]['wdir'] as num?,
        windSpeed: jsonMap?[0]['wspd'] as num?,
        altimeter: jsonMap?[0]['altim'] as num?,
        rawMetar: jsonMap?[0]['rawOb'] as String?
    );
  }

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
