import 'package:flight_e6b/simple_io.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

enum InputInfo {
  temperature('Temperature: ', ' °C'),
  dewpoint('Dewpoint: ', ' °C'),
  indicatedAlt('Indicated Altitude: ', ' FT'),
  baro('Baro: ', ' In Hg'),
  distance('Distance: ', ' NM'),
  time('Time: ', ' HR'),
  calibratedAir('Calibrated Airspeed: ', ' KT'),
  pressureAlt('Pressure Altitude: ', ' FT'),
  windDirection('Wind Direction: ', '°'),
  windSpeed('Wind Speed: ', ' KT'),
  runway('Runway: ', '°'),
  trueCourse('Course: ', '°'),
  trueAirspeed('True Airspeed: ', ' KT'),
  fuelVolume('Fuel Volume: ', ' GAL'),
  groundSpeed('Ground Speed: ', ' KT'),
  fuelRate('Fuel Rate: ', ' GAL/HR');

  const InputInfo(this.title, this.unit);
  final String title;
  final String unit;
}

enum OptionIdent {
  helpConfig('helpConfig', 'helpConfig'),
  help('help', 'help'),
  config('config', 'config'),
  menu('menu', 'menu'),
  exit('exit', 'exit'),
  cloudBase('cloud base', 'op1'),
  pressDenAlt('altitude', 'op2'),
  airport('airport', 'op2'),
  manual('manual', 'op2'),
  groundSpeed('ground speed', 'op3'),
  calGroundSpeed('cal gs', 'op3'),
  groundDur('ground dur', 'op3'),
  groundDis('ground dis', 'op3'),
  trueAirspeed('true airspeed', 'op4'),
  windComp('wind component', 'op5'),
  windCorrection('wind correction', 'op6'),
  fuel('fuel', 'op7'),
  fuelVol('fuel volume', 'op7'),
  fuelDur('fuel duration', 'op7'),
  fuelRate('fuel rate', 'op7'),
  yes('yes', 'yes'),
  no('no', 'no');

  const OptionIdent(this.title, this.typedOption);

  final String title;
  final String typedOption;

}

final titles = <String>[for (final item in OptionIdent.values) item.title];
final typed = <String>[for (final item in OptionIdent.values) item.typedOption];

OptionIdent? checkIdent(String? inputString) {
  if (titles.contains(inputString)) {

    for (final item in OptionIdent.values) {
      if (item.title == inputString) {
        return item;
      }
    }

  } else if (typed.contains(inputString)) {

    for (final item in OptionIdent.values) {
      if (item.typedOption == inputString) {
        return item;
      }
    }
  }

  return null;
}

class MenuLogic {
  MenuLogic({
    required this.optionName,
    required this.inCaseInvalid,
    this.unit = '',
    this.autofillText = const {},
    this.variable,
    this.digitLimit = 5,
    this.ifDigitLimit = 'Invalid number',
    this.ifNegative = '',
    this.invalidDir = '',
    this.checkNegative = false,
    this.checkDir = false,
    this.checkRunway = false,
    this.firstOption = false,
    this.inputType
  });

  double? variable; // TODO No longer needed
  int digitLimit;
  String unit;
  String optionName;
  String inCaseInvalid;
  String ifNegative;
  String ifDigitLimit; // TODO No longer needed
  String invalidDir;
  Map<String, String> autofillText; // TODO No longer needed
  bool checkNegative;
  bool checkDir;
  bool checkRunway;
  bool firstOption;
  InputInfo? inputType;

  var _inputContent = '';

  int? _row = 0;
  int? _colum = 0;
  int? get row => _row;
  int? get colum => _colum;

