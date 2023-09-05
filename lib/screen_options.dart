import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';

final console = Console();

class OptionMenu {
  String? _currentSelection;

  final String title;
  final String displayOptions;
  final int startRange;
  final int endRange;
  final List<String> optionList;

  String? get currentSelection => _currentSelection;

  OptionMenu({
    required this.title,
    required this.displayOptions,
    required this.startRange,
    required this.endRange,
    required this.optionList
  });

  String? displayMenu() {
    String error = '';

    while (true) {
      // Creating the title bar.
      MenuLogic.screenHeader(title: title, errorWindow: false);
      console.setForegroundColor(ConsoleColor.white);
      console.setTextStyle(bold: true, italic: true);

      // Displaying the list of options.
      console.writeLine(displayOptions);
      // Displaying error messages bellow the list of displayOptions
      errorMessage(error);
      console.setForegroundExtendedColor(250);

      // Getting input from user
      String? userInput = input(': ');
      int? selectionNum = int.tryParse(userInput ?? '');

      if (MenuLogic.optionList.contains(userInput?.toLowerCase())) {
        return userInput;
      } else if (selectionNum == null) {
        console.clearScreen();
        error = 'Enter a valid option';
        continue;
      } else if (selectionNum < startRange || selectionNum > endRange) {
        console.clearScreen();
        error = 'Choose an option between ($startRange) — ($endRange)';
        continue;
      }
      _currentSelection = optionList.elementAt(selectionNum - 1);

      return _currentSelection;

    }

  }
}
