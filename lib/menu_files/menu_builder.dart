import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/shortcuts.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

class MenuBuilder {
  MenuBuilder({
    this.menuOptions = const {'Return to:': null, 'Back to Main Menu': OptionIdent.menu},
    this.highlightColor = 94, this.title = '',
    this.noTitle = false, this.errorWindow = false
  });

  Map<String, OptionIdent?> menuOptions;
  int highlightColor;
  String title;
  bool noTitle;
  bool errorWindow;

  int _firstOption = 0;
  int _currentHighlight = 0;
  int _currentHighlightReturn = 1;

  OptionIdent? mainMenu() {
    comm.console.hideCursor();
    final optionKeys = menuOptions.keys.toList();

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
        screenHeader(title: title, errorWindow: errorWindow);
      }

      if (_currentHighlight < _firstOption) {
        _currentHighlight = optionKeys.length - 1;
      } else if (_currentHighlight > optionKeys.length - 1) {
        _currentHighlight = _firstOption;
      }

      _drawMenuOptions(_currentHighlight);

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
        case ControlCharacter.unknown:
          comm.console.clearScreen();
          comm.unknownInput = key.controlChar;
          comm.errorMessage = 'Invalid value';
          comm.selectedOption = OptionIdent.menu;
        default:
          comm.console.clearScreen();
          break;
      }
    }

    comm.console.showCursor();

    return selection;
  }

  bool returnMenu(bool condition) {
    final optionKeys = menuOptions.keys.toList();

    if (_currentHighlightReturn < 1) {
      _currentHighlightReturn = menuOptions.length - 1;
    } else if (_currentHighlightReturn > menuOptions.length - 1) {
      _currentHighlightReturn = 1;
    }

    _drawMenuOptions(_currentHighlightReturn, condition);

    if (condition) {
      comm.console.hideCursor();

      var key = comm.console.readKey();
      shortcuts(key);

      switch (key.controlChar) {
        case ControlCharacter.arrowDown:
          _currentHighlightReturn++;
          comm.console.clearScreen();
          break;
        case ControlCharacter.arrowUp:
          _currentHighlightReturn--;
          comm.console.clearScreen();
          break;
        case ControlCharacter.enter:
          comm.console.clearScreen();
          comm.console.showCursor();
          comm.selectedOption = menuOptions[optionKeys[_currentHighlightReturn]];
          _currentHighlightReturn = 1;
          return true;
        case ControlCharacter.unknown:
          comm.console.clearScreen();
          comm.unknownInput = key.controlChar;
          comm.errorMessage = 'Invalid value';
          comm.selectedOption = OptionIdent.menu;
          return true;
        default:
          comm.console.clearScreen();
          break;
      }
    }

    if (_currentHighlightReturn > menuOptions.length - 1 ) {
      _currentHighlightReturn = menuOptions.length - 1;
      return true;
    } else if (_currentHighlightReturn < 1) {
      comm.console.showCursor();
      _currentHighlightReturn = 1;

      if (comm.currentPosition > 0) comm.currentPosition--;

      comm.currentCursorPos = Coordinate(comm.currentCursorPos!.row - 1, comm.console.cursorPosition!.col);
      return true;
    } else if (condition && _currentHighlightReturn <= menuOptions.length - 1) {
      return true;
    }

    return false;
  }

  void _drawMenuOptions(int highlightPos, [bool condition = true]) {
    final optionKeys = menuOptions.keys.toList();

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
      if (menuOptions[item.key] == OptionIdent.exit && item.key == optionKeys[highlightPos]) {
        comm.console.setForegroundColor(ConsoleColor.white);
        comm.console.setBackgroundColor(ConsoleColor.red);
      } else if (condition && item.key == optionKeys[highlightPos]) {
        comm.console.setBackgroundExtendedColor(highlightColor); // Sets selected highlight color when exit button no selected.
      }

      final optionLength = item.key.length;

      comm.console.setTextStyle(bold: true);
      comm.console.write(item.key.padLeft(optionLength + 2).padRight(optionLength + 4));
      comm.console.writeLine();
      comm.console.resetColorAttributes();
    }
  }
}