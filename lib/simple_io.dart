import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/read_line_custom.dart';
import 'package:flight_e6b/shortcuts.dart';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';

String? input(String? printOut, {bool onlyNumbers = true, int charLimit = 10, String inputContent = '', String unit = ''}) {
  if (printOut != null) {
    comm.console.write(printOut);
  }

  comm.console.setForegroundExtendedColor(180);
  final userInput = comm.console.readLineCustom(
      onlyNumbers: onlyNumbers,
      charLimit: charLimit,
      inputContent: inputContent,
      unit: unit
  );

  return userInput?.trim();
}

List<String> windComponentString({required double? headTail, required double? xCross}) {
  final finalString = <String>[];

  if (headTail == null || xCross == null) {
    (xCross == null) ? finalString.add('X Wind: -- KT') : finalString;
    (headTail == null) ? finalString.add('Head/Tail: -- KT') : finalString;

    return finalString;
  }


  if (xCross < 0) {
    finalString.add('Left X Wind: ${formatNumber(xCross)} KT');
  } else {
    finalString.add('Right X Wind: ${formatNumber(xCross)} KT');
  }

  if (headTail < 0) {
    finalString.add('Tailwind: ${formatNumber(headTail)} KT');
  } else {
    finalString.add('Headwind: ${formatNumber(headTail)} KT');
  }

  return finalString;
}

String formatNumber(num? number) {
  final myFormat = NumberFormat.decimalPattern('en_us');

  if (number == null) {
    return '--';
  }
  if (number == number.toInt()) {
    return myFormat.format(number); // Omit decimal point and trailing zeros for integers
  }

  final inDouble = number.toDouble().toStringAsFixed(2); // To return a double with only two decimals.

  return myFormat.format(double.tryParse(inDouble)); // Keep decimal point for non-integer numbers

}

var _currentHighlight = 1;
bool? insideMenus({
  String text = 'Reenter values?',
  String goBack = 'Back to Main Menu',
  OptionIdent backMenuSelection = OptionIdent.menu,
  Map<String, OptionIdent?> customOptions = const {},
  bool autofill = false,
  bool custom = false,

}) {
  OptionIdent? selection;
  comm.console.hideCursor();

  Map<String, OptionIdent?> options;

  if (autofill) {
    options = {
      'Autofill previously calculated/entered values?': null,
      'Yes': OptionIdent.yes,
      'No': OptionIdent.no,
      goBack: backMenuSelection
    };
  } else if (custom) {
    options = customOptions;
  } else if (backMenuSelection != OptionIdent.menu) {
    options = {
      text: null,
      'Yes': OptionIdent.yes,
      goBack: backMenuSelection,
      'Main Menu': OptionIdent.menu
    };
  } else {
    options = {
      text: null,
      'Yes': OptionIdent.yes,
      goBack: backMenuSelection
    };
  }

  final optionKeys = options.keys.toList();

  if (_currentHighlight < 1) {
    _currentHighlight = options.length - 1;
  } else if (_currentHighlight > options.length - 1) {
    _currentHighlight = 1;
  }

  for (var item in options.entries) {
    if (options[item.key] == null) {
      comm.console.setForegroundExtendedColor(180);
      comm.console.setTextStyle(bold: true, italic: true);
      comm.console.writeLine(item.key);
      comm.console.resetColorAttributes();
      continue;
    }

    if (item.key == optionKeys[_currentHighlight]) {
      comm.console.setBackgroundExtendedColor(94);
    }

    final optionLength = item.key.length;

    comm.console.setTextStyle(bold: true);
    comm.console.write(item.key.padLeft(optionLength + 2).padRight(optionLength + 4));
    comm.console.writeLine();
    comm.console.resetColorAttributes();
  }

  var key = comm.console.readKey();

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
      comm.console.clearScreen();
      comm.console.showCursor();
      selection = options[optionKeys[_currentHighlight]];
      _currentHighlight = 0;
      break;
    default:
      comm.console.clearScreen();
      break;
  }

  comm.console.showCursor();

  if (selection == null) return null;

  _currentHighlight = 1;
  if (selection == OptionIdent.yes) {
    return true;
  } else if (selection == OptionIdent.no) {
    return false;
  }

  comm.selectedOption = selection;

  return false;
}

