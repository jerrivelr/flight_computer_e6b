import 'package:flight_e6b/main_screens/menu_screens.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

void main(List<String> arguments) async {
  comm.console.clearScreen();
  OptionIdent? userSelection = OptionIdent.menu;

  while (userSelection != OptionIdent.exit) {
    comm.error = '';

    switch (userSelection) {
      case OptionIdent.menu:
        userSelection = mainMenu();
        break;
      case OptionIdent.helpConfig:
        userSelection = helpConfig();
        break;
      case OptionIdent.cloudBase:
        comm.console.clearScreen();
        userSelection = cloudBaseScreen();
        break;
      case OptionIdent.pressDenAlt:
        comm.console.clearScreen();
        userSelection = await pressDensityScreen();
        break;
      case OptionIdent.groundSpeed:
        comm.console.clearScreen();
        userSelection = groundSpeedScreen();
        break;
      case OptionIdent.trueAirspeed:
        comm.console.clearScreen();
        userSelection = trueAirspeedScreen();
        break;
      case OptionIdent.windComp:
        comm.console.clearScreen();
        userSelection = windComponentScreen();
        break;
      case OptionIdent.windCorrection:
        comm.console.clearScreen();
        userSelection = headingCorrectionScreen();
        break;
      case OptionIdent.fuel:
        comm.console.clearScreen();
        userSelection = fuelScreen();
        break;
      default:
        break;
    }
  }
  comm.console.clearScreen();
  comm.console.resetColorAttributes();
}