  factory MenuLogic.screenType(InputInfo type, {double? variable}) {
    switch (type) {
      case InputInfo.temperature:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.temperature.title,
            inCaseInvalid: 'Invalid Temperature',
            digitLimit: 3,
            unit: InputInfo.temperature.unit,
            inputType: type
        );
      case InputInfo.dewpoint:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.dewpoint.title,
            inCaseInvalid: 'Invalid Dewpoint',
            digitLimit: 3,
            unit: InputInfo.dewpoint.unit,
            inputType: type
        );
      case InputInfo.indicatedAlt:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.indicatedAlt.title,
            inCaseInvalid: 'Invalid Indicated Altitude',
            checkNegative: true,
            ifNegative: 'Indicated Altitude must be greater than 0ft',
            unit: InputInfo.indicatedAlt.unit,
            inputType: type
        );
      case InputInfo.baro:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.baro.title,
            inCaseInvalid: 'Invalid Altimeter',
            digitLimit: 4,
            checkNegative: true,
            ifNegative: 'Altimeter setting must be greater than 0 InHg',
            unit: InputInfo.baro.unit,
            inputType: type
        );
      case InputInfo.distance:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.distance.title,
            inCaseInvalid: 'Invalid Distance',
            checkNegative: true,
            ifNegative: 'Distance must be greater than 0nm',
            unit: InputInfo.distance.unit,
            inputType: type
        );
      case InputInfo.time:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.time.title,
            inCaseInvalid: 'Invalid Time. Ex. 1.5.',
            checkNegative: true,
            digitLimit: 2,
            ifNegative: 'Time must be greater than 0 hr',
            unit: InputInfo.time.unit,
            inputType: type
        );
      case InputInfo.calibratedAir:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.calibratedAir.title,
            inCaseInvalid: 'Invalid Calibrated Airspeed',
            checkNegative: true,
            digitLimit: 3,
            ifNegative: 'Calibrated Airspeed must be greater than 0kt',
            unit: InputInfo.calibratedAir.unit,
            inputType: type
        );
      case InputInfo.pressureAlt:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.pressureAlt.title,
            inCaseInvalid: 'Invalid Pressure Altitude',
            unit: InputInfo.pressureAlt.unit,
            inputType: type
        );
      case InputInfo.windDirection:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.windDirection.title,
            inCaseInvalid: 'Invalid Wind Direction',
            checkDir: true,
            invalidDir: 'Wind Direction must be between 0° — 360°',
            digitLimit: 3,
            unit: InputInfo.windDirection.unit,
            inputType: type
        );
      case InputInfo.windSpeed:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.windSpeed.title,
            inCaseInvalid: 'Invalid Wind Speed',
            checkNegative: true,
            digitLimit: 3,
            unit: InputInfo.windSpeed.unit,
            inputType: type
        );
      case InputInfo.runway:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.runway.title,
            inCaseInvalid: 'Invalid Runway',
            checkRunway: true,
            digitLimit: 2,
            unit: InputInfo.runway.unit,
            inputType: type
        );
      case InputInfo.trueCourse:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.trueCourse.title,
            inCaseInvalid: 'Invalid Course',
            checkDir: true,
            digitLimit: 3,
            invalidDir: 'The Course must be between 0° — 360°',
            unit: InputInfo.trueCourse.unit,
            inputType: type
        );
      case InputInfo.trueAirspeed:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.trueAirspeed.title,
            inCaseInvalid: 'Invalid True Airspeed',
            digitLimit: 3,
            checkNegative: true,
            ifNegative: 'True Airspeed must be positive',
            unit: InputInfo.trueAirspeed.unit,
            inputType: type
        );
      case InputInfo.fuelVolume:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.fuelVolume.title,
            inCaseInvalid: 'Invalid Fuel Volume',
            checkNegative: true,
            ifNegative: 'Fuel Volume must be positive',
            unit: InputInfo.fuelVolume.unit,
            inputType: type
        );
      case InputInfo.fuelRate:
        return MenuLogic(
            variable: variable,
            optionName: InputInfo.fuelRate.title,
            inCaseInvalid: 'Invalid Fuel Rate',
            digitLimit: 4,
            checkNegative: true,
            ifNegative: 'Fuel Rate must be greater than 0 Gal/hr',
            unit: InputInfo.fuelRate.unit,
            inputType: type
        );
      case InputInfo.groundSpeed:
        return MenuLogic(
            optionName: InputInfo.groundSpeed.title,
            inCaseInvalid: 'Invalid Ground Speed',
            digitLimit: 3,
            checkNegative: true,
            ifNegative: 'Ground must be greater than 0',
            unit: InputInfo.groundSpeed.unit,
            inputType: type
        );
    }
  }

  double? optionLogic() {
    String? userInput;
    while (true) {
      if (variable == null) {
        userInput = _inputChecker(optionName, ifInvalid: inCaseInvalid);

        if (userInput == inCaseInvalid || userInput == ifDigitLimit) {
          comm.error = userInput!;
          break;

        } else if (titles.contains(userInput) || typed.contains(userInput)) {
          comm.console.clearScreen();
          comm.selectedOption = checkIdent(userInput);
          comm.error = '';
          break;

        } else if (checkNegative && double.tryParse(userInput!)! <= 0) {
          comm.error = ifNegative;
          break;

        } else if (checkDir && _directionCheck(userInput!, invalidDir)) {
          break;

        } else if (checkRunway && _runwayCheck(userInput!)) {
          break;
        }

        comm.error = '';
        comm.selectedOption = null;
        // To indicate the screen will be refresh
        comm.screenCleared = true;
        variable = double.tryParse(userInput!);

        return variable;

      } else {
        for (final item in autofillText.entries) {
          comm.console.setForegroundExtendedColor(253);
          comm.console.write(item.key);
          comm.console.setForegroundExtendedColor(180);
          comm.console.write('${item.value}\n');

          comm.console.resetColorAttributes();
        }
        return variable;
      }
    }

    return null;
  }

  double? testLogic() {
    String? userInput;
    userInput = _inputChecker(null, ifInvalid: inCaseInvalid);

    if (userInput == inCaseInvalid) {
      if (comm.error.isEmpty) {
        comm.currentPosition--;
      }
      comm.error = userInput!;
      _inputContent = '';
      return null;

    } else if (userInput == null) {
      _inputContent = '';
      comm.inputValues[inputType] = _inputContent;
      return null;
    } else if (checkNegative && double.tryParse(userInput)! < 0) {
      if (comm.error.isEmpty) {
        comm.currentPosition--;
      }
      comm.error = ifNegative;
      _inputContent = '';
      comm.inputValues[inputType] = _inputContent; // Saves the input value for reuse when the option is re access.
      return null;

    } else if (checkDir && _directionCheck(userInput, invalidDir)) {
      _inputContent = '';
      comm.inputValues[inputType] = _inputContent;
      return null;

    } else if (checkRunway && _runwayCheck(userInput)) {
      _inputContent = '';
      comm.inputValues[inputType] = _inputContent;
      return null;
    }

    comm.error = '';
    comm.selectedOption = null;
    // To indicate the screen will be refresh
    comm.screenCleared = true;
    _inputContent = userInput;
    comm.inputValues[inputType] = _inputContent; // Saves the input value for reuse when the option is re access.
    variable = double.tryParse(userInput);

    return variable;
  }

  void printInput() {
    _inputContent = comm.inputValues[inputType] ?? '';
    _row = comm.console.cursorPosition?.row;

    comm.console.setForegroundColor(ConsoleColor.brightWhite);
    if (comm.currentCursorPos?.row == _row || firstOption) {
      firstOption = false;
      comm.console.write(optionName);
      comm.currentCursorPos = Coordinate(_row ?? 0, 0);
    } else {
      comm.console.write(optionName);
      comm.console.setForegroundExtendedColor(180);

      if (_inputContent.isEmpty) {
        comm.console.write('--$unit');
      } else {
        comm.console.write('$_inputContent$unit');
      }

      comm.console.resetColorAttributes();
    }

    _colum = comm.console.cursorPosition?.col;
    comm.console.writeLine();
  }

  String? _inputChecker(String? printOut, {String ifInvalid = 'Invalid number', }) {
    String? userInput;

    userInput = input(printOut, unit: unit, inputContent: _inputContent, charLimit: digitLimit)?.toLowerCase();

    if (titles.contains(userInput) || typed.contains(userInput)) {
      return userInput;
    } else if (userInput?.isEmpty ?? false) {
      userInput = null;
      return userInput;
    } else if (double.tryParse(userInput ?? '') == null) {
      return ifInvalid;
    }

    return userInput;
  }

  bool _runwayCheck(String numberStr) {
    final numberInt = int.tryParse(numberStr);

    if (numberInt == null) {
      comm.error = 'Runway number must be whole numbers (ex. 24, 36, 15)';
      return true;
    } else if (numberInt > 36) {
      comm.error = 'Runway number must be between 0 — 36';
      return true;
    } else if (numberInt < 0) {
      comm.error = 'Runway number must be positive';
      return true;
    }

    return false;
  }

  bool _directionCheck(String numberStr, String errorMessage) {
    final numberDouble = double.tryParse(numberStr);
    if (numberDouble! < 0 || numberDouble > 360) {
      comm.error = errorMessage;
      return true;
    }

    return false;
  }
}

bool repeatLoop(Object? variable) {
  // Make sure the input value is not null and that the screen is refreshed.
  if (comm.screenCleared || variable == null) {
    comm.screenCleared = false;
    comm.console.clearScreen();
    return true;
  }

  return false;
}