bool interMenu(bool condition, [Map<String, OptionIdent?> options = const {'Return to:': null,'Back to Main Menu': OptionIdent.menu}]) {
  final optionKeys = options.keys.toList();

  if (_currentHighlight < 1) {
    _currentHighlight = options.length - 1;
  } else if (_currentHighlight > options.length - 1) {
    _currentHighlight = 1;
  }

  for (var item in options.entries) {
    if (options[item.key] == null) {
      comm.console.setForegroundExtendedColor(180);
      comm.console.setTextStyle(bold: true, italic: true);
      comm.console.writeLine(item.key);
      comm.console.resetColorAttributes();
      continue;
    }

    if (condition && item.key == optionKeys[_currentHighlight]) {
      comm.console.setBackgroundExtendedColor(94);
    }

    final optionLength = item.key.length;

    comm.console.setTextStyle(bold: true);
    comm.console.write(item.key.padLeft(optionLength + 2).padRight(optionLength + 4));
    comm.console.writeLine();
    comm.console.resetColorAttributes();
  }

  if (condition) {
    OptionIdent? selection;
    comm.console.hideCursor();

    var key = comm.console.readKey();

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
        comm.console.clearScreen();
        comm.console.showCursor();
        comm.selectedOption = options[optionKeys[_currentHighlight]];
        _currentHighlight = 1;
        return true;
      default:
        comm.console.clearScreen();
        break;
    }
  }

  if (_currentHighlight > options.length - 1 ) {
    _currentHighlight = options.length - 1;
    return true;
  } else if (_currentHighlight < 1) {
    comm.console.showCursor();
    _currentHighlight = 1;
    comm.currentPosition--;
    comm.currentCursorPos = Coordinate(comm.currentCursorPos!.row - 1, comm.console.cursorPosition!.col);
    return true;
  } else if (condition && _currentHighlight <= options.length - 1) {
    return true;
  }

  comm.console.showCursor();
  return false;
}

void errorMessage(String message) {
  comm.console.setForegroundColor(ConsoleColor.red);
  comm.console.setTextStyle(bold: true, italic: true, blink: true);
  comm.console.writeLine(message);

  comm.console.resetColorAttributes();
}

void resultPrinter(List<String> displayString) {
  final table = Table()
    ..borderColor = ConsoleColor.brightGreen
    ..borderStyle = BorderStyle.bold
    ..borderType = BorderType.horizontal;

  for (final item in displayString) {
    table.insertRow([item]);
  }

  comm.console.write(table);
}

void printDownData(Map<String, String> data) {
  for (final item in data.entries) {
    comm.console.setForegroundExtendedColor(253);
    comm.console.write(item.key);
    comm.console.setForegroundExtendedColor(180);
    comm.console.write(item.value);
  }
}

void screenHeader({required String title, int color = 22, bool errorWindow = true}) {
  final yamlFile = File(r'C:\Users\jerri\IdeaProjects\flight_e6b\pubspec.yaml');
  final yamlContent = yamlFile.readAsStringSync();
  final yamlDecoded = loadYaml(yamlContent) as Map;
  final versionStr = ' v${yamlDecoded['version']} ';

  final windowWidth = comm.console.windowWidth;
  final windowHalf = (windowWidth / 2) - (title.length / 2);
  final spaces = ' ' * windowHalf.round();

  comm.console.setBackgroundExtendedColor(color);
  comm.console.setForegroundExtendedColor(253);
  comm.console.setTextStyle(bold: true, italic: true);

  comm.console.write(spaces);
  comm.console.write(title);

  final spaceRemanding = windowWidth - spaces.length - title.length - versionStr.length;
  final spaces1 = ' ' * spaceRemanding.round();

  comm.console.write(spaces1);
  comm.console.write(versionStr);
  comm.console.writeLine();

  comm.console.resetColorAttributes();
  if (errorWindow) {
    errorMessage(comm.errorMessage);
  }
}
