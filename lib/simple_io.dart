import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';

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

void errorMessage(String message) {
  comm.console.setForegroundColor(ConsoleColor.red);
  comm.console.setTextStyle(bold: true, italic: true, blink: true);
  comm.console.writeLine(message);

  comm.console.resetColorAttributes();
}

void resultPrinter(List<String> displayString, {Function? unit}) {
  final table = Table()
    ..borderColor = ConsoleColor.brightGreen
    ..borderStyle = BorderStyle.bold
    ..borderType = BorderType.horizontal;

  Object? displayUnit = (unit != null) ? unit() : '';

  for (final item in displayString) {
    table.insertRow(['$item$displayUnit']);
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
  final yamlFile = File(r'..\lib\setting\setting.yaml').readAsStringSync();
  final yamlDecoded = loadYaml(yamlFile) as Map;
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
