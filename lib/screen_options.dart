import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

class OptionMenu {
  String? _currentSelection;

  final String title;
  final Map<String, String> displayOptions;
  final int startRange;
  final int endRange;
  final List<String> listOfOptions;

  String? get currentSelection => _currentSelection;

  OptionMenu({
    required this.title,
    required this.displayOptions,
    required this.startRange,
    required this.endRange,
    required this.listOfOptions
  });

  String? displayMenu() {
    String error = '';

    while (true) {
      // Creating the title bar.
      MenuLogic.screenHeader(title: title, errorWindow: false);

      for (final items in displayOptions.entries) {
        if (items.value == 'noColor') {
          comm.console.setForegroundColor(ConsoleColor.white);
          comm.console.resetColorAttributes();
          comm.console.write(items.key);
          continue;
        }
        comm.console.setForegroundExtendedColor(180);
        comm.console.write(items.key);

        comm.console.setTextStyle(bold: true, italic: true);
        comm.console.setForegroundExtendedColor(253);
        comm.console.write(items.value);

        comm.console.resetColorAttributes();
      }
      // Displaying error messages bellow the list of displayOptions
      errorMessage(error);
      comm.console.setForegroundExtendedColor(250);

      // Getting input from user
      String? userInput = input(': ');
      int? selectionNum = int.tryParse(userInput ?? '');

      if (comm.optionList.contains(userInput?.toLowerCase())) {
        return userInput;
      } else if (selectionNum == null) {
        comm.console.clearScreen();
        error = 'Enter a valid option';
        continue;
      } else if (selectionNum < startRange || selectionNum > endRange) {
        comm.console.clearScreen();
        error = 'Choose an option between ($startRange) — ($endRange)';
        continue;
      }
      _currentSelection = listOfOptions.elementAt(selectionNum - 1);

      return _currentSelection;

    }

  }
}
