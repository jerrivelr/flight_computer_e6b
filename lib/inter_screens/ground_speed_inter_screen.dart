import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/setting/setting_lookup.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/menu_files/menu_builder.dart';
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
    screenHeader(title: 'GROUND SPEED (${speedUnit()?.trim()})');

    tp.distanceInput.printInput();
    tp.timeInput.printInput();

    comm.errorMessage = (timeHr == 0) ? 'Time must be greater than 0' : '';
    calGroundSpeed = (distanceNm == null || timeHr == null || timeHr == 0) ? null : (distanceNm / timeHr).round();

    comm.inputValues[InputTitle.groundSpeed] = calGroundSpeed?.toString();

    resultPrinter(['Ground Speed: ${formatNumber(calGroundSpeed)}'], unit: speedUnit);

    final menu = interMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.distanceInput.row!, tp.distanceInput.colum!),
      Coordinate(tp.timeInput.row!, tp.timeInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        distanceNm = tp.distanceInput.optionLogic();
        break;
      case 1:
        timeHr = tp.timeInput.optionLogic();
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
    screenHeader(title: 'DURATION (${timeUnit()?.trim()})');

    tp.distanceInput.printInput();
    tp.groundSpeedInput.printInput();

    comm.errorMessage = (groundSpeedKt == 0) ? 'Ground Speed must greater than 0' : '';
    result = (distance == null || groundSpeedKt == null || groundSpeedKt == 0) ? null : distance / groundSpeedKt.round();

    comm.inputValues[InputTitle.time] = result?.toStringAsPrecision(2);

    resultPrinter(['Duration: ${formatNumber(result)}'], unit: timeUnit);

    final menu = interMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.distanceInput.row!, tp.distanceInput.colum!),
      Coordinate(tp.groundSpeedInput.row!, tp.groundSpeedInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        distance = tp.distanceInput.optionLogic();
        break;
      case 1:
        groundSpeedKt = tp.groundSpeedInput.optionLogic();
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
    screenHeader(title: 'DISTANCE (${distanceUnit()?.trim()})');

    tp.groundSpeedInput.printInput();
    tp.timeInput.printInput();

    result = (timeHr == null || groundSpeedKt == null) ? null : (groundSpeedKt * timeHr).round();

    comm.inputValues[InputTitle.distance] = result?.toString();

    resultPrinter(['Distance: ${formatNumber(result)}'], unit: distanceUnit);

    final menu = interMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.groundSpeedInput.row!, tp.groundSpeedInput.colum!),
      Coordinate(tp.timeInput.row!, tp.timeInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        groundSpeedKt = tp.groundSpeedInput.optionLogic();
        break;
      case 1:
        timeHr = tp.timeInput.optionLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}