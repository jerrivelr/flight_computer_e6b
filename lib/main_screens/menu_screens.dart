import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/menu_logic.dart';

// Used for creating the screens.
final console = Console();

String? mainMenu() {
  const options =
      '(1) —— Cloud Base (ft)\n'
      '(2) —— Pressure/Density Altitude (ft)\n'
      '(3) —— Ground Speed (GS)\n'
      '(4) —— True Airspeed (TAS)\n'
      '(5) —— Wind Component\n'
      '(6) —— Heading/Wind Correction Angle (WCA)\n'
      '(7) —— Fuel';

  final optionList = MenuLogic.optionList.getRange(1, 9).toList();
  return optionMenu(
      title: 'FLIGHT COMPUTER (E6B)',
      options: options,
      startRange: 1,
      endRange: 7,
      optionList: optionList
  );
}

String? cloudBaseScreen() {
  double? temperature;
  double? dewpoint;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final tempInput = MenuLogic.screenType(InputType.temperature, temperature);
    final dewInput = MenuLogic.screenType(InputType.dewpoint, dewpoint);

    MenuLogic.screenHeader(title: 'CLOUD BASE 🌧️');

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (MenuLogic.repeatLoop(temperature)) continue;

    // Getting dewpoint.
    dewpoint = dewInput.optionLogic();
    if (MenuLogic.repeatLoop(dewpoint)) {
      continue;
    } else if (dewpoint! > temperature!) {
      MenuLogic.error = 'Dewpoint must be less than or equal to temperature';
      dewpoint = null;
      console.clearScreen();
      continue;
    }

    // temperature and dewpoint will never be null at this point.
    final result = cloudBase(temperature, dewpoint);
    resultPrinter(['Cloud Base: ${MenuLogic.formatNumber(result)}ft']);

    // Asking user weather to make a new calculation or back to menu.
    if (!MenuLogic.backToMenu()) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      temperature = null;
      dewpoint = null;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? pressDensityScreen() {
  double? indicatedAlt;
  double? pressInHg;
  double? temperature;
  double? dewpoint;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final indicatedAltInput = MenuLogic.screenType(InputType.indicatedAlt, indicatedAlt);
    final pressInHgInput = MenuLogic.screenType(InputType.baro, pressInHg);
    final tempInput = MenuLogic.screenType(InputType.temperature, temperature);
    final dewInput = MenuLogic.screenType(InputType.dewpoint, dewpoint);

    MenuLogic.screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');

    // Getting indicated altitude
    indicatedAlt = indicatedAltInput.optionLogic();
    if (MenuLogic.repeatLoop(indicatedAlt)) continue;

    // Getting altimeter setting
    pressInHg = pressInHgInput.optionLogic();
    if (MenuLogic.repeatLoop(pressInHg)) continue;

    // Calculated pressure altitude.
    final pressure = pressureAlt(indicatedAlt!, pressInHg!);

    // Sending calculated pressure altitude to the dataResult Map.
    MenuLogic.dataResult['pressureAlt'] = pressure.toDouble();
    resultPrinter(['Pressure Altitude: ${MenuLogic.formatNumber(pressure)}ft']);

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (MenuLogic.repeatLoop(temperature)) continue;

    MenuLogic.dataResult['temperature'] = temperature!;

    // Getting dewpoint.
    dewpoint = dewInput.optionLogic();
    if (MenuLogic.repeatLoop(dewpoint)) {
      continue;
    } else if (dewpoint! > temperature) {
      MenuLogic.error = 'Dewpoint must be less than or equal to temperature';
      dewpoint = null;
      console.clearScreen();
      continue;
    }

    final density = densityAlt(
        tempC: temperature,
        stationInches: pressInHg,
        dewC: dewpoint,
        elevation: indicatedAlt
    );

  // Sending calculated pressure altitude to the dataResult Map.
  MenuLogic.dataResult['densityAlt'] = density;
  resultPrinter(['Density Altitude: ${MenuLogic.formatNumber(density)}ft']);

    // Asking user weather to make a new calculation or back to menu.
    if (!MenuLogic.backToMenu()) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      indicatedAlt = null;
      pressInHg = null;
      temperature = null;
      dewpoint = null;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? groundSpeedScreen() {
  double? distanceNm;
  double? timeHr;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final distanceInput = MenuLogic.screenType(InputType.distance, distanceNm);
    final timeInput = MenuLogic.screenType(InputType.time, timeHr);

    MenuLogic.screenHeader(title: 'GROUND SPEED (kt)');

    // Getting distance
    distanceNm = distanceInput.optionLogic();
    if (MenuLogic.repeatLoop(distanceNm)) continue;

    // Getting time in hours
    timeHr = timeInput.optionLogic();
    if (MenuLogic.repeatLoop(timeHr)) continue;

    final calGroundSpeed = groundSpeed(distanceNm!, timeHr!);
    MenuLogic.dataResult['groundSpeed'] = calGroundSpeed;

    resultPrinter(['Ground Speed: ${MenuLogic.formatNumber(calGroundSpeed)}kt']);

    // Asking user weather to make a new calculation or back to menu.
    if (!MenuLogic.backToMenu()) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      distanceNm = null;
      timeHr = null;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? trueAirspeedScreen() {
  double? calibratedAir;
  double? pressAltitude;
  double? temperature;

  bool pressCheck = MenuLogic.dataResult.containsKey('pressureAlt');
  bool tempCheck = MenuLogic.dataResult.containsKey('temperature');

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final calibratedInput = MenuLogic.screenType(InputType.calibratedAir, calibratedAir);
    final pressAltInput = MenuLogic.screenType(InputType.pressureAlt, pressAltitude);
    final tempInput = MenuLogic.screenType(InputType.temperature, temperature);

    MenuLogic.screenHeader(title: 'TRUE AIRSPEED (kt)');

    // If pressure altitude or temperature was input from option 2, the user is ask weather or not they want to autofill.
    if (pressCheck || tempCheck) {
      console.setTextStyle(italic: true);
      console.writeLine(MenuLogic.inputNames['autofill']);
      MenuLogic.userInput = input(': ')?.toLowerCase();

      if (MenuLogic.userInput == 'y' || MenuLogic.userInput == 'yes') {
        pressAltitude = (pressCheck) ? MenuLogic.dataResult['pressureAlt']?.toDouble() : null;
        temperature = (tempCheck) ? MenuLogic.dataResult['temperature']?.toDouble() : null;
      }

      console.clearScreen();
      pressCheck = false;
      tempCheck = false;

      continue;
    }

    // Getting Calibrated airspeed.
    calibratedAir = calibratedInput.optionLogic();
    if (MenuLogic.repeatLoop(calibratedAir)) continue;

    // Getting pressure altitude.
    pressAltitude = pressAltInput.optionLogic();
    if (MenuLogic.repeatLoop(pressAltitude)) continue;

    MenuLogic.dataResult['pressureAlt'] = pressAltitude!;

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (MenuLogic.repeatLoop(temperature)) continue;


    MenuLogic.dataResult['temperature'] = temperature!;

    final calTrueAirspeed = trueAirspeed(
        calibratedAirS: calibratedAir!,
        pressAltitude: pressAltitude,
        tempC: temperature
    );

    // Sending true airspeed result to dateResult map for reuse
    MenuLogic.dataResult['trueAirspeed'] = calTrueAirspeed;
    resultPrinter(['True Airspeed: ${MenuLogic.formatNumber(calTrueAirspeed)}kt']);

    if (!MenuLogic.backToMenu()) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      calibratedAir = null;
      pressAltitude = null;
      temperature = null;

      pressCheck = true;
      tempCheck = true;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? windComponentScreen() {
  double? windDirection;
  double? windSpeedKt;
  double? runwayNumber;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final windDirInput = MenuLogic.screenType(InputType.windDirection, windDirection);
    final windSpeedInput = MenuLogic.screenType(InputType.windSpeed, windSpeedKt);
    final runwayInput = MenuLogic.screenType(InputType.runway, runwayNumber);

    MenuLogic.screenHeader(title: 'WIND COMPONENT 💨');

    // Getting wind direction.
    windDirection = windDirInput.optionLogic();
    if (MenuLogic.repeatLoop(windDirection)) continue;

    MenuLogic.dataResult['windDirection'] = windDirection!;

    // Getting wind speed
    windSpeedKt = windSpeedInput.optionLogic();
    if (MenuLogic.repeatLoop(windSpeedKt)) continue;

    MenuLogic.dataResult['windSpeed'] = windSpeedKt!;

    // Getting runway number.
    runwayNumber = runwayInput.optionLogic();
    if (MenuLogic.repeatLoop(runwayNumber)) continue;

    // Map with calculated wind component.
    final result = windComponent(direction: runwayNumber!, windDirection: windDirection, windSpeed: windSpeedKt, runway: true);
    final crossWindComp =  result['crossWind']!;
    final headTailComp = result['headWind']!;

    resultPrinter(windComponentString(headTail: headTailComp, xCross: crossWindComp));

    if (!MenuLogic.backToMenu()) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      windDirection = null;
      windSpeedKt = null;
      runwayNumber = null;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? headingCorrectionScreen() {
  // TODO find a way to reset manually entered values if one of the inputs was calculated in another option.
  double? trueCourse;
  double? windDirection;
  double? windSpeedKt;
  double? trueAirspeedTas;

  bool windDirExits = MenuLogic.dataResult.containsKey('windDirection');
  bool windSpeedExits = MenuLogic.dataResult.containsKey('windSpeed');
  bool trueAirExits = MenuLogic.dataResult.containsKey('trueAirspeed');

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final trueCourseInput = MenuLogic.screenType(InputType.trueCourse, trueCourse);
    final windDirInput = MenuLogic.screenType(InputType.windDirection, windDirection);
    final windSpeedInput = MenuLogic.screenType(InputType.windSpeed, windSpeedKt);
    final trueAirspeedInput = MenuLogic.screenType(InputType.trueAirspeed, trueAirspeedTas);

    MenuLogic.screenHeader(title: 'HEADING/WIND CORRECTION ANGLE (WCA)');

    if ([windDirExits, windSpeedExits, trueAirExits].contains(true)) {
      console.setTextStyle(italic: true);
      console.writeLine(MenuLogic.inputNames['autofill']);
      MenuLogic.userInput = input(': ')?.toLowerCase();

      if (MenuLogic.userInput == 'y' || MenuLogic.userInput == 'yes') {
        windDirection = (windDirExits) ? MenuLogic.dataResult['windDirection']?.toDouble() : null;
        windSpeedKt = (windSpeedExits) ? MenuLogic.dataResult['windSpeed']?.toDouble() : null;
        trueAirspeedTas = (trueAirExits) ? MenuLogic.dataResult['trueAirspeed']?.toDouble() : null;
      }

      windDirExits = false;
      windSpeedExits = false;
      trueAirExits = false;

      console.clearScreen();
      continue;
    }

    // Getting true course.
    trueCourse = trueCourseInput.optionLogic();
    if (MenuLogic.repeatLoop(trueCourse)) continue;

    // Getting wind direction.
    windDirection = windDirInput.optionLogic();
    if (MenuLogic.repeatLoop(windDirection)) continue;

    MenuLogic.dataResult['windDirection'] = windDirection!; // saving wind direction input for reuse

    // Getting wind speed
    windSpeedKt = windSpeedInput.optionLogic();
    if (MenuLogic.repeatLoop(windSpeedKt)) continue;

    MenuLogic.dataResult['windSpeed'] = windSpeedKt!; // saving wind speed input for reuse

    // Getting true airspeed.
    trueAirspeedTas = trueAirspeedInput.optionLogic();
    if (MenuLogic.repeatLoop(trueAirspeedTas)) continue;

    MenuLogic.dataResult['trueAirspeed'] = trueAirspeedTas!; // saving true airspeed input for reuse

    final windCorrectionAngle = correctionAngle(
        trueCourse: trueCourse!,
        windDirection: windDirection,
        windSpeed: windSpeedKt,
        trueAirspeed: trueAirspeedTas
    ).round();

    var trueHeading = trueCourse + windCorrectionAngle;
    if (trueHeading > 360) {
      trueHeading -= 360;
    }

    MenuLogic.dataResult['heading'] = trueHeading; // saving calculated heading for reuse

    final headWind = windComponent(direction: trueCourse, windDirection: windDirection, windSpeed: windSpeedKt);
    final groundSpeedKt = trueAirspeedTas - (headWind['headWind']!);

    resultPrinter([
      'Heading: ${MenuLogic.formatNumber(trueHeading)}°',
      'WCA: $windCorrectionAngle°',
      'Ground Speed: ${groundSpeedKt.round()}kt'
    ]);

    if (!MenuLogic.backToMenu()) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      trueCourse = null;
      windDirection = null;
      windSpeedKt = null;
      trueAirspeedTas = null;

      windDirExits = true;
      windSpeedExits = true;
      trueAirExits = true;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? fuelScreen() {
  double? fuelVolume;
  double? time;
  double? fuelRate;

  const fuelOptions =
      'Calculate Fuel:\n'
      '(1) —— Volume (US Gal)\n'
      '(2) —— Endurance (hr)\n'
      '(3) —— Rate (US GPH)';

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    optionMenu(
        title: 'FUEL',
        options: fuelOptions,
        startRange: 1,
        endRange: 3,
        optionList: []
    );

  }



  return MenuLogic.selectedOption;
}