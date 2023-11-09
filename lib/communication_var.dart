import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/enums.dart';
import 'package:yaml/yaml.dart';

final console = Console();

OptionIdent? selectedOption; // Stores values that are part of the optionList if userInput equals to one of the options.
ControlCharacter? unknownInput;
var errorMessage = ''; // Stores errors messages if any.
var inputValues = <InputTitle?, String?>{}; // This Map will contain the calculated data for reuse in other options.
var currentCursorPos = console.cursorPosition;
var currentPosition = 0; // Saves the current input selected

var noInternet = false; // Checks when there is no internet.
var formatError = false; // Checks if there is a format error with the downloaded json.
var handShakeError = false; // Checks if there is a problem during the handShake phase.
var httpError = false; // Checks if there is a problem with http request.
var timeoutError = false; // Checks when the website takes too long to response.

ControlCharacter? keyPressed; // to catch which was pressed

var celsiusTrue = false;
var fahrenheitTrue = false;
var feetTrue = false;
var metersTrue = false;
var inchesMercuryTrue = false;
var millibarsTrue = false;
var knotsTrue = false;
var kilometerHoursTrue = false;
var milesHoursTrue = false;
var disFeetTrue = false;
var disKilometerTrue = false;
var disMetersTrue = false;
var minuteTrue = false;
var secondTrue = false;
var kilogramsTrue = false;
var fuelPoundTrue = false;
var fuelLiterTrue = false;
var jetA = false;
var jetB = false;

YamlMap? settingDecoded;
YamlMap? unitDecoded;

void updateYamlFile() {
  final settingYaml = File(r'..\lib\setting\setting.yaml').readAsStringSync();
  final unitYaml = File(r'..\lib\setting\units.yaml').readAsStringSync();
  settingDecoded = loadYaml(settingYaml);
  unitDecoded = loadYaml(unitYaml);

  celsiusTrue = settingDecoded?['selected_unit']['Temperature']['celsius'] as bool;
  fahrenheitTrue = settingDecoded?['selected_unit']['Temperature']['fahrenheit'] as bool;

  inchesMercuryTrue = settingDecoded?['selected_unit']['Pressure']['inches_of_mercury'] as bool;
  millibarsTrue = settingDecoded?['selected_unit']['Pressure']['millibars'] as bool;

  feetTrue = settingDecoded?['selected_unit']['Altitude']['feet'] as bool;
  metersTrue = settingDecoded?['selected_unit']['Altitude']['meters'] as bool;

  knotsTrue = settingDecoded?['selected_unit']['Speed']['knots'] as bool;
  kilometerHoursTrue = settingDecoded?['selected_unit']['Speed']['kilometer_hours'] as bool;
  milesHoursTrue = settingDecoded?['selected_unit']['Speed']['milesHour'] as bool;

  disFeetTrue = settingDecoded?['selected_unit']['Distance']['dis_feet'] as bool;
  disKilometerTrue = settingDecoded?['selected_unit']['Distance']['kilometers'] as bool;
  disMetersTrue = settingDecoded?['selected_unit']['Distance']['dis_meters'] as bool;

  minuteTrue = settingDecoded?['selected_unit']['Time']['minute'] as bool;
  secondTrue = settingDecoded?['selected_unit']['Time']['seconds'] as bool;

  kilogramsTrue = settingDecoded?['selected_unit']['Fuel Weight']['kilograms'] as bool;

  fuelPoundTrue = settingDecoded?['selected_unit']['Fuel Volume']['fuel_pound'] as bool;
  fuelLiterTrue = settingDecoded?['selected_unit']['Fuel Volume']['fuel_liter'] as bool;

  jetA = settingDecoded?['selected_unit']['Fuel Type']['jet_a'] as bool;
  jetB = settingDecoded?['selected_unit']['Fuel Type']['jet_b'] as bool;
}

