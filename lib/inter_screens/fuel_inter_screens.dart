import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

OptionIdent? volumeScreen() {
  double? fuelRate;
  double? fuelTime;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    final fuelRateInput = MenuLogic.screenType(InputInfo.fuelRate, variable: fuelRate);
    final durationInput = MenuLogic.screenType(InputInfo.time, variable: fuelTime);

    screenHeader(title: 'FUEL VOLUME (Gal)');

    fuelRate = fuelRateInput.optionLogic();
    if (repeatLoop(fuelRate)) continue;

    fuelTime = durationInput.optionLogic();
    if (repeatLoop(fuelTime)) continue;

    final fuelVolume = fuelRate! * fuelTime!;

    resultPrinter([
      'Fuel Volume: ${formatNumber(fuelVolume)} Gal',
      'Fuel Weight: ${formatNumber(fuelVolume * 6)} Ibs'
    ]);

    final backOrNot = insideMenus(goBack: 'Back to Fuel Menu', backMenuSelection: OptionIdent.fuel);
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      fuelRate = null;
      fuelTime = null;

      continue;
    }

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