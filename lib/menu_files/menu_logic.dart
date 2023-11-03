import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/read_line_custom.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/setting/setting_lookup.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

class MenuLogic {
  MenuLogic({
    required this.optionName,
    required this.inCaseInvalid,
    this.unit = '',
    this.digitLimit = 5,
    this.ifNegative = '',
    this.invalidDir = '',
    this.checkNegative = false,
    this.checkDir = false,
    this.checkRunway = false,
    this.firstOption = false,
    this.unitLookup,
    this.inputType,
  });

  int digitLimit;
  String unit;
  String optionName;
  String inCaseInvalid;
  String ifNegative;
  String invalidDir;
  bool checkNegative;
  bool checkDir;
  bool checkRunway;
  bool firstOption;
  InputInfo? inputType;
  Function? unitLookup;

  var _inputContent = '';

  int? _row = 0;
  int? _colum = 0;
  int? get row => _row;
  int? get colum => _colum;
  Object? _unit;

  factory MenuLogic.screenType(InputInfo type) {
    switch (type) {
      case InputInfo.temperature:
        return MenuLogic(
            optionName: InputInfo.temperature.title,
            inCaseInvalid: 'Invalid Temperature',
            digitLimit: 3,
            unitLookup: temperatureUnit,
            inputType: type
        );
      case InputInfo.dewpoint:
        return MenuLogic(
            optionName: InputInfo.dewpoint.title,
            inCaseInvalid: 'Invalid Dewpoint',
            digitLimit: 3,
            unitLookup: temperatureUnit,
            inputType: type
        );
      case InputInfo.indicatedAlt:
        return MenuLogic(
            optionName: InputInfo.indicatedAlt.title,
            inCaseInvalid: 'Invalid Indicated Altitude',
            checkNegative: true,
            ifNegative: 'Indicated Altitude must be greater than 0ft',
            unit: InputInfo.indicatedAlt.unit,
            inputType: type
        );
      case InputInfo.baro:
        return MenuLogic(
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
            optionName: InputInfo.distance.title,
            inCaseInvalid: 'Invalid Distance',
            checkNegative: true,
            ifNegative: 'Distance must be greater than 0nm',
            unit: InputInfo.distance.unit,
            inputType: type
        );
      case InputInfo.time:
        return MenuLogic(
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
            optionName: InputInfo.pressureAlt.title,
            inCaseInvalid: 'Invalid Pressure Altitude',
            unit: InputInfo.pressureAlt.unit,
            inputType: type
        );
      case InputInfo.windDirection:
        return MenuLogic(
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
            optionName: InputInfo.windSpeed.title,
            inCaseInvalid: 'Invalid Wind Speed',
            checkNegative: true,
            digitLimit: 3,
            unit: InputInfo.windSpeed.unit,
            inputType: type
        );
      case InputInfo.runway:
        return MenuLogic(
            optionName: InputInfo.runway.title,
            inCaseInvalid: 'Invalid Runway',
            checkRunway: true,
            digitLimit: 2,
            unit: InputInfo.runway.unit,
            inputType: type
        );
      case InputInfo.trueCourse:
        return MenuLogic(
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
            optionName: InputInfo.fuelVolume.title,
            inCaseInvalid: 'Invalid Fuel Volume',
            checkNegative: true,
            ifNegative: 'Fuel Volume must be positive',
            unit: InputInfo.fuelVolume.unit,
            inputType: type
        );
      case InputInfo.fuelRate:
        return MenuLogic(
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
            ifNegative: 'Ground Speed must be greater than 0 KT',
            unit: InputInfo.groundSpeed.unit,
            inputType: type
        );
    }
  }

  double? optionLogic() {
    String? userInput;
    userInput = _inputChecker(null, ifInvalid: inCaseInvalid);

    if (userInput == inCaseInvalid) {
      if (comm.errorMessage.isEmpty) {
        comm.currentPosition--;
      }
      comm.errorMessage = userInput!;
      _inputContent = '';
      return null;

    } else if (userInput == null) {
      _inputContent = '';
      comm.inputValues[inputType] = _inputContent;
      return null;
    } else if (checkNegative && double.tryParse(userInput)! < 0) {
      if (comm.errorMessage.isEmpty) {
        comm.currentPosition--;
      }
      comm.errorMessage = ifNegative;
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

    comm.errorMessage = '';
    comm.selectedOption = null;

    // To indicate the screen will be refresh
    comm.screenCleared = true;
    _inputContent = userInput;
    comm.inputValues[inputType] = _inputContent; // Saves the input value for reuse when the option is re access.

    final variable = double.tryParse(userInput);

    return variable;
  }

  void printInput() {
    _inputContent = comm.inputValues[inputType] ?? '';
    _row = comm.console.cursorPosition?.row;
    if (unitLookup != null ) _unit = unitLookup!() ?? '';

    comm.console.setForegroundColor(ConsoleColor.brightWhite);
    if (comm.currentCursorPos?.row == _row || firstOption) {
      firstOption = false;
      comm.console.write(optionName);
      comm.currentCursorPos = Coordinate(_row ?? 0, 0);
    } else {
      comm.console.write(optionName);
      comm.console.setForegroundExtendedColor(180);

      if (_inputContent.isEmpty) {
        comm.console.write('--$_unit');
      } else {
        comm.console.write('$_inputContent${_unit ?? ''}');
      }

      comm.console.resetColorAttributes();
    }

    _colum = comm.console.cursorPosition?.col;
    comm.console.writeLine();
  }

  String? _inputChecker(String? printOut, {String ifInvalid = 'Invalid number', }) {
    String? userInput;
    if (unitLookup != null ) _unit = unitLookup!() ?? '';

    userInput = comm.console.input(printOut, unit: _unit.toString(), inputContent: _inputContent, charLimit: digitLimit)?.toLowerCase();

   if (userInput?.isEmpty ?? false) {
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
      comm.errorMessage = 'Runway number must be whole numbers (ex. 24, 36, 15)';
      return true;
    } else if (numberInt > 36) {
      comm.errorMessage = 'Runway number must be between 0 — 36';
      return true;
    } else if (numberInt < 0) {
      comm.errorMessage = 'Runway number must be positive';
      return true;
    }

    return false;
  }

  bool _directionCheck(String numberStr, String errorMessage) {
    final numberDouble = double.tryParse(numberStr);
    if (numberDouble! < 0 || numberDouble > 360) {
      comm.errorMessage = errorMessage;
      return true;
    }

    return false;
  }
}