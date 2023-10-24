import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/main_screens/menu_screens.dart';
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/menu_files/menus.dart';

void main(List<String> arguments) async {
  comm.console.clearScreen();
  OptionIdent? userSelection = OptionIdent.menu;

  while (userSelection != OptionIdent.exit) {
    comm.errorMessage = '';

    switch (userSelection) {
      case OptionIdent.menu:
        userSelection = mainMenu.displayMenu();
        break;
      case OptionIdent.helpConfig:
        userSelection = helpConfig();
        break;
      case OptionIdent.cloudBase:
        userSelection = cloudBaseScreen();
        break;
      case OptionIdent.pressDenAlt:
        userSelection = await pressDensityScreen();
        break;
      case OptionIdent.groundSpeed:
        userSelection = groundSpeedScreen();
        break;
      case OptionIdent.trueAirspeed:
        userSelection = trueAirspeedScreen();
        break;
      case OptionIdent.windComp:
        userSelection = windComponentScreen();
        break;
      case OptionIdent.windCorrection:
        userSelection = headingCorrectionScreen();
        break;
      case OptionIdent.fuel:
        userSelection = fuelScreen();
        break;
      default:
        break;
    }
  }
  comm.console.clearScreen();
  comm.console.resetColorAttributes();
}
