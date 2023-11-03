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

String? speedUnit() {
  _updateFile();

  final speedMapBool = settingDecoded?['selected_unit']['speed'] as YamlMap?;
  final speedUnits = unitDecoded?['speed'] as YamlMap?;

  if (speedMapBool != null && speedUnits != null) {
    for (final item in speedMapBool.entries) {
      if (item.value == true) {
        return speedUnits[item.key];
      }
    }
  }

  return null;
}

String? distanceUnit() {
  _updateFile();

  final disMapBool = settingDecoded?['selected_unit']['distance'] as YamlMap?;
  final disUnits = unitDecoded?['distance'] as YamlMap?;

  if (disMapBool != null && disUnits != null) {
    for (final item in disMapBool.entries) {
      if (item.value == true) {
        return disUnits[item.key];
      }
    }
  }

  return null;
}

String? timeUnit() {
  _updateFile();

  final timeMapBool = settingDecoded?['selected_unit']['time'] as YamlMap?;
  final timeUnits = unitDecoded?['time'] as YamlMap?;

  if (timeMapBool != null && timeUnits != null) {
    for (final item in timeMapBool.entries) {
      if (item.value == true) {
        return timeUnits[item.key];
      }
    }
  }

  return null;
}

String? pressUnit() {
  _updateFile();

  final pressMapBool = settingDecoded?['selected_unit']['pressure'] as YamlMap?;
  final pressUnits = unitDecoded?['pressure'] as YamlMap?;

  if (pressMapBool != null && pressUnits != null) {
    for (final item in pressMapBool.entries) {
      if (item.value == true) {
        return pressUnits[item.key];
      }
    }
  }

  return null;
}

String? weightUnit() {
  _updateFile();

  final weightMapBool = settingDecoded?['selected_unit']['weight'] as YamlMap?;
  final weightUnits = unitDecoded?['weight'] as YamlMap?;

  if (weightMapBool != null && weightUnits != null) {
    for (final item in weightMapBool.entries) {
      if (item.value == true) {
        return weightUnits[item.key];
      }
    }
  }

  return null;
}

String? fuelRateUnit() {
  _updateFile();

  final rateMapBool = settingDecoded?['selected_unit']['fuel_rate'] as YamlMap?;
  final rateUnits = unitDecoded?['fuel_rate'] as YamlMap?;

  if (rateMapBool != null && rateUnits != null) {
    for (final item in rateMapBool.entries) {
      if (item.value == true) {
        return rateUnits[item.key];
      }
    }
  }

  return null;
}

String? fuelUnit() {
  _updateFile();

  final fuelMapBool = settingDecoded?['selected_unit']['fuel_volume'] as YamlMap?;
  final fuelUnits = unitDecoded?['fuel_volume'] as YamlMap?;

  if (fuelMapBool != null && fuelUnits != null) {
    for (final item in fuelMapBool.entries) {
      if (item.value == true) {
        return fuelUnits[item.key];
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