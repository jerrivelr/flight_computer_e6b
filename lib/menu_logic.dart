import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:intl/intl.dart';

enum InputType {
  temperature,
  dewpoint,
  indicatedAlt,
  baro,
  distance,
  time,
  calibratedAir,
  pressureAlt,
  windDirection,
  windSpeed,
  runway,
  trueCourse,
  trueAirspeed,
}

class MenuLogic {

  static final console = Console();
  // List of possible options while inside a certain screen.
  static const optionList = ['menu', 'exit', 'opt1', 'opt2', 'opt3', 'opt4', 'opt5', 'opt6', 'opt7'];
  // Stores all the names of all inputs.
  static const inputNames = {
    'temp': 'Temperature °C: ',
    'dew': 'Dewpoint °C: ',
    'IALT': 'Indicated Altitude (ft): ',
    'baro': 'Baro (In Hg): ',
    'distance': 'Distance (nm): ',
    'time': 'Time (hr): ',
    'calibratedAir': 'Calibrated Airspeed (kt): ',
    'pressureAlt': 'Pressure Altitude (ft): ',
    'windDirection': 'Wind Direction°: ',
    'windSpeed': 'Wind Speed (kt): ',
    'runway': 'Runway°: ',
    'autofill': 'Autofill previously calculated/entered values: [Y] yes ——— [N] no (any key)?',
    'trueCourse' : 'Course°: ',
    'trueAirspeed': 'True Airspeed (kt): ',
  };

  // Stores all user inputs
  static String? userInput;
  // Stores values that are part of the optionList if userInput equals to one of the options
  static String? selectedOption;
  // Stores errors messages if any.
  static var error = '';
  // To check the screen has been clear
  static var screenCleared = false;
  // This Map will contain the calculated data for reuse in other options.
  static Map<String, num> dataResult = {};
  // The condition of the while loop inside optionLogic method
  static var condition = optionList.contains(userInput?.toLowerCase().trim());


  MenuLogic({
    required this.variable,
    required this.optionName,
    required this.inCaseInvalid,
    this.autofillText = '',
    this.ifNegative = '',
    this.checkNegative = false,
    this.checkWindDir = false,
    this.checkTrueDir = false,
    this.checkRunway = false,
  });

  double? variable;
  String optionName;
  String inCaseInvalid;
  String autofillText;
  String ifNegative;
  bool checkNegative;
  bool checkWindDir;
  bool checkTrueDir;
  bool checkRunway;

