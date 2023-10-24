import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/shortcuts.dart';

class MenuBuilder {
  MenuBuilder({required this.menuOptions, this.highlightColor = 94, this.title = '', this.noTitle = false});

  final Map<String, OptionIdent?> menuOptions;
  int highlightColor;
  bool noTitle;
  String title;

  int _firstOption = 0;
  int _currentHighlight = 0;

  OptionIdent? displayMenu() {
    final optionKeys = menuOptions.keys.toList();
    comm.console.hideCursor();

    if (menuOptions[optionKeys[0]] == null) {
      _firstOption = 1;

    } else {
      _firstOption = 0;
    }

    Key? key;
    OptionIdent? selection;

    while (selection == null) {
      if (!noTitle) {
        // Creating the title bar.
        screenHeader(title: title, errorWindow: false);
      }

      if (_currentHighlight < _firstOption) {
        _currentHighlight = optionKeys.length - 1;
      } else if (_currentHighlight > optionKeys.length - 1) {
        _currentHighlight = _firstOption;
      }

      for (var item in menuOptions.entries) {
        if (menuOptions[item.key] == null) {
          comm.console.setForegroundExtendedColor(180);
          comm.console.setTextStyle(bold: true, italic: true);
          comm.console.writeLine(item.key);
          comm.console.resetColorAttributes();
          continue;
        } else if (menuOptions[item.key] == OptionIdent.exit) {
          comm.console.setForegroundColor(ConsoleColor.red); // Exit button text red when not selected
        }

        // Sets exit button with a red highlight when selected
        if (menuOptions[item.key] == OptionIdent.exit && item.key == optionKeys[_currentHighlight]) {
          comm.console.setForegroundColor(ConsoleColor.white);
          comm.console.setBackgroundColor(ConsoleColor.red);
        } else if (item.key == optionKeys[_currentHighlight]) {
          comm.console.setBackgroundExtendedColor(highlightColor); // Sets selected highlight color when exit button no selected.
        }

        final optionLength = item.key.length;

        comm.console.setTextStyle(bold: true);
        comm.console.write(item.key.padLeft(optionLength + 2).padRight(optionLength + 4));
        comm.console.writeLine();
        comm.console.resetColorAttributes();
      }

      key = comm.console.readKey();
      // Checking for control combination
      selection = shortcuts(key);

      switch (key.controlChar) {
        case ControlCharacter.arrowDown:
          _currentHighlight++;
          comm.console.clearScreen();
          break;
        case ControlCharacter.arrowUp:
          _currentHighlight--;
          comm.console.clearScreen();
          break;
        case ControlCharacter.enter:
          selection = menuOptions[optionKeys[_currentHighlight]];
          comm.console.clearScreen();
          break;
        default:
          comm.console.clearScreen();
          break;
      }
    }

    comm.console.showCursor();

    return selection;
  }

}