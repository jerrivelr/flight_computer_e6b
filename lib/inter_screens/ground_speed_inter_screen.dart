import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/communication_var.dart' as comm;

const options = {
  'Return to:': null,
  'Ground Speed Menu': OptionIdent.groundSpeed,
  'Main Menu': OptionIdent.menu
};

OptionIdent? speedScreen() {
  tp.distanceInput.firstOption = true;

  double? distanceNm = double.tryParse(comm.inputValues[tp.distanceInput.inputType] ?? '');
  double? timeHr = double.tryParse(comm.inputValues[tp.timeInput.inputType] ?? '');

  int? calGroundSpeed;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'GROUND SPEED (KT)');

    tp.distanceInput.printInput();
    tp.timeInput.printInput();

    comm.error = (timeHr == 0) ? 'Time must be greater than 0' : '';
    calGroundSpeed = (distanceNm == null || timeHr == null || timeHr == 0) ? null : (distanceNm / timeHr).round();

    comm.inputValues[InputInfo.groundSpeed] = calGroundSpeed?.toString();

    resultPrinter(['Ground Speed: ${formatNumber(calGroundSpeed)} KT']);

    final menu = interMenu(comm.currentPosition > 1, options);
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

OptionIdent? durationScreen() {
  tp.distanceInput.firstOption = true;

  double? distance = double.tryParse(comm.inputValues[tp.distanceInput.inputType] ?? '');
  double? groundSpeedKt = double.tryParse(comm.inputValues[tp.groundSpeedInput.inputType] ?? '');

  double? result;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'DURATION (HR)');

    tp.distanceInput.printInput();
    tp.groundSpeedInput.printInput();

    comm.error = (groundSpeedKt == 0) ? 'Ground Speed must greater than 0' : '';
    result = (distance == null || groundSpeedKt == null || groundSpeedKt == 0) ? null : distance / groundSpeedKt.round();

    comm.inputValues[InputInfo.time] = result?.toStringAsPrecision(2);

    resultPrinter(['Duration: ${formatNumber(result)} HR']);

    final menu = interMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.distanceInput.row!, tp.distanceInput.colum!),
      Coordinate(tp.groundSpeedInput.row!, tp.groundSpeedInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        distance = tp.distanceInput.testLogic();
        break;
      case 1:
        groundSpeedKt = tp.groundSpeedInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}

OptionIdent? distanceScreen() {
  tp.groundSpeedInput.firstOption = true;

  double? groundSpeedKt = double.tryParse(comm.inputValues[tp.groundSpeedInput.inputType] ?? '');
  double? timeHr = double.tryParse(comm.inputValues[tp.timeInput.inputType] ?? '');

  int? result;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'DISTANCE (NM)');

    tp.groundSpeedInput.printInput();
    tp.timeInput.printInput();

    result = (timeHr == null || groundSpeedKt == null) ? null : (groundSpeedKt * timeHr).round();

    comm.inputValues[InputInfo.distance] = result?.toString();

    resultPrinter(['Distance: ${formatNumber(result)} NM']);

    final menu = interMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.groundSpeedInput.row!, tp.groundSpeedInput.colum!),
      Coordinate(tp.timeInput.row!, tp.timeInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        groundSpeedKt = tp.groundSpeedInput.testLogic();
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