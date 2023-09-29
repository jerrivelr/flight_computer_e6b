import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/main_screens/menu_screens.dart';
import 'package:flight_e6b/menu_logic.dart';

final console = Console();

void main(List<String> arguments) async {
  console.clearScreen();
  OptionIdent? userSelection = OptionIdent.menu;

  while (userSelection != OptionIdent.exit) {
    switch (userSelection) {
      case OptionIdent.menu:
        userSelection = mainMenu();
        break;
      case OptionIdent.cloudBase:
        console.clearScreen();
        userSelection = cloudBaseScreen();
        break;
      case OptionIdent.pressDenAlt:
        console.clearScreen();
        userSelection = await pressDensityScreen();
        break;
      case OptionIdent.groundSpeed:
        console.clearScreen();
        userSelection = groundSpeedScreen();
        break;
      case OptionIdent.trueAirspeed:
        console.clearScreen();
        userSelection = trueAirspeedScreen();
        break;
      case OptionIdent.windComp:
        console.clearScreen();
        userSelection = windComponentScreen();
        break;
      case OptionIdent.windCorrection:
        console.clearScreen();
        userSelection = headingCorrectionScreen();
        break;
      case OptionIdent.fuel:
        console.clearScreen();
        userSelection = fuelScreen();
        break;
      default:
        break;
    }
  }
  console.clearScreen();
  console.resetColorAttributes();
}
