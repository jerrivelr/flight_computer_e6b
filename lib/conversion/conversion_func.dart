import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

double temperatureConv({required Conversion inputUnit, required num temp}) {
  comm.updateYamlFile();

  switch (inputUnit) {
    case Conversion.celsius:
      if (comm.celsiusTrue) {
        return temp.toDouble();
      }

      // celsius conversion
      return (temp - 32) * 5/9;
    case Conversion.fahrenheit:
      if (comm.fahrenheitTrue) {
        return temp.toDouble();
      }

      // fahrenheit conversion
      return  (temp * 9/5) + 32;
    default:
      return temp.toDouble();
  }
}

double altitudeConv({required Conversion inputUnit, required num alt, bool convResult = false} ) {
  comm.updateYamlFile();

  switch (inputUnit) {
    case Conversion.feet:
      if (comm.feetTrue) {
        return alt.toDouble();
      } else if (convResult) {
        // Feet to meters
        return alt * 0.3048;
      }

      // Meters to feet
      return alt * 3.28084;
    case Conversion.meters:
      if (comm.metersTrue) {
        return alt.toDouble();
      } else if (convResult) {
        // Meters to feet
        return alt * 3.28084;
      }

      // Feet to meters
      return alt * 0.3048;
    default:
      return alt.toDouble();
  }
}

double pressConv({required Conversion inputUnit, required double pressUnit}) {
  comm.updateYamlFile();

  switch (inputUnit) {
    case Conversion.inchesMercury:
      if (comm.inchesMercuryTrue) {
        return pressUnit;
      }

      // MB to InHg
      return pressUnit / 0.02953;
    case Conversion.millibars:
      if (comm.millibarsTrue) {
        return pressUnit;
      }

      // InHg to MB
      return pressUnit * 33.8639;
    default:
      return pressUnit;
  }
}

double speedConvKnt({required double speed, bool convResult = false}) {
  comm.updateYamlFile();

  if (comm.kilometerHoursTrue) {
    // Knots to KMH
    if (convResult) return speed * 1.852;

    // KMH to knots
    return speed / 1.852;
  } else if (comm.milesHoursTrue) {
    // Knots to MPH
    if (convResult) return speed * 1.15078;

    // MPH to knots
    return speed / 1.15078;
  }

  return speed;
}

double distanceConvNm({required double distance, bool convResult = false}) {
  comm.updateYamlFile();

  if (comm.disFeetTrue) {
    // nautical mile to feet
    if (convResult) return distance * 6076.11549;

    // feet to nautical mile
    return distance / 6076;
  } else if (comm.disKilometerTrue) {
    // nautical mile to kilometer
    if (convResult) return distance * 1.852;

    // kilometer to nautical mile
    return distance / 1.852;
  } else if (comm.disMetersTrue) {
    // nautical mile to meter
    if (convResult) return distance * 1852;

    // meters to nautical mile
    return distance / 1852;
  }

  return distance;
}

double timeConvHr({required double time, bool convResult = false}) {
  comm.updateYamlFile();

  if (comm.minuteTrue) {
    // hours to minute
    if (convResult) return time * 60;

    // minute to hours
    return time / 60;
  } else if (comm.secondTrue) {
    // hours to seconds
    if (convResult) return time * 3600;

    // seconds to hours
    return time / 3600;
  }

  return time;
}

double fuelWeightConv(double fuelVolume) {
  comm.updateYamlFile();

  fuelVolume = _fuelVolGal(fuelVolume); // fuel volume always in gallons

  if (comm.kilogramsTrue) {
    // fuel weight in kg
    final fuelDensityKg = _fuelDensityIbs() / 2.205;
    return fuelVolume * fuelDensityKg;
  }

  // fuel weight in ibs
  return fuelVolume * _fuelDensityIbs();
}

double _fuelVolGal(double fuel) {
  comm.updateYamlFile();

  if (comm.fuelPoundTrue) {
    // Ibs to Gal
    return fuel / _fuelDensityIbs();
  } else if (comm.fuelLiterTrue) {
    // L to Gal
    return fuel / 3.785;
  }

  return fuel;
}

double _fuelDensityIbs() {
  comm.updateYamlFile();

  if (comm.jetA) {
    return 6.75; // Jet A fuel in ibs
  } else if (comm.jetB) {
    return 6.5; // Jet B fuel in ibs
  }

  return 6; // AvGas in ibs
}