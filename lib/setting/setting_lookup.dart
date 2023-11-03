import 'dart:io';

import 'package:yaml/yaml.dart';

YamlMap? settingDecoded;
YamlMap? unitDecoded;

String? temperatureUnit() {
  _updateFile();

  final tempMapBool = settingDecoded?['selected_unit']['temperature'] as YamlMap?;
  final tempUnits = unitDecoded?['temperature'] as YamlMap?;

  if (tempMapBool != null && tempUnits != null) {
    for (final item in tempMapBool.entries) {
        if (item.value == true) {
          return tempUnits[item.key];
        }
      }
  }

  return null;
}

String? altitudeUnit() {
  _updateFile();

  final altMapBool = settingDecoded?['selected_unit']['altitude'] as YamlMap?;
  final altUnits = unitDecoded?['altitude'] as YamlMap?;

  if (altMapBool != null && altUnits != null) {
    for (final item in altMapBool.entries) {
      if (item.value == true) {
        return altUnits[item.key];
      }
    }
  }

  return null;
}

void _updateFile() {
  final settingYaml = File(r'..\lib\setting\setting.yaml').readAsStringSync();
  settingDecoded = loadYaml(settingYaml) as YamlMap;

  final unitYaml = File(r'..\lib\setting\units.yaml').readAsStringSync();
  unitDecoded = loadYaml(unitYaml) as YamlMap;
}