import 'dart:math';
import 'package:flight_e6b/simple_io.dart';

String windsInterpolation({
  required int altOne,
  required int altTwo,
  required int altOneDir,
  required int altOneSpeed,
  required int altTwoDir,
  required int altTwoSpeed,
  required int interAlt
}) {
  final altDiff = (altTwo - altOne) / 1000;
  final dirDiff = altOneDir - altTwoDir;

  final int speedDiff;
  if (altOneSpeed < altTwoSpeed) {
    speedDiff = altTwoSpeed - altOneSpeed;
  } else {
    speedDiff = altOneSpeed - altTwoSpeed;
  }

  final interAltDiff = interAlt - altOne;

  final degreeChange = dirDiff / altDiff;
  final speedChange = (speedDiff / altDiff) * (interAltDiff / 1000);
  final windDir = altOneDir - (degreeChange * (interAltDiff / 1000));

  final double windSpeed;
  if (altOneSpeed < speedChange) {
    windSpeed = speedChange - altOneSpeed;
  } else {
    windSpeed = altOneSpeed - speedChange;
  }

  return '${interAlt}Ft: ${windDir.toStringAsFixed(1)} at ${windSpeed.toStringAsFixed(1)}KT';
}

int cloudBase(double temp, double dew) {
  final spread = temp - dew;
  final base = (spread / 2.5) * 1000;
  return base.round();
}

int pressureAlt(double indicatedAlt, double stationInch) {
  // Pressure in Millibars
  final stationMill = stationInch * 33.8639;
  final pressDiff = (1 - pow(stationMill / 1013.25, 0.190284)) * 145366.45;
  final calPressAlt = indicatedAlt + (pressDiff);

  return calPressAlt.round();
}

int densityAlt({required double tempC, required double stationInches, required double dewC, required double elevation}) {
  final vaporPress = _saturationVapor(tempC: dewC); // Converting Celsius to Kelvin
  final humidity = vaporPress / _saturationVapor(tempC: tempC) * 100; // Relative humidity
  final pressInMb = _mbPressure(altimeterIn: stationInches, stationElevation: elevation); // Pressure in millibars at a certain altitude.
  final density = _airDensity(pressMb: pressInMb, tempC: tempC, relativeHumidity: humidity); // Air density at the input elevation

  // Density Altitude in kilometers and the altitude is geo potential.
  final calDensityKm = 44.3308 - (42.2665 * (pow(density, 0.234969))); // In km

  // Converting altitude in feet and into geo metric altitude
  final calDensityFt = _geometricAlt(calDensityKm) * 3280.84; // In ft

  return calDensityFt.round();
}

int groundSpeed(double distanceNM, double timeHr) {
  // Ground Speed knots
  return (distanceNM / timeHr).round();
}

int trueAirspeed({required double calibratedAirS, required double pressAltitude, required double tempC}) {
  final mbPressAtAlt = _pressAtAltitude(pressAltitude, tempC);

  final seaLevelDensity = _airDensity(pressMb: 1013.25, tempC: 15); // Air density at sea level in kg/m^3.
  final altitudeDensity = _airDensity(pressMb: mbPressAtAlt, tempC: tempC); // Air density at a certain altitude in kg/m^3.

  final tas = calibratedAirS * (sqrt(seaLevelDensity / altitudeDensity));

  return tas.round();
}

Map<String, double> windComponent({required double direction, required double windDirection, required double windSpeed, bool runway = false}) {
  // Converting degrees into radians.
  final double angularDiff;

  if (runway) {
    angularDiff = windDirection - (direction * 10);
  } else {
    angularDiff = windDirection - direction;
  }

  final radians = angularDiff * (pi / 180);
  final Map<String, double> result = {};

  result['crossWind'] = windSpeed * (sin(radians));
  result['headWind'] = windSpeed * (cos(radians));

  return result;
}

double correctionAngle({
  required double trueCourse,
  required double windDirection,
  required double windSpeed,
  required double trueAirspeed}
    ) {

  // The angle between the wind direction and the desired course
  final windAngle = trueCourse - (180 + windDirection);
  // Wind angle in radians
  final windAngleRadians = windAngle * (pi / 180);

  final forTheInverseSin = windSpeed / trueAirspeed * (sin(windAngleRadians));
  // The result is in radians
  final calWindCorrAngle = asin(forTheInverseSin);

  // Returning wind correction angle in degrees
  return calWindCorrAngle * (180 / pi);
}

