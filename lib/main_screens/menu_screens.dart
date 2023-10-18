import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/inter_screens/help_config.dart';
import 'package:flight_e6b/inter_screens/fuel_inter_screens.dart';
import 'package:flight_e6b/inter_screens/pd_altitude_inter_screens.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/communication_var.dart' as comm;

OptionIdent? mainMenu() {
  const options = {
  'Help/Config': OptionIdent.helpConfig,
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

OptionIdent? helpConfig() {
  OptionIdent? selection;

  const options = {
    'Help': OptionIdent.help,
    'Config': OptionIdent.config,
    'Main Menu': OptionIdent.menu
  };

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    selection = menuBuilder (title: 'HELP/CONFIG', menuOptions: options);

    switch (selection) {
      case OptionIdent.help:
        comm.console.clearScreen();
        helpScreen();
        break;
      case OptionIdent.config:
        comm.console.clearScreen();
        configScreen();
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

OptionIdent? cloudBaseScreen() {
  tp.tempInput.firstOption = true;

  double? temperature = double.tryParse(comm.inputValues[tp.tempInput.inputType] ?? '');
  double? dewpoint = double.tryParse(comm.inputValues[tp.dewInput.inputType] ?? '');

  int? result;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'CLOUD BASE 🌧️');

    tp.tempInput.printInput();
    tp.dewInput.printInput();

    result = cloudBase(temperature, dewpoint);

    resultPrinter(['Cloud Base: ${formatNumber(result)} FT']);

    final menu = interMenu(comm.currentPosition > 1);
    if (menu) continue;

    final positions = [
      Coordinate(tp.tempInput.row!, tp.tempInput.colum!),
      Coordinate(tp.dewInput.row!, tp.dewInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        temperature = tp.tempInput.testLogic();
        break;
      case 1:
        dewpoint = tp.dewInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
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
  tp.distanceInput.firstOption = true;

  double? distanceNm = double.tryParse(comm.inputValues[tp.distanceInput.inputType] ?? '');
  double? timeHr = double.tryParse(comm.inputValues[tp.timeInput.inputType] ?? '');

  int? calGroundSpeed;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'GROUND SPEED (kt)');

    tp.distanceInput.printInput();
    tp.timeInput.printInput();

    if (distanceNm != null && timeHr != null) {
      comm.error = (timeHr == 0) ? 'Time must be greater than 0' : '';
      calGroundSpeed = (timeHr == 0) ? null : (distanceNm / timeHr).round();
    }

    resultPrinter(['Ground Speed: ${formatNumber(calGroundSpeed)} KT']);

    final menu = interMenu(comm.currentPosition > 1);
    if (menu) continue;

    final positions = [
      Coordinate(tp.distanceInput.row!, tp.distanceInput.colum!),
      Coordinate(tp.timeInput.row!, tp.timeInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        distanceNm = tp.distanceInput.testLogic();
        break;
      case 1:
        timeHr = tp.timeInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}

OptionIdent? trueAirspeedScreen() {
  tp.calibratedInput.firstOption = true;

  double? calibratedAir = double.tryParse(comm.inputValues[tp.calibratedInput.inputType] ?? '');
  double? pressAltitude = double.tryParse(comm.inputValues[tp.pressAltInput.inputType] ?? '');
  double? temperature = double.tryParse(comm.inputValues[tp.tempInput.inputType] ?? '');

  int? calTrueAirspeed;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'TRUE AIRSPEED (kt)');

    tp.calibratedInput.printInput();
    tp.pressAltInput.printInput();
    tp.tempInput.printInput();

    calTrueAirspeed = trueAirspeed(
        calibratedAirS: calibratedAir,
        pressAltitude: pressAltitude,
        tempC: temperature
    );

    resultPrinter(['True Airspeed: ${formatNumber(calTrueAirspeed)} KT']);

    comm.inputValues[InputInfo.trueAirspeed] = calTrueAirspeed?.toString();

    final menu = interMenu(comm.currentPosition > 2);
    if (menu) continue;

    final positions = [
      Coordinate(tp.calibratedInput.row!, tp.calibratedInput.colum!),
      Coordinate(tp.pressAltInput.row!, tp.pressAltInput.colum!),
      Coordinate(tp.tempInput.row!, tp.tempInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        calibratedAir = tp.calibratedInput.testLogic();
        break;
      case 1:
        pressAltitude = tp.pressAltInput.testLogic();
        break;
      case 2:
        temperature = tp.tempInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}

OptionIdent? windComponentScreen() {
  tp.windDirInput.firstOption = true;

  double? windDirection = double.tryParse(comm.inputValues[tp.windDirInput.inputType] ?? '');
  double? windSpeedKt = double.tryParse(comm.inputValues[tp.windSpeedInput.inputType] ?? '');
  double? runwayNumber = double.tryParse(comm.inputValues[tp.runwayInput.inputType] ?? '');

  double? xWindComp;
  double? headTailComp;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'WIND COMPONENT 💨');

    tp.windDirInput.printInput();
    tp.windSpeedInput.printInput();
    tp.runwayInput.printInput();

    // Calculated head wind and tail wind component.
    xWindComp =  crossWindComp(direction: runwayNumber, windDirection: windDirection, windSpeed: windSpeedKt);
    headTailComp = headWindComp(direction: runwayNumber, windDirection: windDirection, windSpeed: windSpeedKt);

    resultPrinter(windComponentString(headTail: headTailComp, xCross: xWindComp));

    final menu = interMenu(comm.currentPosition > 2);
    if (menu) continue;

    final positions = [
      Coordinate(tp.windDirInput.row!, tp.windDirInput.colum!),
      Coordinate(tp.windSpeedInput.row!, tp.windSpeedInput.colum!),
      Coordinate(tp.runwayInput.row!, tp.runwayInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        windDirection = tp.windDirInput.testLogic();
        break;
      case 1:
        windSpeedKt = tp.windSpeedInput.testLogic();
        break;
      case 2:
        runwayNumber = tp.runwayInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
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
    final trueCourseInput = MenuLogic.screenType(InputInfo.trueCourse, variable: trueCourse);
    final windDirInput = MenuLogic.screenType(InputInfo.windDirection, variable: windDirection);
    final windSpeedInput = MenuLogic.screenType(InputInfo.windSpeed, variable: windSpeedKt);
    final trueAirspeedInput = MenuLogic.screenType(InputInfo.trueAirspeed, variable: trueAirspeedTas);

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
    );

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
    var trueHeading = trueCourse + windCorrectionAngle.round();
    if (trueHeading > 360) {
      trueHeading -= 360;
    }

    comm.dataResult['heading'] = trueHeading; // saving calculated heading for reuse

    final groundSpeedKt = groundSpeed(
        trueAirspeed: trueAirspeedTas,
        windDirection: windDirection,
        windSpeed: windSpeedKt,
        course: trueCourse,
        corrAngle: windCorrectionAngle
    );

    resultPrinter([
      'Heading: ${formatNumber(trueHeading)}°',
      'WCA: ${windCorrectionAngle.round()}°',
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