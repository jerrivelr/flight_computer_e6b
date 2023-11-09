import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/setting/setting_lookup.dart';
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/menu_files/menu_builder.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/conversion/conversion_func.dart';

const options = {
  'Return to:': null,
  'Ground Speed Menu': OptionIdent.groundSpeed,
  'Main Menu': OptionIdent.menu
};

OptionIdent? speedScreen() {
  tp.distanceInput.firstOption = true;

  double? distance = double.tryParse(comm.inputValues[tp.distanceInput.inputType] ?? '');
  double? timeHr = double.tryParse(comm.inputValues[tp.timeInput.inputType] ?? '');

  double? calGroundSpeed;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'GROUND SPEED (${speedUnit()?.trim()})');

    tp.distanceInput.printInput();
    tp.timeInput.printInput();

    comm.errorMessage = (timeHr == 0) ? 'Time must be greater than 0' : '';

    final inputsNotNull = distance == null || timeHr == null || timeHr == 0;
    calGroundSpeed = (inputsNotNull) ? null : distanceConvNm(distance: distance) / timeConvHr(time: timeHr);

    if (calGroundSpeed != null) {
      calGroundSpeed = speedConvKnt(speed: calGroundSpeed, convResult: true); // result conversion
      comm.inputValues[InputTitle.groundSpeed] = formatNumber(calGroundSpeed);
    }

    resultPrinter(['Ground Speed: ${formatNumber(calGroundSpeed?.round())}'], unit: speedUnit);

    final menu = returnMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.distanceInput.row!, tp.distanceInput.colum!),
      Coordinate(tp.timeInput.row!, tp.timeInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        distance = tp.distanceInput.optionLogic();
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

    final inputsNotNull = distance == null || groundSpeedKt == null || groundSpeedKt == 0;
    result = (inputsNotNull) ? null : distanceConvNm(distance: distance) / speedConvKnt(speed: groundSpeedKt).round();

    if (result != null) {
      result = timeConvHr(time: result, convResult: true);       // result conversion
      comm.inputValues[InputTitle.time] = formatNumber(result);
    }

    resultPrinter(['Duration: ${formatNumber(result)}'], unit: timeUnit);

    final menu = returnMenu(comm.currentPosition > 1, options);
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

  double? result;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'DISTANCE (${distanceUnit()?.trim()})');

    tp.groundSpeedInput.printInput();
    tp.timeInput.printInput();

    final inputsNotNull = timeHr == null || groundSpeedKt == null;
    result = (inputsNotNull) ? null : (speedConvKnt(speed: groundSpeedKt) * timeConvHr(time: timeHr));

    if (result != null) {
      result = distanceConvNm(distance: result, convResult: true); // result conversion
      comm.inputValues[InputTitle.distance] = formatNumber(result);
    }

    resultPrinter(['Distance: ${formatNumber(result?.round())}'], unit: distanceUnit);

    final menu = returnMenu(comm.currentPosition > 1, options);
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