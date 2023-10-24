import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';

OptionIdent? helpScreen() {
  const List<List<Object>>tableContent = [
    ['Main Menu', 'CTRL + N'],
    ['Help/Config', 'F1'],
    ['Cloud Base', 'CTRL + Q'],
    ['Pressure/Density Altitude', 'CTRL + W'],
    ['Ground Speed', 'CTRL + E'],
    ['True Airspeed', 'CTRL + R'],
    ['Wind Component', 'CTRL + T'],
    ['Heading/Wind Correction Angle', 'CTRL + Y'],
    ['Fuel', 'CTRL + U'],
    ['Exit', 'CTRL + F'],
  ];

  final table = Table()
    ..title = 'SHORTCUTS'
    ..titleStyle = FontStyle.bold
    ..headerStyle = FontStyle.bold
    ..headerColor = ConsoleColor.brightWhite
    ..borderColor = ConsoleColor.brightBlack
    ..borderStyle = BorderStyle.bold
    ..insertColumn(header: 'Selection', alignment: TextAlignment.center)
    ..insertColumn(header: 'Keystroke', alignment: TextAlignment.center)
    ..insertRows(tableContent)
    ;

  comm.selectedOption = null;
  while (comm.selectedOption == null) {
    screenHeader(title: 'HELP');

    comm.console.write(table);
    comm.console.writeLine('• Use arrow keys for menu selection');
    comm.console.writeLine('• Only numbers are allowed on most inputs');
    comm.console.writeLine('• Conditions at airport is the only option that allow all characters');
    comm.console.writeLine();

    final helpMenu = {
      'Return to:': null,
      'Help/Config': OptionIdent.helpConfig,
      'Main Menu': OptionIdent.menu
    };
    
    final backOrNot = insideMenus(custom: true, customOptions: helpMenu);
    if (backOrNot == null) continue;
  }

  return comm.selectedOption;
}

OptionIdent? configScreen() {

}