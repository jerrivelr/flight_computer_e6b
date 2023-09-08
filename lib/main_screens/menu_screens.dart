import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/inter_screens/fuel_inter_screens.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/screen_options.dart';

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

  final optionList = MenuLogic.optionList.getRange(0, 7).toList();
  final menuDisplay = OptionMenu(
      title: 'FLIGHT COMPUTER (E6B)',
      displayOptions: options,
      startRange: 1,
      endRange: 7,
      optionList: optionList
  );
  return menuDisplay.displayMenu();
}

String? cloudBaseScreen() {
  double? temperature;
  double? dewpoint;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    // Sending calculated pressure altitude to the dataResult Map.
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
    // Sending calculated pressure altitude to the dataResult Map.
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
    // Creating input object for each input.
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
    MenuLogic.dataResult['groundSpeed'] = calGroundSpeed; // Sending ground speed to the dataResult map.

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

  // Checking pressure altitude was previously calculated or input.
  bool pressExists = MenuLogic.dataResult.containsKey('pressureAlt');
  bool tempExists = MenuLogic.dataResult.containsKey('temperature');

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    // Creating input object for each input.
    final calibratedInput = MenuLogic.screenType(InputType.calibratedAir, calibratedAir);
    final pressAltInput = MenuLogic.screenType(InputType.pressureAlt, pressAltitude);
    final tempInput = MenuLogic.screenType(InputType.temperature, temperature);

    MenuLogic.screenHeader(title: 'TRUE AIRSPEED (kt)');

    // If pressure altitude or temperature was input from option 2, the user is asked weather or not they want to autofill.
    if (pressExists || tempExists) {
      console.setTextStyle(italic: true);
      console.writeLine('Autofill previously calculated/entered values: [Y] yes ——— [N] no (any key)?');
      MenuLogic.userInput = input(': ')?.toLowerCase();

      if (MenuLogic.userInput == 'y' || MenuLogic.userInput == 'yes') {
        pressAltitude = (pressExists) ? MenuLogic.dataResult['pressureAlt']?.toDouble() : null;
        temperature = (tempExists) ? MenuLogic.dataResult['temperature']?.toDouble() : null;
      }

      console.clearScreen();
      pressExists = false;
      tempExists = false;

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

      pressExists = true;
      tempExists = true;

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
    // Creating input object for each input.
    final windDirInput = MenuLogic.screenType(InputType.windDirection, windDirection);
    final windSpeedInput = MenuLogic.screenType(InputType.windSpeed, windSpeedKt);
    final runwayInput = MenuLogic.screenType(InputType.runway, runwayNumber);

    MenuLogic.screenHeader(title: 'WIND COMPONENT 💨');

    // Getting wind direction.
    windDirection = windDirInput.optionLogic();
    if (MenuLogic.repeatLoop(windDirection)) continue;

    MenuLogic.dataResult['windDirection'] = windDirection!; // Sending the inputted wind direction to the dataResult map.

    // Getting wind speed
    windSpeedKt = windSpeedInput.optionLogic();
    if (MenuLogic.repeatLoop(windSpeedKt)) continue;

    MenuLogic.dataResult['windSpeed'] = windSpeedKt!; // Sending the inputted wind speed to the dataResult map.

    // Getting runway number.
    runwayNumber = runwayInput.optionLogic();
    if (MenuLogic.repeatLoop(runwayNumber)) continue;

    // Map with calculated wind component.
    final result = windComponent(direction: runwayNumber!, windDirection: windDirection, windSpeed: windSpeedKt, runway: true);
    // Calculated head wind and tail wind component.
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

  // Checking if wind direction, wind speed, and true airspeed was previously input or calculated.
  bool windDirExists = MenuLogic.dataResult.containsKey('windDirection');
  bool windSpeedExists = MenuLogic.dataResult.containsKey('windSpeed');
  bool trueAirExists = MenuLogic.dataResult.containsKey('trueAirspeed');

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    // Creating input object for each input.
    final trueCourseInput = MenuLogic.screenType(InputType.trueCourse, trueCourse);
    final windDirInput = MenuLogic.screenType(InputType.windDirection, windDirection);
    final windSpeedInput = MenuLogic.screenType(InputType.windSpeed, windSpeedKt);
    final trueAirspeedInput = MenuLogic.screenType(InputType.trueAirspeed, trueAirspeedTas);

    MenuLogic.screenHeader(title: 'HEADING/WIND CORRECTION ANGLE (WCA)');

    // If the user decides to autofill the calculated or input values they will be autofilled.
    if ([windDirExists, windSpeedExists, trueAirExists].contains(true)) {
      console.setTextStyle(italic: true);
      console.writeLine('Autofill previously calculated/entered values: [Y] yes ——— [N] no (any key)?');
      MenuLogic.userInput = input(': ')?.toLowerCase();

      if (MenuLogic.userInput == 'y' || MenuLogic.userInput == 'yes') {
        windDirection = (windDirExists) ? MenuLogic.dataResult['windDirection']?.toDouble() : null;
        windSpeedKt = (windSpeedExists) ? MenuLogic.dataResult['windSpeed']?.toDouble() : null;
        trueAirspeedTas = (trueAirExists) ? MenuLogic.dataResult['trueAirspeed']?.toDouble() : null;
      }

      windDirExists = false;
      windSpeedExists = false;
      trueAirExists = false;

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

    // Calculating wind correction angle.
    final windCorrectionAngle = correctionAngle(
        trueCourse: trueCourse!,
        windDirection: windDirection,
        windSpeed: windSpeedKt,
        trueAirspeed: trueAirspeedTas
    ).round();

    // To make sure true heading is not equal to more than 360.
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

    // Asking the user weather to go back to the main menu or stay in this option for new calculations.
    if (!MenuLogic.backToMenu()) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      trueCourse = null;
      windDirection = null;
      windSpeedKt = null;
      trueAirspeedTas = null;

      windDirExists = true;
      windSpeedExists = true;
      trueAirExists = true;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? fuelScreen() {
  String? selection;

  const fuelOptions =
      'Calculate Fuel...\n'
      '(1) —— Volume (US Gal)\n'
      '(2) —— Endurance (hr)\n'
      '(3) —— Rate (US GPH)';

  final menuDisplay = OptionMenu(
      title: 'FUEL',
      displayOptions: fuelOptions,
      startRange: 1,
      endRange: 3,
      optionList: ['vol', 'dur', 'rate']
  );

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    selection = menuDisplay.displayMenu();

    switch (selection) {
      case 'vol':
        console.clearScreen();
        volumeScreen();
        break;
      case 'dur':
        console.clearScreen();
        enduranceScreen();
        break;
      case 'rate':
        console.clearScreen();
        fuelRateScreen();
        break;
      default:
        console.clearScreen();
        return selection;

    }
  }

  return MenuLogic.selectedOption;
}