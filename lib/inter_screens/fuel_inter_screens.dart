import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:dart_console/dart_console.dart';

final console = Console();

String? volumeScreen() {
  double? fuelRate;
  double? duration;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    final fuelRateInput = MenuLogic.screenType(InputType.fuelRate, fuelRate);
    final durationInput = MenuLogic.screenType(InputType.time, duration);

    MenuLogic.screenHeader(title: 'FUEL VOLUME (Gal)');

    fuelRate = fuelRateInput.optionLogic();
    if (MenuLogic.repeatLoop(fuelRate)) continue;

    duration = durationInput.optionLogic();
    if (MenuLogic.repeatLoop(duration)) continue;

    final fuelVolume = fuelRate! * duration!;

    resultPrinter([
      'Fuel Volume: ${MenuLogic.formatNumber(fuelVolume)} Gal',
      'Fuel Weight: ${MenuLogic.formatNumber(fuelVolume * 6)} Ibs'
    ]);

    if (!MenuLogic.backToMenu(text: 'Back to fuel menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt7')) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      fuelRate = null;
      duration = null;

      continue;
    }

  }

  return MenuLogic.selectedOption;
}
