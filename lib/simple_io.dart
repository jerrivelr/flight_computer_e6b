import 'dart:io';

import 'package:characters/characters.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/main_screens/menu_screens.dart';


String? input([String? printOut]) {
  if (printOut != null) {
    stdout.write(printOut);
  }
  console.setForegroundExtendedColor(180);

  final String? userInput = stdin.readLineSync();

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

void errorMessage(String message) {
  final console = Console();

  console.setForegroundColor(ConsoleColor.red);
  console.setTextStyle(bold: true, italic: true, blink: true);
  console.writeLine(message);

  console.resetColorAttributes();
}

void resultPrinter(List<String> displayString) {
  final table = Table()
    ..borderColor = ConsoleColor.green
    ..borderStyle = BorderStyle.rounded
    ..borderType = BorderType.horizontal;

  for (final item in displayString) {
    table.insertRow([item]);
  }

  console.write(table);
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

void printDownData(Map<String, String> data) {
  for (final item in data.entries) {
    console.setForegroundExtendedColor(253);
    console.write(item.key);
    console.setForegroundExtendedColor(180);
    console.write(item.value);
  }
}
