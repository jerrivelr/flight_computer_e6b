import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/main_screens/input_screens.dart';
import 'package:flight_e6b/menu_files/menus.dart';
import 'package:flight_e6b/setting/setting_lookup.dart';

void main(List<String> arguments) async {
  comm.console.clearScreen();
  OptionIdent? userSelection = OptionIdent.menu;

  while (userSelection != OptionIdent.exit) {
    if (comm.unknownInput != ControlCharacter.unknown) comm.errorMessage = '';
    comm.unknownInput = null;

    switch (userSelection) {
      case OptionIdent.menu:
        mainMenu.menuOptions = {
          'Help/Settings': OptionIdent.helpSetting,
          'Cloud Base (${altitudeUnit()?.trim()})': OptionIdent.cloudBase,
          'Pressure/Density Altitude (${altitudeUnit()?.trim()})': OptionIdent.pressDenAlt,
          'Ground Speed (${speedUnit()?.trim()})': OptionIdent.groundSpeed,
          'True Airspeed (${speedUnit()?.trim()})': OptionIdent.trueAirspeed,
          'Wind Component': OptionIdent.windComp,
          'Heading/Wind Correction Angle (WCA)': OptionIdent.windCorrection,
          'Fuel (${fuelTypeSel()?.trim()})': OptionIdent.fuel,
          'Exit': OptionIdent.exit
        };

        userSelection = mainMenu.displayMenu();
        break;
      case OptionIdent.helpSetting:
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
