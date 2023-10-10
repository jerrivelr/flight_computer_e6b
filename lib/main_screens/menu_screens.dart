import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/inter_screens/fuel_inter_screens.dart';
import 'package:flight_e6b/inter_screens/pd_altitude_inter_screens.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

OptionIdent? mainMenu() {
  const options = {
  'Cloud Base (ft)': OptionIdent.cloudBase,
  'Pressure/Density Altitude (ft)': OptionIdent.pressDenAlt,
  'Ground Speed (GS)': OptionIdent.groundSpeed,
  'True Airspeed (TAS)': OptionIdent.trueAirspeed,
  'Wind Component': OptionIdent.windComp,
  'Heading/Wind Correction Angle (WCA)': OptionIdent.windCorrection,
  'Fuel': OptionIdent.fuel,
  'Exit': OptionIdent.exit
  };

  final menuDisplay = menuBuilder(title: 'FLIGHT COMPUTER (E6B)', menuOptions: options);
  return menuDisplay;
}

OptionIdent? cloudBaseScreen() {
  double? temperature;
  double? dewpoint;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    final tempInput = MenuLogic.screenType(InputTitle.temperature, temperature);
    final dewInput = MenuLogic.screenType(InputTitle.dewpoint, dewpoint);

    screenHeader(title: 'CLOUD BASE 🌧️');

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (repeatLoop(temperature)) continue;

    // Getting dewpoint.
    dewpoint = dewInput.optionLogic();
    if (repeatLoop(dewpoint)) {
      continue;
    } else if (dewpoint! > temperature!) {
      comm.error = 'Dewpoint must be less than or equal to temperature';
      dewpoint = null;
      comm.console.clearScreen();
      continue;
    }

    final result = cloudBase(temperature, dewpoint);
    resultPrinter(['Cloud Base: ${formatNumber(result)}ft']);

    final backOrNot = insideMenus();
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      temperature = null;
      dewpoint = null;

      continue;
    }
  }

  return comm.selectedOption;
}

Future<OptionIdent?> pressDensityScreen() async {
  OptionIdent? selection;

  const densityPressOption = {
  'Calculate Pressure/Density Altitude From...': null,
  'Conditions at Airport': OptionIdent.airport,
  'Manual Values': OptionIdent.manual,
  'Main Menu': OptionIdent.menu
  };

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    selection = menuBuilder(title: 'PRESSURE/DENSITY ALTITUDE', menuOptions: densityPressOption);

    switch (selection) {
      case OptionIdent.airport:
        comm.console.clearScreen();
        await conditionsAirportScreen();
        break;
      case OptionIdent.manual:
        comm.console.clearScreen();
        manualScreen();
        break;
      case OptionIdent.menu:
        comm.console.clearScreen();
        comm.selectedOption = selection;
        break;
      default:
        comm.console.clearScreen();
        return selection;
    }
  }

  return comm.selectedOption;
}

OptionIdent? groundSpeedScreen() {
  double? distanceNm;
  double? timeHr;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    // Creating input object for each input.
    final distanceInput = MenuLogic.screenType(InputTitle.distance, distanceNm);
    final timeInput = MenuLogic.screenType(InputTitle.time, timeHr);

    screenHeader(title: 'GROUND SPEED (kt)');

    // Getting distance
    distanceNm = distanceInput.optionLogic();
    if (repeatLoop(distanceNm)) continue;

    // Getting time in hours
    timeHr = timeInput.optionLogic();
    if (repeatLoop(timeHr)) continue;

    final calGroundSpeed = groundSpeed(distanceNm!, timeHr!);
    comm.dataResult['groundSpeed'] = calGroundSpeed; // Sending ground specomm dataResult map.

    resultPrinter(['Ground Speed: ${formatNumber(calGroundSpeed)}kt']);

    final backOrNot = insideMenus();
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      distanceNm = null;
      timeHr = null;

      continue;
    }
  }

  return comm.selectedOption;
}

