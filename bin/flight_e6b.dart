import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/simple_io.dart';

void main(List<String> arguments) {
  // If more options are added, remember to increase the condition in the while statement (option > x) inside
  // the optionChecker function to check for out of range selections.

  const menu =
      '**** Flight Computer (E6B) ****\n'
      '1. Cloud Base (ft)\n'
      '2. Pressure/Density Altitude (ft)\n'
      '3. Ground Speed (GS)\n'
      '4. True Airspeed (TAS)\n'
      '5. Wind Component\n'
      '6. Wind Correction\n'
      '------------------------\n'
      '7. Fuel';

  while (true) {
    print(menu);
    // Check for the option
    var userOption = optionChecker();
    // Just for newline
    print('');

    // optionChecker returns null when the user types 'exit' while in the menu.
    if (userOption == null) {
      print('Bye!');
      break;
    }

    switch (userOption) {
      case 1:
        optionOne();
        break;
      case 2:
        optionTwo();
        break;
      case 3:
        optionThree();
        break;
      case 4:
        optionFour();
        break;
      case 5:
        optionFive();
        break;
      case 6:
        optionSix();
        break;
      case 7:
        print('Not available yet. Coming soon:)');
        break;
    }
    // Just for newline
    print('');
  }
}

// This Map will take the calculated data for reuse in other options.
Map<String, num> dataResult = {};

int? optionChecker() {
  String userInput = input(': ') ?? '';

  // If the user types 'exit' while in the menu, the app closes.
  if (userInput.toLowerCase() == 'exit') {
    return null;
  }

  int? option = int.tryParse(userInput);
  // If more options are added, remember to increase the condition in the while statement (option > x)
  // to check for out of range selection
  while (option == null || option < 1 || option > 7) {
    if (option == null) {
      print('Enter a valid option');
      option = intParse(': ');
      continue;
    } else if (option < 1 || option > 7) {
      print('Choose an option between 1-7');
      option = intParse(': ');
      continue;
    }
  }

  return option;
}

// 1. Cloud Base (ft)
void optionOne() {
  print('**** Cloud Base ****');

  // Getting temperature
  var temperature = doubleParse('Temperature (c): ', ifInvalid: 'Invalid Temperature\n');
  // Getting dew point
  var dewpoint = doubleParse('Dew Point (c): ', ifInvalid: 'Invalid Dew Point\n');
  while (dewpoint > temperature) {
    print('Dew Point must be less than or equal to temperature.\n');
    dewpoint = doubleParse('Dew Point (c): ', ifInvalid: 'Invalid Dew Point\n');
  }

  final result = cloudBase(temperature, dewpoint);
  beautifulPrint('Cloud Base: ${result}ft');
}

// 2. Pressure/Density Altitude (ft)
void optionTwo() {
  print('**** Pressure/Density Altitude ****');

  // Getting pressure altitude
  //
  var indicatedAlt = doubleParse('Indicated Altitude (ft): ', ifInvalid: 'Invalid Altitude\n' );
  while (indicatedAlt < 0) {
    print('Altitude must be positive');
    indicatedAlt = doubleParse('Indicated Altitude (ft): ', ifInvalid: 'Invalid Altitude\n');
  }

  var pressInHg = doubleParse('Baro (In Hg): ', ifInvalid: 'Invalid Pressure\n');
  while (pressInHg < 0) {
    print('Pressure must positive');
    pressInHg = doubleParse('Baro (In Hg): ', ifInvalid: 'Invalid Pressure\n');
  }

  final pressure = pressureAlt(indicatedAlt, pressInHg);
  // Sending calculated pressure altitude to the calData Map.
  dataResult['pressureAlt'] = pressure;
  beautifulPrint('Pressure Altitude: ${pressure}ft');

  // Getting density altitude
  //
  var tempC = doubleParse('Temperature (c): ', ifInvalid: 'Invalid Temperature\n');

  // Sending the input temperature to the calData Map
  dataResult['tempC'] = tempC;

  var dewC = doubleParse('Dew Point (c): ', ifInvalid: 'Invalid Dew Point\n');
  while (dewC > tempC) {
    print('Dew Point must be less than or equal to temperature.\n');
    dewC = doubleParse('Dew Point (c): ', ifInvalid: 'Invalid Dew Point\n');
  }

  final density = densityAlt(
      tempC: tempC,
      stationInches: pressInHg,
      dewC: dewC,
      elevation: indicatedAlt
  );
  // Sending calculated density altitude to the calData Map.
  dataResult['densityAlt'] = density;
  beautifulPrint('Density Altitude: ${density}ft');
}

// 3. Ground Speed (GS)
void optionThree() {
  print('**** Ground Speed ****');

  var distanceNM = doubleParse('Distance (NM): ', ifInvalid: 'Invalid Distance\n');
  while (distanceNM < 0) {
    print('Distance must be positive');
    distanceNM = doubleParse('Distance (NM): ', ifInvalid: 'Invalid Distance\n');
  }

  var timeHr = doubleParse('Time (HR): ', ifInvalid: 'Invalid Time. Ex. 1.5.\n');

  final calGroundSpeed = (distanceNM / timeHr).round();
  dataResult['groundSpeed'] = calGroundSpeed;

  beautifulPrint('Ground Speed: ${calGroundSpeed}KT');
}

