import 'package:yaml/yaml.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

String? temperatureUnit() {
  comm.updateYamlFile();

  final tempMapBool = comm.settingDecoded?['selected_unit']['Temperature'] as YamlMap?;
  final tempUnits = comm.unitDecoded?['Temperature'] as YamlMap?;

  if (tempMapBool != null && tempUnits != null) {
    for (final item in tempMapBool.entries) {
        if (item.value == true) {
          return ' ${tempUnits[item.key]}';
        }
      }
  }

  return null;
}

String? altitudeUnit() {
  comm.updateYamlFile();

  final altMapBool = comm.settingDecoded?['selected_unit']['Altitude'] as YamlMap?;
  final altUnits = comm.unitDecoded?['Altitude'] as YamlMap?;

  if (altMapBool != null && altUnits != null) {
    for (final item in altMapBool.entries) {
      if (item.value == true) {
        return ' ${altUnits[item.key]}';
      }
    }
  }

  return null;
}

String? speedUnit() {
  comm.updateYamlFile();

  final speedMapBool = comm.settingDecoded?['selected_unit']['Speed'] as YamlMap?;
  final speedUnits = comm.unitDecoded?['Speed'] as YamlMap?;

  if (speedMapBool != null && speedUnits != null) {
    for (final item in speedMapBool.entries) {
      if (item.value == true) {
        return ' ${speedUnits[item.key]}';
      }
    }
  }

  return null;
}

String? distanceUnit() {
  comm.updateYamlFile();

  final disMapBool = comm.settingDecoded?['selected_unit']['Distance'] as YamlMap?;
  final disUnits = comm.unitDecoded?['Distance'] as YamlMap?;

  if (disMapBool != null && disUnits != null) {
    for (final item in disMapBool.entries) {
      if (item.value == true) {
        return ' ${disUnits[item.key]}';
      }
    }
  }

  return null;
}

String? timeUnit() {
  comm.updateYamlFile();

  final timeMapBool = comm.settingDecoded?['selected_unit']['Time'] as YamlMap?;
  final timeUnits = comm.unitDecoded?['Time'] as YamlMap?;

  if (timeMapBool != null && timeUnits != null) {
    for (final item in timeMapBool.entries) {
      if (item.value == true) {
        return ' ${timeUnits[item.key]}';
      }
    }
  }

  return null;
}

String? pressUnit() {
  comm.updateYamlFile();

  final pressMapBool = comm.settingDecoded?['selected_unit']['Pressure'] as YamlMap?;
  final pressUnits = comm.unitDecoded?['Pressure'] as YamlMap?;

  if (pressMapBool != null && pressUnits != null) {
    for (final item in pressMapBool.entries) {
      if (item.value == true) {
        return ' ${pressUnits[item.key]}';
      }
    }
  }

  return null;
}

String? weightUnit() {
  comm.updateYamlFile();

  final weightMapBool = comm.settingDecoded?['selected_unit']['Fuel Weight'] as YamlMap?;
  final weightUnits = comm.unitDecoded?['Fuel Weight'] as YamlMap?;

  if (weightMapBool != null && weightUnits != null) {
    for (final item in weightMapBool.entries) {
      if (item.value == true) {
        return ' ${weightUnits[item.key]}';
      }
    }
  }

  return null;
}

String? fuelRateUnit() {
  comm.updateYamlFile();

  final rateMapBool = comm.settingDecoded?['selected_unit']['Fuel Rate'] as YamlMap?;
  final rateUnits = comm.unitDecoded?['Fuel Rate'] as YamlMap?;

  if (rateMapBool != null && rateUnits != null) {
    for (final item in rateMapBool.entries) {
      if (item.value == true) {
        return ' ${rateUnits[item.key]}';
      }
    }
  }

  return null;
}

String? fuelUnit() {
  comm.updateYamlFile();

  final fuelMapBool = comm.settingDecoded?['selected_unit']['Fuel Volume'] as YamlMap?;
  final fuelUnits = comm.unitDecoded?['Fuel Volume'] as YamlMap?;

  if (fuelMapBool != null && fuelUnits != null) {
    for (final item in fuelMapBool.entries) {
      if (item.value == true) {
        return ' ${fuelUnits[item.key]}';
      }
    }
  }

  return null;
}

String? fuelTypeSel() {
  comm.updateYamlFile();

  final fuelMapBool = comm.settingDecoded?['selected_unit']['Fuel Type'] as YamlMap?;
  final fuelUnits = comm.unitDecoded?['Fuel Type'] as YamlMap?;

  if (fuelMapBool != null && fuelUnits != null) {
    for (final item in fuelMapBool.entries) {
      if (item.value == true) {
        return ' ${fuelUnits[item.key]}';
      }
    }
  }

  return null;
}