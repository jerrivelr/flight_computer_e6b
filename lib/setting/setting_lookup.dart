import 'dart:io';

import 'package:yaml/yaml.dart';

final settingYaml = File(r'.\setting\setting.yaml').readAsStringSync();
final settingDecoded = loadYaml(settingYaml) as YamlMap;

final unitYaml = File(r'.\setting\units.yaml').readAsStringSync();
final unitDecoded = loadYaml(unitYaml) as YamlMap;

String? temperatureUnit() {
  final tempMapBool = settingDecoded['selected_unit']['temperature'] as YamlMap;
  final tempUnits = unitDecoded['temperature'] as YamlMap;

  for (final item in tempMapBool.keys) {
    if (item.value == true) {
      return tempUnits[item.key];
    }
  }

  return null;
}