// True Airspeed (TAS)
void optionFour() {
  print('**** True Airspeed ****');

  var calibratedAirS = intParse('Calibrated Airspeed: ', ifInvalid: 'Invalid CAS');
  while (calibratedAirS < 0) {
    print('Calibrated Airspeed must be positive');
    calibratedAirS = intParse('Calibrated Airspeed: ', ifInvalid: 'Invalid CAS');
  }

  int? pressAlt;
  // If the pressure altitude was calculated from option 2, it is automatically input.
  if (dataResult.containsKey('pressureAlt')) {
    pressAlt = dataResult['pressureAlt'] as int;
    print('Pressure Altitude (auto): ${pressAlt}ft');
  } else {
    pressAlt = intParse('Pressure Altitude (ft): ');
    while (pressAlt == null || pressAlt < 0) {
      print('Invalid Pressure Altitude');
      pressAlt = intParse('Pressure Altitude (ft): ');
    }
  }

  double? tempC;
  // If the temperature was already input from option 2, it is automatically input.
  if (dataResult.containsKey('tempC')) {
    tempC = dataResult['tempC'] as double;
    print('Temperature (c) (auto): ${tempC.round()}C');
  } else {
    tempC = doubleParse('Temperature (c): ', ifInvalid: 'Invalid Temperature\n');
  }

  final calTrueAirspeed = trueAirspeed(
      calibratedAirS: calibratedAirS.toDouble(),
      pressAltitude: pressAlt.toDouble(),
      tempC: tempC
  );
  // Sending calculated true airspeed to dataResult Map.
  dataResult['trueAirspeed'] = calTrueAirspeed;

  beautifulPrint('True Airspeed: ${calTrueAirspeed}kt');

}

// 5. Wind Component
void optionFive() {
  print('**** Wind Component ****');

  final windDirection = windDirectionChecker();

  final windSpeedKt = windSpeedChecker();

  // Runway should be the actual number and not the magnetic heading. ex. RWY24
  var runway = doubleParse('Runway: ', ifInvalid: 'Invalid runway\n');
  while (runway > 36 || runway < 0) {
    if (runway > 36) {
      print('Runway number must be between 0-36\n');
    } else if (runway < 0) {
      print('Runway number must be positive\n');
    }

    runway = doubleParse('Runway: ', ifInvalid: 'Invalid runway\n');
  }

  final result = windComponent(windDirection: windDirection.toDouble(), windSpeed: windSpeedKt, direction: runway);

  final crossWindComp =  result['crossWind']!;
  final headTailComp = result['headWind']!;

  // To construct the final string.
  final totalString = StringBuffer();
  if (crossWindComp < 0) {
    totalString.write('Left X Wind: ${crossWindComp.abs().toStringAsFixed(2)}kt\n');
  } else {
    totalString.write('Right X Wind: ${crossWindComp.toStringAsFixed(2)}kt\n');
  }

  if (headTailComp < 0) {
    totalString.write('Tailwind: ${headTailComp.abs().toStringAsFixed(2)}kt');
  } else {
    totalString.write('Headwind: ${headTailComp.toStringAsFixed(2)}kt');
  }

  beautifulPrint(totalString);
}

// 6. Wind Correction
void optionSix() {
  print('**** Wind Correction ****');

  final trueCourse = trueCourseChecker();
  final windDirection = windDirectionChecker();
  final windSpeed = windSpeedChecker();
  int trueAirspeedTAS;

  // If true airspeed was calculated in option 4, it is automatically input.
  if (dataResult.containsKey('trueAirspeed')) {
    trueAirspeedTAS = dataResult['trueAirspeed'] as int;
    print('True airspeed (auto): ${trueAirspeedTAS}kt');
  } else {
    trueAirspeedTAS = intParse('True Airspeed (kt): ', ifInvalid: 'Invalid True Airspeed');
    while (trueAirspeedTAS < 0) {
      print('True Airspeed must be positive');
      trueAirspeedTAS = intParse('True Airspeed (kt): ', ifInvalid: 'Invalid True Airspeed');
    }
  }

  final windCorrectionAngle = correctionAngle(
      trueCourse: trueCourse.toDouble(),
      windDirection: windDirection.toDouble(),
      windSpeed: windSpeed,
      trueAirspeed: trueAirspeedTAS.toDouble()
  )?.round();

  var trueHeading = trueCourse + windCorrectionAngle!;
  if (trueHeading > 360) {
    trueHeading -= 360;
  }
  // Sending True Heading to dataResult Map
  dataResult['trueHeading'] = trueHeading;

  beautifulPrint(
    'True Heading (THdg): $trueHeading \n'
    'Wind Correction Angle (WCA): $windCorrectionAngle'
  );

}