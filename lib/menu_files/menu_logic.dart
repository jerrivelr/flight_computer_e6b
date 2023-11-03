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
  InputTitle? inputType;
  Function? unitLookup;

  var _inputContent = '';

  int? _row = 0;
  int? _colum = 0;
  int? get row => _row;
  int? get colum => _colum;
  Object? _unit;

  factory MenuLogic.screenType(InputTitle type) {
    switch (type) {
      case InputTitle.temperature:
        return MenuLogic(
            optionName: InputTitle.temperature.title,
            inCaseInvalid: 'Invalid Temperature',
            digitLimit: 3,
            unitLookup: temperatureUnit,
            inputType: type
        );
      case InputTitle.dewpoint:
        return MenuLogic(
            optionName: InputTitle.dewpoint.title,
            inCaseInvalid: 'Invalid Dewpoint',
            digitLimit: 3,
            unitLookup: temperatureUnit,
            inputType: type
        );
      case InputTitle.indicatedAlt:
        return MenuLogic(
            optionName: InputTitle.indicatedAlt.title,
            inCaseInvalid: 'Invalid Indicated Altitude',
            checkNegative: true,
            ifNegative: 'Indicated Altitude must be greater than 0',
            unitLookup: altitudeUnit,
            inputType: type
        );
      case InputTitle.baro:
        return MenuLogic(
            optionName: InputTitle.baro.title,
            inCaseInvalid: 'Invalid Altimeter',
            digitLimit: 4,
            checkNegative: true,
            ifNegative: 'Altimeter setting must be greater than 0',
            unitLookup: pressUnit,
            inputType: type
        );
      case InputTitle.distance:
        return MenuLogic(
            optionName: InputTitle.distance.title,
            inCaseInvalid: 'Invalid Distance',
            checkNegative: true,
            ifNegative: 'Distance must be greater than 0',
            unitLookup: distanceUnit,
            inputType: type
        );
      case InputTitle.time:
        return MenuLogic(
            optionName: InputTitle.time.title,
            inCaseInvalid: 'Invalid Time. Ex. 1.5.',
            checkNegative: true,
            digitLimit: 2,
            ifNegative: 'Time must be greater than 0 hr',
            unitLookup: timeUnit,
            inputType: type
        );
      case InputTitle.calibratedAir:
        return MenuLogic(
            optionName: InputTitle.calibratedAir.title,
            inCaseInvalid: 'Invalid Calibrated Airspeed',
            checkNegative: true,
            digitLimit: 3,
            ifNegative: 'Calibrated Airspeed must be greater than 0',
            unitLookup: speedUnit,
            inputType: type
        );
      case InputTitle.pressureAlt:
        return MenuLogic(
            optionName: InputTitle.pressureAlt.title,
            inCaseInvalid: 'Invalid Pressure Altitude',
            unitLookup: altitudeUnit,
            inputType: type
        );
      case InputTitle.windDirection:
        return MenuLogic(
            optionName: InputTitle.windDirection.title,
            inCaseInvalid: 'Invalid Wind Direction',
            checkDir: true,
            invalidDir: 'Wind Direction must be between 0° — 360°',
            digitLimit: 3,
            unit: '°',
            inputType: type
        );
      case InputTitle.windSpeed:
        return MenuLogic(
            optionName: InputTitle.windSpeed.title,
            inCaseInvalid: 'Invalid Wind Speed',
            checkNegative: true,
            digitLimit: 3,
            unitLookup: speedUnit,
            inputType: type
        );
      case InputTitle.runway:
        return MenuLogic(
            optionName: InputTitle.runway.title,
            inCaseInvalid: 'Invalid Runway',
            checkRunway: true,
            digitLimit: 2,
            unit: '°',
            inputType: type
        );
      case InputTitle.trueCourse:
        return MenuLogic(
            optionName: InputTitle.trueCourse.title,
            inCaseInvalid: 'Invalid Course',
            checkDir: true,
            digitLimit: 3,
            invalidDir: 'The Course must be between 0° — 360°',
            unit: '°',
            inputType: type
        );
      case InputTitle.trueAirspeed:
        return MenuLogic(
            optionName: InputTitle.trueAirspeed.title,
            inCaseInvalid: 'Invalid True Airspeed',
            digitLimit: 3,
            checkNegative: true,
            ifNegative: 'True Airspeed must be positive',
            unitLookup: speedUnit,
            inputType: type
        );
      case InputTitle.fuelVolume:
        return MenuLogic(
            optionName: InputTitle.fuelVolume.title,
            inCaseInvalid: 'Invalid Fuel Volume',
            checkNegative: true,
            ifNegative: 'Fuel Volume must be positive',
            unitLookup: fuelUnit,
            inputType: type
        );
      case InputTitle.fuelRate:
        return MenuLogic(
            optionName: InputTitle.fuelRate.title,
            inCaseInvalid: 'Invalid Fuel Rate',
            digitLimit: 4,
            checkNegative: true,
            ifNegative: 'Fuel Rate must be greater than 0 Gal/hr',
            unitLookup: fuelRateUnit,
            inputType: type
        );
      case InputTitle.groundSpeed:
        return MenuLogic(
            optionName: InputTitle.groundSpeed.title,
            inCaseInvalid: 'Invalid Ground Speed',
            digitLimit: 3,
            checkNegative: true,
            ifNegative: 'Ground Speed must be greater than 0',
            unitLookup: speedUnit,
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
    _unit = (unitLookup != null) ? unitLookup!() : unit;

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
    _unit = (unitLookup != null) ? unitLookup!() : unit;

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