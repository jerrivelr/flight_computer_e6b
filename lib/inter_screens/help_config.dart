import 'dart:io';

import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/shortcuts.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:yaml_modify/yaml_modify.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_files/menu_builder.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

const _helpMenu = {
  'Return to:': null,
  'Help/Settings': OptionIdent.helpSetting,
  'Main Menu': OptionIdent.menu
};

OptionIdent? helpScreen() {
  const List<List<Object>>tableContent = [
    ['Main Menu', 'CTRL + N'],
    ['Help/Settings', 'F1'],
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
    
    final backOrNot = interMenu(true, _helpMenu);
    if (backOrNot) continue;
  }

  return comm.selectedOption;
}

var _currentHighlight = 0;
var _unitSelection = 0;
var _selectedRowKeys = [];
var _selection = <dynamic, dynamic>{};
var _rowSelection = false;
var _returnMenu = false;

OptionIdent? settingScreen() {
  comm.selectedOption = null;
  _currentHighlight = 0;

  while (comm.selectedOption == null) {
    screenHeader(title: 'SETTINGS');

    final settingYaml = File(r'..\lib\setting\setting.yaml').readAsStringSync();
    final unitYaml = File(r'..\lib\setting\units.yaml').readAsStringSync();
    var settingDecoded = loadYaml(settingYaml) as YamlMap?;
    var unitDecoded = loadYaml(unitYaml) as YamlMap?;

    _printSettingTitle('Select Unit:');

    if (settingDecoded != null && unitDecoded != null) {
      comm.console.setForegroundColor(ConsoleColor.white);

      final settingMap = settingDecoded['selected_unit'] as YamlMap;
      final settingKeys = settingMap.keys.toList();

      _highlightControl(settingMap);

      for (var item in unitDecoded.entries) {
        final optionLength = item.key.length;
        final unitTitle = item.key.toString();

        if (item.key == settingKeys[_currentHighlight] && _rowSelection != true && _returnMenu != true) {
          comm.console.setBackgroundExtendedColor(94);
          final unitMap = unitDecoded[item.key] as YamlMap;
          _selectedRowKeys = unitMap.keys.toList();
        }

        comm.console.write('${unitTitle.padLeft(optionLength + 2)}: ');
        comm.console.resetColorAttributes();
        comm.console.write(' ');

        final values = item.value as Map;

        for (var val in values.entries) {
          final unit = val.value.toString().trim();
          final unitPadded = unit.padLeft(unit.length + 2).padRight(unit.length + 4);
          _rowControl(_selectedRowKeys);

          if (_rowSelection && val.key == _selectedRowKeys[_unitSelection] && item.key == settingKeys[_currentHighlight]) {
            comm.console.setBackgroundExtendedColor(239);
            comm.console.write(unitPadded);
            comm.console.resetColorAttributes();
            _selection = {settingKeys[_currentHighlight]: _selectedRowKeys[_unitSelection]};

          } else if (settingMap[item.key][val.key] == true) {
            comm.console.setBackgroundExtendedColor(22);
            comm.console.write(unitPadded);
            comm.console.resetColorAttributes();
          } else {
            comm.console.write(unitPadded);
          }

          comm.console.write('|');
        }

        comm.console.writeLine('');
      }
    }

    final backOrNot = interMenu(_currentHighlight > 9, _helpMenu);
    if (!backOrNot) _keyLogic();
  }

  return comm.selectedOption;
}

void _printSettingTitle(String title) {
  comm.console.setForegroundExtendedColor(180);
  comm.console.setTextStyle(bold: true, italic: true);
  comm.console.writeLine(title);
  comm.console.resetColorAttributes();
}

void _highlightControl(Map map) {
  if (_currentHighlight > map.length - 1) {
    _currentHighlight = map.length - 1;
    _returnMenu = true;
  } else if (_currentHighlight < 0) {
    _currentHighlight = map.length - 1;
  }
}

void _rowControl(List list) {
  if (_unitSelection > list.length - 1) {
    _unitSelection--;
  }
}

void _keyLogic() {
  final key = comm.console.readKey();
  // Checking for control combination
  shortcuts(key);

  switch (key.controlChar) {
    case ControlCharacter.arrowDown:
      if (_rowSelection) {
        _unitSelection = 0;
        _rowSelection = false;
      }

      _currentHighlight++;
      comm.console.clearScreen();
      break;
    case ControlCharacter.arrowUp:
      if (_rowSelection) {
        _unitSelection = 0;
        _rowSelection = false;
      }

      _currentHighlight--;
      comm.console.clearScreen();
      break;
    case ControlCharacter.arrowLeft:
      if (_rowSelection) _unitSelection--;

      if (_unitSelection < 0) {
        _unitSelection = 0;
        _rowSelection = false;
      }
      comm.console.clearScreen();
      break;
    case ControlCharacter.arrowRight:
      if (!_rowSelection) {
        _rowSelection = true;
        comm.console.clearScreen();
        break;
      }

      if (_rowSelection) _unitSelection++;
      comm.console.clearScreen();
      break;
    case ControlCharacter.enter:
      if (!_rowSelection) {
        _rowSelection = true;
      } else {
        _changeSetting();
        _rowSelection = false;
        _unitSelection = 0;
      }

      comm.console.clearScreen();
      break;
    default:
      comm.console.clearScreen();
      break;
  }
}

void _changeSetting() {
  // Unreadable like shit, but works (❁´◡`❁)

  final settingYaml = File(r'..\lib\setting\setting.yaml').readAsStringSync();
  final settingDecoded = loadYaml(settingYaml) as YamlMap?;
  final modifiable = getModifiableNode(settingDecoded) as Map?;

  if (modifiable != null) {
    final loopMap = modifiable['selected_unit'] as Map;

    for (var item in loopMap.entries) {
      final key = item.key;
      final mapValues = loopMap[key] as Map;
      for (var val in mapValues.entries) {
        final value = val.key;
        final finalMap = {key: value};

        if (_selection.values.toString() == finalMap.values.toString()) {
          for (var change in mapValues.entries) {
            modifiable['selected_unit'][key][change.key] = false;
          }

          modifiable['selected_unit'][key][value] = true;
          final strYaml = toYamlString(modifiable);
          File(r'..\lib\setting\setting.yaml').writeAsStringSync(strYaml);
        }
      }
    }
  }
}