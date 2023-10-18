import 'dart:math';

import 'package:flight_e6b/communication_var.dart' as comm;

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

int? cloudBase(double? temp, double? dew) {
  if (temp == null || dew == null) {
    return null;
  }

  final spread = temp - dew;
  final base = (spread / 2.5) * 1000;
  return base.round();
}

int? pressureAlt(double? indicatedAlt, double? stationInch) {
  if (indicatedAlt == null || stationInch == null) {
    return null;
  }

  // Pressure in Millibars
  final stationMill = stationInch * 33.8639;
  final pressDiff = (1 - pow(stationMill / 1013.25, 0.190284)) * 145366.45;
  final calPressAlt = indicatedAlt + (pressDiff);

  return calPressAlt.round();
}

int? densityAlt({required double? tempC, required double? stationInches, required double? dewC, required double? elevation}) {
  if (tempC == null || stationInches == null || dewC == null || elevation == null) {
    return null;
  }
  final vaporPress = _saturationVapor(tempC: dewC); // Converting Celsius to Kelvin
  final humidity = vaporPress / _saturationVapor(tempC: tempC) * 100; // Relative humidity
  final pressInMb = _mbPressure(altimeterIn: stationInches, stationElevation: elevation); // Pressure in millibars at a certain altitude.
  final density = _airDensity(pressMb: pressInMb, tempC: tempC, relativeHumidity: humidity); // Air density at the input elevation

  // Density Altitude in kilometers and the altitude is geo potential.
  final calDensityKm = 44.3308 - (42.2665 * (pow(density, 0.234969))); // In km
  if (calDensityKm.isNaN) {
    comm.error = 'Invalid Result. Try different values';
    return null;
  }

  // Converting altitude in feet and into geo metric altitude
  final calDensityFt = _geometricAlt(calDensityKm) * 3280.84; // In ft

  return calDensityFt.round();
}

int? groundSpeed({required double? trueAirspeed, required double? windDirection, required double? windSpeed, required double? course, required double? corrAngle}) {
  if (trueAirspeed == null || windDirection == null || windSpeed == null || course == null || corrAngle == null) {
    return null;
  }

  final courseRadians = course * (pi / 180);
  final corrAngleRadians = corrAngle * (pi / 180);
  final windDirectionRadians = windDirection * (pi / 180);

  final calCos = cos(courseRadians - windDirectionRadians + corrAngleRadians); // in degrees

  final formulaPart1 = pow(trueAirspeed, 2) + pow(windSpeed, 2);
  final formulaPart2 = (2 * trueAirspeed * windSpeed * calCos);

  return sqrt(formulaPart1 - formulaPart2).round();
}

int? trueAirspeed({required double? calibratedAirS, required double? pressAltitude, required double? tempC}) {
  if (calibratedAirS == null || pressAltitude == null || tempC == null) {
    return null;
  }

  final mbPressAtAlt = _pressAtAltitude(pressAltitude, tempC);

  final seaLevelDensity = _airDensity(pressMb: 1013.25, tempC: 15); // Air density at sea level in kg/m^3.
  final altitudeDensity = _airDensity(pressMb: mbPressAtAlt, tempC: tempC); // Air density at a certain altitude in kg/m^3.

  final tas = calibratedAirS * (sqrt(seaLevelDensity / altitudeDensity));

  if (tas.isNaN) {
    comm.error = 'Invalid Result. Try different values';
    return null;
  }

  return tas.round();
}

double? crossWindComp({required double? direction, required double? windDirection, required double? windSpeed}) {
  if (direction == null || windDirection == null || windSpeed == null) {
    return null;
  }

  final double angularDiff = windDirection - (direction * 10);

  final radians = angularDiff * (pi / 180);

  return windSpeed * (sin(radians));
}

double? headWindComp({required double? direction, required double? windDirection, required double? windSpeed}) {
  if (direction == null || windDirection == null || windSpeed == null) {
    return null;
  }

  final double angularDiff = windDirection - (direction * 10);

  final radians = angularDiff * (pi / 180);

  return windSpeed * (cos(radians));
}

double? correctionAngle({
  required double? trueCourse,
  required double? windDirection,
  required double? windSpeed,
  required double? trueAirspeed}
    ) {

  if (trueCourse == null || windDirection == null || windSpeed == null || trueAirspeed == null) {
    return null;
  }

  // The angle between the wind direction and the desired course
  final windAngle = trueCourse - (180 + windDirection);
  // Wind angle in radians
  final windAngleRadians = windAngle * (pi / 180);

  final forTheInverseSin = (sin(windAngleRadians) * windSpeed) / trueAirspeed;
  // The result is in radians
  final calWindCorrAngle = asin(forTheInverseSin);

  if (calWindCorrAngle.isNaN) {
    comm.error = 'Invalid Values';
    return null;
  }

  // Returning wind correction angle in degrees
  return calWindCorrAngle * (180 / pi);
}

int? heading(double? trueCourse, double? windCorrectionAngle) {
  if (trueCourse == null || windCorrectionAngle == null) {
    return null;
  }

  // To make sure true heading is not equal to more than 360.
  var trueHeading = trueCourse + windCorrectionAngle;
  if (trueHeading > 360) {
    trueHeading -= 360;
  }

  return trueHeading.round();
}

double _saturationVapor({required double tempC}) {
  // Returns saturation vapor pressure in Pascals
  // Private function to calculate the partial vapor pressure
  const eso = 6.1078;
  const c0 = 0.99999683;
  const c1 = -0.90826951 * 1e-2;
  const c2 = 0.78736169 * 1e-4;
  const c3 = -0.61117958 * 1e-6;
  const c4 = 0.43884187 * 1e-8;
  const c5 = -0.29883885 * 1e-10;
  const c6 = 0.21874425 * 1e-12;
  const c7 = -0.17892321 * 1e-14;
  const c8 = 0.11112018 * 1e-16;
  const c9 = -0.30994571 * 1e-19;

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
