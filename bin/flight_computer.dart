import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/main_screens/menu_screens.dart';

final console = Console();

void main(List<String> arguments) async {
  console.clearScreen();
  String? userSelection = 'menu';

  while (userSelection != 'exit') {
    switch (userSelection) {
      case 'menu':
        userSelection = mainMenu();
        break;
      case 'opt1':
        console.clearScreen();
        userSelection = cloudBaseScreen();
        break;
      case 'opt2':
        console.clearScreen();
        userSelection = await pressDensityScreen();
        break;
      case 'opt3':
        console.clearScreen();
        userSelection = groundSpeedScreen();
        break;
      case 'opt4':
        console.clearScreen();
        userSelection = trueAirspeedScreen();
        break;
      case 'opt5':
        console.clearScreen();
        userSelection = windComponentScreen();
        break;
      case 'opt6':
        console.clearScreen();
        userSelection = headingCorrectionScreen();
        break;
      case 'opt7':
        console.clearScreen();
        userSelection = fuelScreen();
        break;
    }
  }
  console.clearScreen();
  console.resetColorAttributes();
}
