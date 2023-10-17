import 'package:characters/characters.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/read_line_custom.dart';
import 'package:intl/intl.dart';
import 'package:flight_e6b/shortcuts.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

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

double doubleParse(String? displayString, {String? ifInvalid}) {
  var doubleInput = double.tryParse(input(displayString) ?? '');
  while (doubleInput == null) {
    print(ifInvalid);
    var userInput = input(displayString);

    doubleInput = double.tryParse(userInput ?? '');
  }

  return doubleInput;
}

int intParse(String? printout, {String? ifInvalid}) {
  var intInput = int.tryParse(input(printout) ?? '');
  while (intInput == null) {
    print(ifInvalid);
    var userInput = input(printout);

    intInput = int.tryParse(userInput ?? '');
  }

  return intInput;
}

List<String> windComponentString({required double headTail, required double xCross}) {
  final finalString = <String>[];

  if (xCross < 0) {
    finalString.add('Left X Wind: ${xCross.abs().toStringAsFixed(2)}kt');
  } else {
    finalString.add('Right X Wind: ${xCross.toStringAsFixed(2)}kt\n');
  }

  if (headTail < 0) {
    finalString.add('Tailwind: ${headTail.abs().toStringAsFixed(2)}kt');
  } else {
    finalString.add('Headwind: ${headTail.toStringAsFixed(2)}kt');
  }

  return finalString;
}

String formatNumber(num number) {
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

OptionIdent? menuBuilder ({required Map<String, OptionIdent?> menuOptions, String title = '', highlightColor = 94, bool noTitle = false}) {
  final optionKeys = menuOptions.keys.toList();
  comm.console.hideCursor();

  int firstOption;
  if (menuOptions[optionKeys[0]] == null) {
    firstOption = 1;
  } else {
    firstOption = 0;
  }

  int currentHighlight = firstOption; // to know where to put the highlight bar
  Key? key;
  OptionIdent? selection;

  while (selection == null) {
    if (!noTitle) {
      // Creating the title bar.
      screenHeader(title: title, errorWindow: false);
    }

    if (currentHighlight < firstOption) {
      currentHighlight = optionKeys.length - 1;
    } else if (currentHighlight > optionKeys.length - 1) {
      currentHighlight = firstOption;
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
      if (menuOptions[item.key] == OptionIdent.exit && item.key == optionKeys[currentHighlight]) {
        comm.console.setForegroundColor(ConsoleColor.white);
        comm.console.setBackgroundColor(ConsoleColor.red);
      } else if (item.key == optionKeys[currentHighlight]) {
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
        currentHighlight++;
        comm.console.clearScreen();
        break;
      case ControlCharacter.arrowUp:
        currentHighlight--;
        comm.console.clearScreen();
        break;
      case ControlCharacter.enter:
        selection = menuOptions[optionKeys[currentHighlight]];
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

/// Used for printing the results of something
void beautifulPrint(Object input, {String symbol = '='}) {
  final inputString = input.toString();

  if (!inputString.contains('\n')) {
    final linesOfSymbols = symbol * (inputString.length + 4);
    final result =
        '$linesOfSymbols\n'
        '$symbol $input $symbol\n'
        '$linesOfSymbols';
    print(result);

  } else {

    // To construct the final string.
    final totalString = StringBuffer();

    final splitString = inputString.split('\n');
    // Used to store the lengths of the strings in splitString variable.
    final stringLength = <int>[];

    for (final sentence in splitString) {
      stringLength.add(sentence.characters.length);
    }

    // List sorted to find the length of the longest string, which is the last item.
    stringLength.sort();
    final longestString = stringLength.last;

    totalString.write('${symbol * (longestString + 4)}\n');
    for (final sentence in splitString) {
      var whitespaceToAdd = (longestString - 1) - (sentence.characters.length - 2);
      totalString.write('$symbol $sentence${' ' * whitespaceToAdd}$symbol\n');
    }
    totalString.write(symbol * (longestString + 4));

    print(totalString);

  }
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
  comm.console.setBackgroundExtendedColor(color);
  comm.console.setForegroundExtendedColor(253);
  comm.console.setTextStyle(bold: true, italic: true);

  comm.console.writeLine(title, TextAlignment.center);

  comm.console.resetColorAttributes();
  if (errorWindow) {
    errorMessage(comm.error);
  }

  comm.console.setForegroundColor(ConsoleColor.white);
  comm.console.setTextStyle(bold: true);
}
