import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/communication_var.dart' as comm;

OptionIdent? volumeScreen() {
  tp.fuelRateInput.firstOption = true;

  double? fuelRate = double.tryParse(comm.inputValues[tp.fuelRateInput.inputType] ?? '');
  double? fuelTime = double.tryParse(comm.inputValues[tp.timeInput.inputType] ?? '');

  double? fuelVolume;
  double? fuelWeight;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'FUEL VOLUME (Gal)');

    tp.fuelRateInput.printInput();
    tp.timeInput.printInput();

    if (fuelRate != null && fuelTime != null) {
      fuelVolume = fuelRate * fuelTime;
      fuelWeight = fuelVolume * 6;
    }

    resultPrinter([
      'Fuel Volume: ${formatNumber(fuelVolume)} GAL',
      'Fuel Weight: ${formatNumber(fuelWeight)} IBS'
    ]);

    final menu = interMenu(comm.currentPosition > 1);
    if (menu) continue;

    final positions = [
      Coordinate(tp.fuelRateInput.row!, tp.fuelRateInput.colum!),
      Coordinate(tp.timeInput.row!, tp.timeInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        fuelRate = tp.fuelRateInput.testLogic();
        break;
      case 1:
        fuelTime = tp.timeInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}

OptionIdent? enduranceScreen() {
  double? fuelVolume;
  double? fuelRate;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    final volumeInput = MenuLogic.screenType(InputInfo.fuelVolume, variable: fuelVolume);
    final fuelRateInput = MenuLogic.screenType(InputInfo.fuelRate, variable: fuelRate);

    screenHeader(title: 'FUEL ENDURANCE');

    fuelVolume = volumeInput.optionLogic();
    if (repeatLoop(fuelVolume)) continue;

    fuelRate = fuelRateInput.optionLogic();
    if (repeatLoop(fuelRate)) continue;

    final endurance = fuelVolume! / fuelRate!;

    resultPrinter([
      'Fuel Endurance: ${formatNumber(endurance)} hr',
      'Fuel Weight: ${formatNumber(fuelVolume * 6)} Ibs'
    ]);

    final backOrNot = insideMenus(goBack: 'Back to Fuel Menu', backMenuSelection: OptionIdent.fuel);
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      fuelVolume = null;
      fuelRate = null;

      continue;
    }

  }

  return comm.selectedOption;
}

OptionIdent? fuelRateScreen() {
  double? fuelVolume;
  double? fuelTime;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    final volumeInput = MenuLogic.screenType(InputInfo.fuelVolume, variable: fuelVolume);
    final fuelTimeInput = MenuLogic.screenType(InputInfo.time, variable: fuelTime);

    screenHeader(title: 'FUEL RATE');

    fuelVolume = volumeInput.optionLogic();
    if (repeatLoop(fuelVolume)) continue;

    fuelTime = fuelTimeInput.optionLogic();
    if (repeatLoop(fuelTime)) continue;

    final fuelRate = fuelVolume! / fuelTime!;

    resultPrinter([
      'Fuel Rate: ${formatNumber(fuelRate)} Gal/hr',
      'Fuel Weight: ${formatNumber(fuelVolume * 6)} Ibs'
    ]);

    final backOrNot = insideMenus(goBack: 'Back to Fuel Menu', backMenuSelection: OptionIdent.fuel);
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      fuelVolume = null;
      fuelTime = null;

      continue;
    }
  }

  return comm.selectedOption;
}