OptionIdent? trueAirspeedScreen() {
  double? calibratedAir;
  double? pressAltitude;
  double? temperature;

  // Checking pressure altitude was previously calculated or input.
  bool pressExists = comm.dataResult.containsKey('pressureAlt');
  bool tempExists = comm.dataResult.containsKey('temperature');

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    // Creating input object for each input.
    final calibratedInput = MenuLogic.screenType(InputTitle.calibratedAir, calibratedAir);
    final pressAltInput = MenuLogic.screenType(InputTitle.pressureAlt, pressAltitude);
    final tempInput = MenuLogic.screenType(InputTitle.temperature, temperature);

    screenHeader(title: 'TRUE AIRSPEED (kt)');

    // If pressure altitude or temperature was input from option 2, the user is asked weather or not they want to autofill.
    if (pressExists || tempExists) {
      bool? yesSelected = insideMenus(autofill: true);
      if (yesSelected == null) continue;

      if (yesSelected) {
        pressAltitude = (pressExists) ? comm.dataResult['pressureAlt']?.toDouble() : null;
        temperature = (tempExists) ? comm.dataResult['temperature']?.toDouble() : null;
      }

      comm.console.clearScreen();
      pressExists = false;
      tempExists = false;

      continue;
    }

    // Getting Calibrated airspeed.
    calibratedAir = calibratedInput.optionLogic();
    if (repeatLoop(calibratedAir)) continue;

    // Getting pressure altitude.
    pressAltitude = pressAltInput.optionLogic();
    if (repeatLoop(pressAltitude)) continue;

    comm.dataResult['pressureAlt'] = pressAltitude!;

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (repeatLoop(temperature)) continue;


    comm.dataResult['temperature'] = temperature!;

    final calTrueAirspeed = trueAirspeed(
        calibratedAirS: calibratedAir!,
        pressAltitude: pressAltitude,
        tempC: temperature
    );

    // Sending true airspeed result to dateResult map for reuse
    comm.dataResult['trueAirspeed'] = calTrueAirspeed;
    resultPrinter(['True Airspeed: ${formatNumber(calTrueAirspeed)}kt']);

    final backOrNot = insideMenus();
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      calibratedAir = null;
      pressAltitude = null;
      temperature = null;

      pressExists = true;
      tempExists = true;

      continue;
    }
  }

  return comm.selectedOption;
}

OptionIdent? windComponentScreen() {
  double? windDirection;
  double? windSpeedKt;
  double? runwayNumber;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    // Creating input object for each input.
    final windDirInput = MenuLogic.screenType(InputTitle.windDirection, windDirection);
    final windSpeedInput = MenuLogic.screenType(InputTitle.windSpeed, windSpeedKt);
    final runwayInput = MenuLogic.screenType(InputTitle.runway, runwayNumber);

    screenHeader(title: 'WIND COMPONENT 💨');

    // Getting wind direction.
    windDirection = windDirInput.optionLogic();
    if (repeatLoop(windDirection)) continue;

    comm.dataResult['windDirection'] = windDirection!; // Sending the inputted wind directicomm dataResult map.

    // Getting wind speed
    windSpeedKt = windSpeedInput.optionLogic();
    if (repeatLoop(windSpeedKt)) continue;

    comm.dataResult['windSpeed'] = windSpeedKt!; // Sending the inputted wind specomm dataResult map.

    // Getting runway number.
    runwayNumber = runwayInput.optionLogic();
    if (repeatLoop(runwayNumber)) continue;

    // Map with calculated wind component.
    final result = windComponent(direction: runwayNumber!, windDirection: windDirection, windSpeed: windSpeedKt, runway: true);
    // Calculated head wind and tail wind component.
    final crossWindComp =  result['crossWind']!;
    final headTailComp = result['headWind']!;

    resultPrinter(windComponentString(headTail: headTailComp, xCross: crossWindComp));

    final backOrNot = insideMenus();
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      windDirection = null;
      windSpeedKt = null;
      runwayNumber = null;

      continue;
    }
  }

  return comm.selectedOption;
}