int windDirectionChecker() {
  var windDirection = doubleParse('Wind Direction: ', ifInvalid: 'Invalid wind direction\n');
  while (windDirection > 360 || windDirection < 0) {
    if (windDirection > 360) {
      print('Wind direction must be between 0-360\n');
    } else if (windDirection < 0) {
      print('Wind direction must be positive\n');
    }

    windDirection = doubleParse('Wind Direction: ', ifInvalid: 'Invalid wind direction\n');
  }

  return windDirection.round();
}

double windSpeedChecker() {
  var windSpeedKt = doubleParse('Wind Speed (kt): ', ifInvalid: 'Invalid wind speed\n');
  while (windSpeedKt < 0) {
    print('Wind speed must be positive\n');
    windSpeedKt = doubleParse('Wind Speed (kt): ', ifInvalid: 'Invalid wind speed\n');
  }

  return windSpeedKt;
}

int trueCourseChecker() {
  var trueCourse = doubleParse('True Course: ', ifInvalid: 'Invalid True Course');
  while (trueCourse > 360 || trueCourse < 0) {
    if (trueCourse > 360) {
      print('True course must be between 0-360\n');
    } else if (trueCourse < 0) {
      print('True course must be positive\n');
    }
    trueCourse = doubleParse('True Course: ', ifInvalid: 'Invalid True Course');
  }

  return trueCourse.round();
}

double _saturationVapor({required double tempC}) {
  // Returns saturation vapor pressure in Pascals
  // Private function to calculate the partial vapor pressure
  const double eso = 6.1078;
  const double c0 = 0.99999683;
  const double c1 = -0.90826951 * 1e-2;
  const double c2 = 0.78736169 * 1e-4;
  const double c3 = -0.61117958 * 1e-6;
  const double c4 = 0.43884187 * 1e-8;
  const double c5 = -0.29883885 * 1e-10;
  const double c6 = 0.21874425 * 1e-12;
  const double c7 = -0.17892321 * 1e-14;
  const double c8 = 0.11112018 * 1e-16;
  const double c9 = -0.30994571 * 1e-19;

  final p =
      c0 + tempC *
          (c1 + tempC *
              (c2 + tempC *
                  (c3 + tempC *
                      (c4 + tempC *
                          (c5 + tempC *
                              (c6 + tempC *
                                  (c7 + tempC *
                                      (c8 + tempC * c9))))))));

  final saturationVaporPress = eso / (pow(p, 8));
  return saturationVaporPress * 100;
}

double _geometricAlt(double geoPotentialKm) {
  // Geo potential altitude must be in kilometers

  const earthRadius = 6356.766; // in kilometers

  final geoMetricAlt = (earthRadius * geoPotentialKm) / (earthRadius - geoPotentialKm); // In kilometers
  return geoMetricAlt;
}

double _airDensity({required double pressMb, required double tempC, double relativeHumidity = 0}) {
  // Air density in kg/m^3.
  const gasConstDry = 287.05; // J/(kg*degK)
  const gasConstMoist = 461.495; // J/(kg*degK)

  final pascalsPress = pressMb * 100;
  final vaporPress = (relativeHumidity * _saturationVapor(tempC: tempC)) / 100;
  final dryAirPress = pascalsPress - vaporPress; // In Pascals
  final kelvinTemp = tempC + 273.15;

  final density = (dryAirPress / (gasConstDry * kelvinTemp)) + (vaporPress / (gasConstMoist * kelvinTemp));

  return density;
}

double _mbPressure({required double altimeterIn, required double stationElevation}) {
  /// This function determines the pressure in millibars at a specific elevation
  final altimeterMb = altimeterIn *  33.864;
  final aS = pow(altimeterMb, 0.190263) as double;
  final body = 8.417286 * 1e-5 * (stationElevation / 3.281);

  final result = pow(aS - body, 1 / 0.190263) as double;

  return result;
}

double _pressAtAltitude(double altitudeFT, double tempC) {
  // Function returns atmospheric pressure in Millibars

  // Constants for the formula
  const lapseRate = 0.0065; // C/meter
  const gravity = 9.8; // meters/seconds
  const molar = 0.0285; // Molar mass kg/mol
  const gasConst = 8.315; // J/(mol * k)
  const oneAtmosphere = 1; // atm

  final altitudeM = altitudeFT / 3.28; // altitude in meters
  final tempK = tempC + 273.16; // Temperature in Kelvin

  final exponent = (gravity * molar) / (gasConst * lapseRate);
  final body = (lapseRate * altitudeM) / tempK;
  final atmosphericPress = oneAtmosphere * (pow(1 - body, exponent));

  return atmosphericPress * 1013.25;
}
