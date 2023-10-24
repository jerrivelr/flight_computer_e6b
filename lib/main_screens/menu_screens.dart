import 'package:flight_e6b/inter_screens/ground_speed_inter_screen.dart';
import 'package:flight_e6b/menu_files/menus.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/inter_screens/help_config.dart';
import 'package:flight_e6b/inter_screens/fuel_inter_screens.dart';
import 'package:flight_e6b/inter_screens/pd_altitude_inter_screens.dart';
import 'package:flight_e6b/menu_files/menu_builder.dart';
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
  OptionIdent? selection;

  const groundOptions = {
    'Calculate...': null,
    'Ground Speed (KT)': OptionIdent.calGroundSpeed,
    'Duration (HR)': OptionIdent.groundDur,
    'Distance (NM)': OptionIdent.groundDis,
    'Main Menu': OptionIdent.menu
  };

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    selection = menuBuilder (title: 'GROUND SPEED', menuOptions: groundOptions);

    switch (selection) {
      case OptionIdent.calGroundSpeed:
        comm.console.clearScreen();
        speedScreen();
        break;
      case OptionIdent.groundDur:
        comm.console.clearScreen();
        durationScreen();
        break;
      case OptionIdent.groundDis:
        comm.console.clearScreen();
        distanceScreen();
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
  tp.trueAirspeedInput.firstOption = true;

  double? trueAirspeedTas = double.tryParse(comm.inputValues[tp.trueAirspeedInput.inputType] ?? '');
  double? trueCourse = double.tryParse(comm.inputValues[tp.trueCourseInput.inputType] ?? '');
  double? windDirection = double.tryParse(comm.inputValues[tp.windDirInput.inputType] ?? '');
  double? windSpeedKt = double.tryParse(comm.inputValues[tp.windSpeedInput.inputType] ?? '');

  double? windCorrectionAngle;
  int? trueHeading;
  int? groundSpeedKt;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'HEADING/WIND CORRECTION ANGLE (WCA)');

    tp.trueAirspeedInput.printInput();
    tp.trueCourseInput.printInput();
    tp.windDirInput.printInput();
    tp.windSpeedInput.printInput();

    // Calculating wind correction angle.
    windCorrectionAngle = correctionAngle(
        trueCourse: trueCourse,
        windDirection: windDirection,
        windSpeed: windSpeedKt,
        trueAirspeed: trueAirspeedTas
    );

    trueHeading = heading(trueCourse, windCorrectionAngle);

    groundSpeedKt = groundSpeed(
        trueAirspeed: trueAirspeedTas,
        windDirection: windDirection,
        windSpeed: windSpeedKt,
        course: trueCourse,
        corrAngle: windCorrectionAngle
    );

    comm.inputValues[InputInfo.groundSpeed] = groundSpeedKt?.toString();

    resultPrinter([
      'Heading: ${formatNumber(trueHeading)}°',
      'WCA: ${formatNumber(windCorrectionAngle?.round())}°',
      'Ground Speed: ${formatNumber(groundSpeedKt?.round())} KT'
    ]);

    final menu = interMenu(comm.currentPosition > 3);
    if (menu) continue;

    final positions = [
      Coordinate(tp.trueAirspeedInput.row!, tp.trueAirspeedInput.colum!),
      Coordinate(tp.trueCourseInput.row!, tp.trueCourseInput.colum!),
      Coordinate(tp.windDirInput.row!, tp.windDirInput.colum!),
      Coordinate(tp.windSpeedInput.row!, tp.windSpeedInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        trueAirspeedTas = tp.trueAirspeedInput.testLogic();
        break;
      case 1:
        trueCourse = tp.trueCourseInput.testLogic();
        break;
      case 2:
        windDirection = tp.windDirInput.testLogic();
        break;
      case 3:
        windSpeedKt = tp.windSpeedInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();

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