OptionIdent? headingCorrectionScreen() {
  double? trueCourse;
  double? windDirection;
  double? windSpeedKt;
  double? trueAirspeedTas;

  // Checking if wind direction, wind speed, and true airspeed was previously input or calculated.
  bool windDirExists = comm.dataResult.containsKey('windDirection');
  bool windSpeedExists = comm.dataResult.containsKey('windSpeed');
  bool trueAirExists = comm.dataResult.containsKey('trueAirspeed');

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    // Creating input object for each input.
    final trueCourseInput = MenuLogic.screenType(InputTitle.trueCourse, trueCourse);
    final windDirInput = MenuLogic.screenType(InputTitle.windDirection, windDirection);
    final windSpeedInput = MenuLogic.screenType(InputTitle.windSpeed, windSpeedKt);
    final trueAirspeedInput = MenuLogic.screenType(InputTitle.trueAirspeed, trueAirspeedTas);

    screenHeader(title: 'HEADING/WIND CORRECTION ANGLE (WCA)');

    // If the user decides to autofill the calculated or input values they will be autofilled.
    if ([windDirExists, windSpeedExists, trueAirExists].contains(true)) {
      bool? yesSelected = insideMenus(autofill: true);
      if (yesSelected == null) continue;

      if (yesSelected) {
        windDirection = (windDirExists) ? comm.dataResult['windDirection']?.toDouble() : null;
        windSpeedKt = (windSpeedExists) ? comm.dataResult['windSpeed']?.toDouble() : null;
        trueAirspeedTas = (trueAirExists) ? comm.dataResult['trueAirspeed']?.toDouble() : null;
      }

      windDirExists = false;
      windSpeedExists = false;
      trueAirExists = false;

      comm.console.clearScreen();
      continue;
    }

    // Getting true course.
    trueCourse = trueCourseInput.optionLogic();
    if (repeatLoop(trueCourse)) continue;

    // Getting wind direction.
    windDirection = windDirInput.optionLogic();
    if (repeatLoop(windDirection)) continue;

    comm.dataResult['windDirection'] = windDirection!; // saving wind direction input for reuse

    // Getting wind speed
    windSpeedKt = windSpeedInput.optionLogic();
    if (repeatLoop(windSpeedKt)) continue;

    comm.dataResult['windSpeed'] = windSpeedKt!; // saving wind speed input for reuse

    // Getting true airspeed.
    trueAirspeedTas = trueAirspeedInput.optionLogic();
    if (repeatLoop(trueAirspeedTas)) continue;

    comm.dataResult['trueAirspeed'] = trueAirspeedTas!; // saving true airspeed input for reuse

    // Calculating wind correction angle.
    final windCorrectionAngle = correctionAngle(
        trueCourse: trueCourse!,
        windDirection: windDirection,
        windSpeed: windSpeedKt,
        trueAirspeed: trueAirspeedTas
    )?.round();

    if (windCorrectionAngle == null) {
      comm.console.clearScreen();
      comm.error = 'Invalid Values';

      trueCourse = null;
      windDirection = null;
      windSpeedKt = null;
      trueAirspeedTas = null;

      windDirExists = false;
      windSpeedExists = false;
      trueAirExists = false;
      continue;
    }

    // To make sure true heading is not equal to more than 360.
    var trueHeading = trueCourse + windCorrectionAngle;
    if (trueHeading > 360) {
      trueHeading -= 360;
    }

    comm.dataResult['heading'] = trueHeading; // saving calculated heading for reuse

    final headWind = windComponent(direction: trueCourse, windDirection: windDirection, windSpeed: windSpeedKt);
    final groundSpeedKt = trueAirspeedTas - (headWind['headWind']!);

    resultPrinter([
      'Heading: ${formatNumber(trueHeading)}°',
      'WCA: $windCorrectionAngle°',
      'Ground Speed: ${groundSpeedKt.round()}kt'
    ]);

    final backOrNot = insideMenus();
    if (backOrNot == null) continue;

    // Asking the user weather to go back to the main menu or stay in this option for new calculations.
    if (backOrNot) {
      comm.console.clearScreen();
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

  return comm.selectedOption;
}

OptionIdent? fuelScreen() {
  OptionIdent? selection;

  const fuelOptions = {
  'Calculate Fuel...': null,
  'Volume (US Gal)': OptionIdent.fuelVol,
  'Endurance (hr)': OptionIdent.fuelDur,
  'Rate (US GPH)': OptionIdent.fuelRate,
  'Main Menu': OptionIdent.menu
  };

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    selection = menuBuilder (title: 'FUEL', menuOptions: fuelOptions);

    switch (selection) {
      case OptionIdent.fuelVol:
        comm.console.clearScreen();
        volumeScreen();
        break;
      case OptionIdent.fuelDur:
        comm.console.clearScreen();
        enduranceScreen();
        break;
      case OptionIdent.fuelRate:
        comm.console.clearScreen();
        fuelRateScreen();
        break;
      case OptionIdent.menu:
        comm.console.clearScreen();
        comm.selectedOption = selection;
        break;
      default:
        comm.console.clearScreen();
        return selection;

    }
  }

  return comm.selectedOption;
}