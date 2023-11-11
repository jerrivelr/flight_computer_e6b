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
  'Fuel Menu': OptionIdent.fuel,
  'Main Menu': OptionIdent.menu
};

OptionIdent? volumeScreen() {
  tp.fuelRateInput.firstOption = true;

  double? fuelRate = double.tryParse(comm.inputValues[tp.fuelRateInput.inputType] ?? '');
  double? fuelTime = double.tryParse(comm.inputValues[tp.timeInput.inputType] ?? '');

  double? fuelVolume;
  double? fuelWeight;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'FUEL VOLUME (${fuelUnit()?.trim()})');

    tp.fuelRateInput.printInput();
    tp.timeInput.printInput();

    fuelVolume = (fuelRate == null || fuelTime == null) ? null : fuelRate * timeConvHr(time: fuelTime);
    fuelWeight = (fuelVolume == null) ? null : fuelWeightConv(fuelVolume);

    if (fuelVolume != null) comm.inputValues[InputTitle.fuelVolume] = fuelVolume.toStringAsFixed(2);

    resultPrinter([
      'Fuel Volume: ${formatNumber(fuelVolume)}${fuelUnit()}',
      'Fuel Weight: ${formatNumber(fuelWeight)}${weightUnit()}'
    ]);

    final menu = returnMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.fuelRateInput.row, tp.fuelRateInput.colum),
      Coordinate(tp.timeInput.row, tp.timeInput.colum),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        fuelRate = tp.fuelRateInput.optionLogic();
        break;
      case 1:
        fuelTime = tp.timeInput.optionLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}

OptionIdent? enduranceScreen() {
  tp.volumeInput.firstOption = true;

  double? fuelVolume = double.tryParse(comm.inputValues[tp.volumeInput.inputType] ?? '');
  double? fuelRate = double.tryParse(comm.inputValues[tp.fuelRateInput.inputType] ?? '');

  double? endurance;
  double? fuelWeight;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'FUEL ENDURANCE (${timeUnit()?.trim()})');

    tp.volumeInput.printInput();
    tp.fuelRateInput.printInput();

    comm.errorMessage = (fuelRate == 0) ? 'Fuel rate must be greater than 0' : '';

    final inputsNotNull = fuelRate == 0 || fuelRate == null || fuelVolume == null;
    endurance = (inputsNotNull) ? null : fuelVolume / fuelRate;

    if (endurance != null) {
      endurance = timeConvHr(time: endurance, convResult: true);
      comm.inputValues[InputTitle.time] = endurance.toStringAsFixed(2);
    }

    fuelWeight = (fuelVolume == null) ? null : fuelWeightConv(fuelVolume);

    resultPrinter([
      'Fuel Endurance: ${formatNumber(endurance)}${timeUnit()}',
      'Fuel Weight: ${formatNumber(fuelWeight)}${weightUnit()}'
    ]);

    final menu = returnMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.volumeInput.row, tp.volumeInput.colum),
      Coordinate(tp.fuelRateInput.row, tp.fuelRateInput.colum),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        fuelVolume = tp.volumeInput.optionLogic();
        break;
      case 1:
        fuelRate = tp.fuelRateInput.optionLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}

OptionIdent? fuelRateScreen() {
  tp.volumeInput.firstOption = true;

  double? fuelVolume = double.tryParse(comm.inputValues[tp.volumeInput.inputType] ?? '');
  double? fuelTime = double.tryParse(comm.inputValues[tp.timeInput.inputType] ?? '');

  double? fuelRate;
  double? fuelWeight;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'FUEL RATE (${fuelRateUnit()?.trim()})');

    tp.volumeInput.printInput();
    tp.timeInput.printInput();

    comm.errorMessage = (fuelTime == 0) ? 'Time must be greater than 0' : '';
    final inputsNotNull = fuelTime == 0 || fuelTime == null || fuelVolume == null;

    fuelRate = (inputsNotNull) ? null : fuelVolume / timeConvHr(time: fuelTime);
    fuelWeight = (fuelVolume == null) ? null : fuelWeightConv(fuelVolume);

    if (fuelRate != null) comm.inputValues[InputTitle.fuelRate] = fuelRate.toStringAsFixed(2);

    resultPrinter([
      'Fuel Rate: ${formatNumber(fuelRate)}${fuelRateUnit()}',
      'Fuel Weight: ${formatNumber(fuelWeight)}${weightUnit()}'
    ]);

    final menu = returnMenu(comm.currentPosition > 1, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.volumeInput.row, tp.volumeInput.colum),
      Coordinate(tp.timeInput.row, tp.timeInput.colum),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        fuelVolume = tp.volumeInput.optionLogic();
        break;
      case 1:
        fuelTime = tp.timeInput.optionLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}