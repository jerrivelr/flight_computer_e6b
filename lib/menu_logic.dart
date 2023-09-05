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
  fuelVolume,
  fuelRate,

}

class MenuLogic {

  static final console = Console();
  // List of possible options while inside a certain screen.
  static const optionList = ['opt1', 'opt2', 'opt3', 'opt4', 'opt5', 'opt6', 'opt7', 'menu', 'exit'];
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
    'fuelVolume': 'Fuel Volume (Gal): ',
    'fuelRate': 'Fuel Rate (Gal/hr): ',

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
    this.digitLimit = 5,
    this.ifDigitLimit = 'Invalid number',
    this.autofillText = '',
    this.ifNegative = '',
    this.checkNegative = false,
    this.checkWindDir = false,
    this.checkTrueDir = false,
    this.checkRunway = false,
  });

  double? variable;
  int digitLimit;
  String optionName;
  String inCaseInvalid;
  String autofillText;
  String ifNegative;
  String ifDigitLimit;
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
            digitLimit: 3,
            ifDigitLimit: 'Temperature must be between (-999°C) — (999°C)',
            autofillText: 'Temperature: ${MenuLogic.formatNumber(variable ?? 0)}°C '
        );
      case InputType.dewpoint:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['dew']!,
            inCaseInvalid: 'Invalid Dewpoint',
            digitLimit: 3,
            ifDigitLimit: 'Dewpoint must be between (-999°C) — (999°C)',
            autofillText: 'Dewpoint: ${MenuLogic.formatNumber(variable ?? 0)}°C'
        );
      case InputType.indicatedAlt:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['IALT']!,
            inCaseInvalid: 'Invalid Indicated Altitude',
            checkNegative: true,
            ifNegative: 'Indicated Altitude must be positive',
            ifDigitLimit: 'Indicated Altitude must less than 100,000ft',
            autofillText: 'Indicated Altitude: ${MenuLogic.formatNumber(variable ?? 0)}ft'
        );
      case InputType.baro:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['baro']!,
            inCaseInvalid: 'Invalid Altimeter',
            checkNegative: true,
            digitLimit: 2,
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
            ifDigitLimit: 'Distance must less than 100,000nm',
            autofillText: 'Distance: ${MenuLogic.formatNumber(variable ?? 0)}nm'
        );
      case InputType.time:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['time']!,
            inCaseInvalid: 'Invalid Time. Ex. 1.5.',
            checkNegative: true,
            digitLimit: 2,
            ifDigitLimit: 'Time must be less 100hr',
            ifNegative: 'Time must be positive',
            autofillText: 'Temperature: ${MenuLogic.formatNumber(variable ?? 0)}hr'
        );
      case InputType.calibratedAir:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['calibratedAir']!,
            inCaseInvalid: 'Invalid Calibrated Airspeed',
            checkNegative: true,
            digitLimit: 3,
            ifDigitLimit: 'Calibrated Airspeed must less than 1,000kt',
            ifNegative: 'Calibrated Airspeed must be positive',
            autofillText: 'Calibrated Airspeed: ${MenuLogic.formatNumber(variable ?? 0)}kt'
        );
      case InputType.pressureAlt:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['pressureAlt']!,
            inCaseInvalid: 'Invalid Pressure Altitude',
            checkNegative: true,
            ifDigitLimit: 'Pressure Altitude must less than 100,000ft',
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
            digitLimit: 3,
            ifDigitLimit: 'Wind Speed must less than 1,000kt',
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
            digitLimit: 3,
            checkNegative: true,
            ifDigitLimit: 'True Airspeed must less than 1,000kt',
            ifNegative: 'True Airspeed must be positive',
            autofillText: 'True Airspeed: ${MenuLogic.formatNumber(variable ?? 0)}kt'
        );
      case InputType.fuelVolume:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['fuelVolume']!,
            inCaseInvalid: 'Invalid Fuel Volume',
            ifDigitLimit: 'Fuel Volume must be less than 100,000 Gal',
            checkNegative: true,
            ifNegative: 'Fuel Volume must be positive',
            autofillText: 'Fuel Volume: ${MenuLogic.formatNumber(variable ?? 0)}Gal'
        );
      case InputType.fuelRate:
        return MenuLogic(
            variable: variable,
            optionName: inputNames['fuelRate']!,
            inCaseInvalid: 'Invalid Fuel Rate',
            digitLimit: 4,
            ifDigitLimit: 'Fuel Rate must be less 10,000 Gal/hr',
            checkNegative: true,
            ifNegative: 'Fuel Rate must be positive',
            autofillText: 'Fuel Rate: ${MenuLogic.formatNumber(variable ?? 0)}Gal/hr'
        );
    }
  }

  double? optionLogic() {
    while (!condition) {
      if (variable == null) {
        userInput = _inputChecker(optionName, ifInvalid: inCaseInvalid, digitAmount: digitLimit, ifDigitLimit: ifDigitLimit);

        if (userInput == inCaseInvalid || userInput == ifDigitLimit) {
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

  static bool backToMenu({String text = 'Back to main menu: [Y] yes (any key) ——— [N] no?', String backMenuSelection = 'menu'}) {
    console.setTextStyle(italic: true);
    console.writeLine(text);
    userInput = input(': ')?.toLowerCase().trim();

    if (userInput == 'n' || userInput == 'no') {
      error = '';
      return false;
    }

    selectedOption = backMenuSelection;
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

  String? _inputChecker(String printOut, {required int digitAmount, String ifDigitLimit = 'Invalid Digit', String ifInvalid = 'Invalid number', }) {
    digitAmount++;
    final digitChecker = RegExp('^-?\\d{$digitAmount,}\$');

    String? userInput;

    // Make sure the input lowercase.
    userInput = input(printOut)?.toLowerCase();

    if (optionList.contains(userInput)) {
      return userInput;
    } else if (double.tryParse(userInput ?? '') == null) {
      return ifInvalid;
    } else if (digitChecker.hasMatch(userInput ?? '')) {
      return ifDigitLimit;
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
