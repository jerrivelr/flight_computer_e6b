import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_screens.dart';
import 'package:flight_e6b/simple_io.dart';

final console = Console();

void main(List<String> arguments) {
  String? userSelection = 'menu';
  // TODO EXIT does not work after going back to the menu from another option. It only works when the program first run.
  while (userSelection != 'exit') {
    switch (userSelection) {
      case 'menu':
        mainMenu();
        userSelection = optionChecker();
        break;
      case 'opt1':
        console.clearScreen();
        userSelection = cloudBaseScreen();
        break;
      case 'opt2':
        console.clearScreen();
        userSelection = pressDensityScreen();
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

    }
  }
}

String? optionChecker() {
  console.writeLine();
  console.setForegroundExtendedColor(250);
  String userInput = input(': ') ?? '';

  if (userInput == 'exit') {
    return userInput;
  }

  int? option = int.tryParse(userInput);
  // If more options are added, remember to increase the condition in the while statement (option > x)
  // to check for out of range selection
  while (option == null || option < 1 || option > 7) {
    if (option == null) {
      console.clearScreen();
      mainMenu();
      errorMessage('Enter a valid option');

      option = int.tryParse(input(': ') ?? '');
      continue;
    } else if (option < 1 || option > 7) {
      console.clearScreen();
      mainMenu();
      errorMessage('Choose an option between [1] — [7]');

      option = int.tryParse(input(': ') ?? '');
      continue;
    }
  }

  switch (option) {
    case 1:
      return 'opt1';
    case 2:
      return 'opt2';
    case 3:
      return 'opt3';
    case 4:
      return 'opt4';
    case 5:
      return 'opt5';
    case 6:
      return 'opt6';
    case 7:
      return 'opt7';
  }

  return null;

}
