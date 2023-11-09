import 'package:flight_e6b/conversion/conversion_func.dart';
import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/setting/setting_lookup.dart';
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/menu_files/menu_builder.dart';
import 'package:flight_e6b/inter_screens/help_config.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/inter_screens/fuel_inter_screens.dart';
import 'package:flight_e6b/inter_screens/pd_altitude_inter_screens.dart';
import 'package:flight_e6b/inter_screens/ground_speed_inter_screen.dart';

import '../menu_files/menus.dart';

OptionIdent? helpConfig() {
  OptionIdent? selection;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    selection = helpConfigMenu.displayMenu();

    switch (selection) {
      case OptionIdent.help:
        comm.console.clearScreen();
        helpScreen();
        break;
      case OptionIdent.setting:
        comm.console.clearScreen();
        settingScreen();
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

    resultPrinter(['Cloud Base: ${formatNumber(result)}'], unit: altitudeUnit, isAgl: true);

    final menu = returnMenu(comm.currentPosition > 1);
    if (menu) continue;

    final positions = [
      Coordinate(tp.tempInput.row, tp.tempInput.colum),
      Coordinate(tp.dewInput.row, tp.dewInput.colum),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        temperature = tp.tempInput.optionLogic();
        break;
      case 1:
        dewpoint = tp.dewInput.optionLogic();
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

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    selection = pressDenMenu.displayMenu();

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

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    final groundSpeedMenu = MenuBuilder(
        title: 'GROUND SPEED',
        menuOptions: {
          'Calculate...': null,
          'Ground Speed (${speedUnit()?.trim()})': OptionIdent.calGroundSpeed,
          'Duration (${timeUnit()?.trim()})': OptionIdent.groundDur,
          'Distance (${distanceUnit()?.trim()})': OptionIdent.groundDis,
          'Main Menu': OptionIdent.menu
        }
    );

    selection = groundSpeedMenu.displayMenu();

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
    screenHeader(title: 'TRUE AIRSPEED (${speedUnit()?.trim()})');

    tp.calibratedInput.printInput();
    tp.pressAltInput.printInput();
    tp.tempInput.printInput();

    calTrueAirspeed = trueAirspeed(
        calibratedAirS: calibratedAir,
        pressAltitude: pressAltitude,
        tempC: temperature
    );

    resultPrinter(['True Airspeed: ${formatNumber(calTrueAirspeed)}'], unit: speedUnit);

    comm.inputValues[InputTitle.trueAirspeed] = calTrueAirspeed?.toString();

    final menu = returnMenu(comm.currentPosition > 2);
    if (menu) continue;

    final positions = [
      Coordinate(tp.calibratedInput.row, tp.calibratedInput.colum),
      Coordinate(tp.pressAltInput.row, tp.pressAltInput.colum),
      Coordinate(tp.tempInput.row, tp.tempInput.colum),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        calibratedAir = tp.calibratedInput.optionLogic();
        break;
      case 1:
        pressAltitude = tp.pressAltInput.optionLogic();
        break;
      case 2:
        temperature = tp.tempInput.optionLogic();
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

    final menu = returnMenu(comm.currentPosition > 2);
    if (menu) continue;

    final positions = [
      Coordinate(tp.windDirInput.row, tp.windDirInput.colum),
      Coordinate(tp.windSpeedInput.row, tp.windSpeedInput.colum),
      Coordinate(tp.runwayInput.row, tp.runwayInput.colum),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        windDirection = tp.windDirInput.optionLogic();
        break;
      case 1:
        windSpeedKt = tp.windSpeedInput.optionLogic();
        break;
      case 2:
        runwayNumber = tp.runwayInput.optionLogic();
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

    comm.inputValues[InputTitle.groundSpeed] = groundSpeedKt?.toString();

    resultPrinter([
      'Heading: ${formatNumber(trueHeading)}°',
      'WCA: ${formatNumber(windCorrectionAngle?.round())}°',
      'Ground Speed: ${formatNumber(groundSpeedKt?.round())}${speedUnit()}'
    ]);

    final menu = returnMenu(comm.currentPosition > 3);
    if (menu) continue;

    final positions = [
      Coordinate(tp.trueAirspeedInput.row, tp.trueAirspeedInput.colum),
      Coordinate(tp.trueCourseInput.row, tp.trueCourseInput.colum),
      Coordinate(tp.windDirInput.row, tp.windDirInput.colum),
      Coordinate(tp.windSpeedInput.row, tp.windSpeedInput.colum),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        trueAirspeedTas = tp.trueAirspeedInput.optionLogic();
        break;
      case 1:
        trueCourse = tp.trueCourseInput.optionLogic();
        break;
      case 2:
        windDirection = tp.windDirInput.optionLogic();
        break;
      case 3:
        windSpeedKt = tp.windSpeedInput.optionLogic();
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

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    fuelMenu.title = 'FUEL (${fuelTypeSel()?.trim()})';
    fuelMenu.menuOptions = {
      'Calculate Fuel...': null,
      'Volume (${fuelUnit()?.trim()})': OptionIdent.fuelVol,
      'Endurance (${timeUnit()?.trim()})': OptionIdent.fuelDur,
      'Rate (${fuelRateUnit()?.trim()})': OptionIdent.fuelRate,
      'Main Menu': OptionIdent.menu
    };

    selection = fuelMenu.displayMenu();

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