  factory MenuLogic.screenType(InputType t, double? variable) {
    switch (t) {
      case InputType.temperature:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['temp']!,
            inCaseInvalid: 'Invalid Temperature',
            autofillText: 'Temperature: ${MenuLogic.formatNumber(variable ?? 0)}°C '
        );
      case InputType.dewpoint:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['dew']!,
            inCaseInvalid: 'Invalid Dewpoint',
            autofillText: 'Dewpoint: ${MenuLogic.formatNumber(variable ?? 0)}°C'
        );
      case InputType.indicatedAlt:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['IALT']!,
            inCaseInvalid: 'Invalid Altitude',
            checkNegative: true,
            ifNegative: 'Altitude must be positive',
            autofillText: 'Indicated Altitude: ${MenuLogic.formatNumber(variable ?? 0)}ft'
        );
      case InputType.baro:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['baro']!,
            inCaseInvalid: 'Invalid Altimeter',
            checkNegative: true,
            ifNegative: 'Altimeter setting must be positive',
            autofillText: 'Baro: ${MenuLogic.formatNumber(variable ?? 0)} InHg'
        );
      case InputType.distance:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['distance']!,
            inCaseInvalid: 'Invalid Distance',
            checkNegative: true,
            ifNegative: 'Distance must be positive',
            autofillText: 'Distance: ${MenuLogic.formatNumber(variable ?? 0)}nm'
        );
      case InputType.time:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['time']!,
            inCaseInvalid: 'Invalid Time. Ex. 1.5.',
            checkNegative: true,
            ifNegative: 'Time must be positive',
            autofillText: 'Temperature: ${MenuLogic.formatNumber(variable ?? 0)}hr'
        );
      case InputType.calibratedAir:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['calibratedAir']!,
            inCaseInvalid: 'Invalid Calibrated Airspeed',
            checkNegative: true,
            ifNegative: 'Calibrated Airspeed must be positive',
            autofillText: 'Calibrated Airspeed: ${MenuLogic.formatNumber(variable ?? 0)}kt'
        );
      case InputType.pressureAlt:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['pressureAlt']!,
            inCaseInvalid: 'Invalid Pressure Altitude',
            checkNegative: true,
            ifNegative: 'Pressure Altitude must be positive',
            autofillText: 'Pressure Altitude: ${MenuLogic.formatNumber(variable ?? 0)}ft'
        );
      case InputType.windDirection:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['windDirection']!,
            inCaseInvalid: 'Invalid Wind Direction',
            checkWindDir: true,
            checkNegative: true,
            ifNegative: 'Wind Direction must be possible',
            autofillText: 'Wind Direction: ${MenuLogic.formatNumber(variable ?? 0)}°'
        );
      case InputType.windSpeed:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['windSpeed']!,
            inCaseInvalid: 'Invalid Wind Speed',
            checkNegative: true,
            ifNegative: 'Wind Speed must be positive',
            autofillText: 'Wind Speed: ${MenuLogic.formatNumber(variable ?? 0)}kt'
        );
      case InputType.runway:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['runway']!,
            inCaseInvalid: 'Invalid Runway',
            checkRunway: true,
            autofillText: 'Runway ${MenuLogic.formatNumber(variable ?? 0)}'
        );
      case InputType.trueCourse:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['trueCourse']!,
            inCaseInvalid: 'Invalid Course',
            checkTrueDir: true,
            checkNegative: true,
            ifNegative: 'The Course must be positive',
            autofillText: 'Course: ${MenuLogic.formatNumber(variable ?? 0)}°'
        );
      case InputType.trueAirspeed:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['trueAirspeed']!,
            inCaseInvalid: 'Invalid True Airspeed',
            checkNegative: true,
            ifNegative: 'True Airspeed must be positive',
            autofillText: 'True Airspeed: ${MenuLogic.formatNumber(variable ?? 0)}kt'
        );
    }
  }

  double? optionLogic() {
    while (!condition) {
      if (variable == null) {
        userInput = _inputChecker(optionName, ifInvalid: inCaseInvalid);

        if (userInput == inCaseInvalid) {
          error = userInput!;
          break;

        } else if (optionList.contains(userInput!)) {
          console.clearScreen();
          selectedOption = userInput;
          error = '';
          break;

        } else if (checkNegative && double.tryParse(userInput!)! < 0) {
          error = ifNegative;
          break;

        } else if (checkWindDir && _directionCheck(userInput!, 'Wind Direction must be between 0° — 360°')) {
          break;

        } else if (checkTrueDir && _directionCheck(userInput!, 'The Course must be between 0° — 360°')) {
          break;

        } else if (checkRunway && _runwayCheck(userInput!)) {
          break;
        }

        error = '';
        selectedOption = null;
        // To indicate the screen will be refresh
        screenCleared = true;
        variable = double.tryParse(userInput!);

        return variable;

      } else {
        console.writeLine(autofillText);
        return variable;
      }
    }

    return null;
  }

  static bool checkValueExits(List<bool> listOfConditions) {
    if (listOfConditions.contains(true)) {
      console.setTextStyle(italic: true);
      console.writeLine('Autofill previously calculated/input values: [Y] yes ——— [N] no (any key)?');
      MenuLogic.userInput = input(': ')?.toLowerCase();

      console.clearScreen();
      if (MenuLogic.userInput == 'y' || MenuLogic.userInput == 'yes') {
        MenuLogic.userInput = null;
        return true;
      }
    }

    return false;
  }

  static bool backToMenu() {
    console.setTextStyle(italic: true);
    console.writeLine('Back to main menu: [Y] yes (any key) ——— [N] no?');
    userInput = input(': ')?.toLowerCase().trim();

    if (userInput == 'n' || userInput == 'no') {
      error = '';
      return false;
    }

    selectedOption = 'menu';
    console.clearScreen();
    return true;
  }

  static String formatNumber(num number) {
    final myFormat = NumberFormat.decimalPattern('en_us');

    if (number == number.toInt()) {
      return myFormat.format(number); // Omit decimal point and trailing zeros for integers
    }

    return myFormat.format(number); // Keep decimal point for non-integer numbers

  }

  static bool repeatLoop(double? number) {
    // Make sure the input value is not null and that the screen is refreshed.
    if (MenuLogic.screenCleared || number == null) {
      MenuLogic.screenCleared = false;
      console.clearScreen();
      return true;
    }

    return false;
  }

  static void screenHeader({required String title, int color = 22, bool errorWindow = true}) {
    console.setBackgroundExtendedColor(color);
    console.setForegroundColor(ConsoleColor.white);
    console.setTextStyle(bold: true, italic: true);

    console.writeLine(title, TextAlignment.center);

    console.resetColorAttributes();
    if (errorWindow) {
      _errorMessage(error);
    }

    console.setForegroundColor(ConsoleColor.white);
    console.setTextStyle(bold: true);
  }

  static void _errorMessage(String message) {
    final console = Console();

    console.setForegroundColor(ConsoleColor.red);
    console.setTextStyle(bold: true, italic: true, blink: true);
    console.writeLine(message);

    console.resetColorAttributes();
  }

  String? _inputChecker(String printOut, {String ifInvalid = 'Invalid number'}) {
    final digitChecker = RegExp(r'^\d{1,6}$');

    String? userInput;

    // Make sure the input lowercase.
    userInput = input(printOut)?.toLowerCase();

    if (optionList.contains(userInput)) {
      return userInput;
    } else if (!digitChecker.hasMatch(userInput ?? '')) {
      return ifInvalid;
    }

    return userInput;
  }

  bool _runwayCheck(String numberStr) {
    final numberInt = int.tryParse(numberStr);

    if (numberInt == null) {
      error = 'Runway number must be whole numbers (ex. 24, 36, 15)';
      return true;
    } else if (numberInt > 36) {
      error = 'Runway number must be between 0 — 36';
      return true;
    } else if (numberInt < 0) {
      error = 'Runway number must be positive';
      return true;
    }

    return false;
  }

  bool _directionCheck(String numberStr, String errorMessage) {
    final numberDouble = double.tryParse(numberStr);
    if (numberDouble! > 360) {
      error = errorMessage;
      return true;
    }

    return false;
  }



}
