import 'dart:io';

import 'package:yaml_modify/yaml_modify.dart';

void unitYamlFile() {
  const content = {
  'Temperature': {'celsius': ' °C', 'fahrenheit': ' °F'},
  'Altitude': {'feet': ' FT', 'meters': ' M'},
  'Speed': {'knots': ' KTS', 'kilometer_hours': ' KPH', 'milesHour': ' MPH'},
  'Distance': {'nautical_miles': ' NM', 'dis_feet': ' FT', 'kilometers': ' KM', 'dis_meters': ' M'},
  'Time': {'hour': ' HR', 'minute': ' MIN', 'seconds': ' SEC'},
  'Pressure': {'inches_of_mercury': ' InHg', 'millibars': ' MB'},
  'Fuel Weight': {'weight_pound': ' LBS', 'kilograms': ' KG'},
  'Fuel Rate': {'fuel_gallon': ' GAL/HR', 'fuel_pound': ' LBS/HR', 'fuel_liter': ' L/HR'},
  'Fuel Volume': {'fuel_gallon': ' GAL', 'fuel_pound': ' LBS', 'fuel_liter': ' L'},
  'Fuel Type': {'avgas': ' AvGas', 'jet_a':  ' Jet A', 'jet_b':   'Jet B}'}
  };

  final cwd = Directory.current.path;
  final unitFile = File('$cwd\\settings\\units.yaml');

  if (!unitFile.existsSync()) {
    final toYaml = toYamlString(content);
    unitFile.createSync(recursive: true);

    unitFile.writeAsStringSync(toYaml);
  }
}

void settingYamlFile() {
  final content = <String, dynamic>{
    'version': '0.7.0',
    'selected_unit': {
      'Temperature': {'celsius': true, 'fahrenheit': false},
      'Altitude': {'feet': true, 'meters': false},
      'Speed': {'knots': true, 'kilometer_hours': false, 'milesHour': false},
      'Distance': {'nautical_miles': true, 'dis_feet': false, 'kilometers': false, 'dis_meters': false},
      'Time': {'hour': true, 'minute': false, 'seconds': false},
      'Pressure': {'inches_of_mercury': true, 'millibars': false},
      'Fuel Weight': {'weight_pound': true, 'kilograms': false},
      'Fuel Rate': {'fuel_gallon': true, 'fuel_pound': false, 'fuel_liter': false},
      'Fuel Volume': {'fuel_gallon': true, 'fuel_pound': false, 'fuel_liter': false},
      'Fuel Type': {'avgas': true, 'jet_a': false, 'jet_b': false}
    }
  };

  final cwd = Directory.current.path;
  final unitFile = File('$cwd\\settings\\setting.yaml');

  if (!unitFile.existsSync()) {
    final toYaml = toYamlString(content);
    unitFile.createSync(recursive: true);

    unitFile.writeAsStringSync(toYaml);
  }
}