import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:dart_console/dart_console.dart';

final console = Console();

String? volumeScreen() {
  double? fuelRate;
  double? fuelTime;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final fuelRateInput = MenuLogic.screenType(InputType.fuelRate, fuelRate);
    final durationInput = MenuLogic.screenType(InputType.time, fuelTime);

    MenuLogic.screenHeader(title: 'FUEL VOLUME (Gal)');

    fuelRate = fuelRateInput.optionLogic();
    if (MenuLogic.repeatLoop(fuelRate)) continue;

    fuelTime = durationInput.optionLogic();
    if (MenuLogic.repeatLoop(fuelTime)) continue;

    final fuelVolume = fuelRate! * fuelTime!;

    resultPrinter([
      'Fuel Volume: ${MenuLogic.formatNumber(fuelVolume)} Gal',
      'Fuel Weight: ${MenuLogic.formatNumber(fuelVolume * 6)} Ibs'
    ]);

    if (!MenuLogic.backToMenu(text: 'Back to fuel menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt7')) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      fuelRate = null;
      fuelTime = null;

      continue;
    }

  }

  return MenuLogic.selectedOption;
}

String? enduranceScreen() {
  double? fuelVolume;
  double? fuelRate;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final volumeInput = MenuLogic.screenType(InputType.fuelVolume, fuelVolume);
    final fuelRateInput = MenuLogic.screenType(InputType.fuelRate, fuelRate);

    MenuLogic.screenHeader(title: 'FUEL ENDURANCE');

    fuelVolume = volumeInput.optionLogic();
    if (MenuLogic.repeatLoop(fuelVolume)) continue;

    fuelRate = fuelRateInput.optionLogic();
    if (MenuLogic.repeatLoop(fuelRate)) continue;

    final endurance = fuelVolume! / fuelRate!;

    resultPrinter([
      'Fuel Endurance: ${MenuLogic.formatNumber(endurance)} hr',
      'Fuel Weight: ${MenuLogic.formatNumber(fuelVolume * 6)} Ibs'
    ]);

    if (!MenuLogic.backToMenu(text: 'Back to fuel menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt7')) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      fuelVolume = null;
      fuelRate = null;

      continue;
    }

  }

  return MenuLogic.selectedOption;
}

String? fuelRateScreen() {
  double? fuelVolume;
  double? fuelTime;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final volumeInput = MenuLogic.screenType(InputType.fuelVolume, fuelVolume);
    final fuelTimeInput = MenuLogic.screenType(InputType.time, fuelTime);

    MenuLogic.screenHeader(title: 'FUEL RATE');

    fuelVolume = volumeInput.optionLogic();
    if (MenuLogic.repeatLoop(fuelVolume)) continue;

    fuelTime = fuelTimeInput.optionLogic();
    if (MenuLogic.repeatLoop(fuelTime)) continue;

    final fuelRate = fuelVolume! / fuelTime!;

    resultPrinter([
      'Fuel Rate: ${MenuLogic.formatNumber(fuelRate)} Gal/hr',
      'Fuel Weight: ${MenuLogic.formatNumber(fuelVolume * 6)} Ibs'
    ]);

    if (!MenuLogic.backToMenu(text: 'Back to fuel menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt7')) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      fuelVolume = null;
      fuelTime = null;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}