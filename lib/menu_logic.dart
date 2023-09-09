import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:intl/intl.dart';

enum InputType {
  temperature('Temperature °C: '),
  dewpoint('Dewpoint °C: '),
  indicatedAlt('Indicated Altitude (ft): '),
  baro('Baro (In Hg): '),
  distance('Distance (nm): '),
  time('Time (hr): '),
  calibratedAir('Calibrated Airspeed (kt): '),
  pressureAlt('Pressure Altitude (ft): '),
  windDirection('Wind Direction°: '),
  windSpeed('Wind Speed (kt): '),
  runway('Runway°: '),
  trueCourse('Course°: '),
  trueAirspeed('True Airspeed (kt): '),
  fuelVolume('Fuel Volume (Gal): '),
  fuelRate('Fuel Rate (Gal/hr): ');

  const InputType(this.title);
  final String title;
}

class MenuLogic {
  static final console = Console();
  // List of possible options while inside a certain screen.
  static const optionList = ['opt1', 'opt2', 'opt3', 'opt4', 'opt5', 'opt6', 'opt7', 'menu', 'exit'];

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
    this.invalidDir = '',
    this.checkNegative = false,
    this.checkDir = false,
    this.checkRunway = false,
  });

  double? variable;
  int digitLimit;
  String optionName;
  String inCaseInvalid;
  String autofillText;
  String ifNegative;
  String ifDigitLimit;
  String invalidDir;
  bool checkNegative;
  bool checkDir;
  bool checkRunway;

  factory MenuLogic.screenType(InputType t, double? variable) {
    switch (t) {
      case InputType.temperature:
        return MenuLogic(
            variable: variable,
            optionName: InputType.temperature.title,
            inCaseInvalid: 'Invalid Temperature',
            digitLimit: 3,
            ifDigitLimit: 'Temperature must be between (-999°C) — (999°C)',
            autofillText: 'Temperature: ${MenuLogic.formatNumber(variable ?? 0)}°C '
        );
      case InputType.dewpoint:
        return MenuLogic(
            variable: variable,
            optionName: InputType.dewpoint.title,
            inCaseInvalid: 'Invalid Dewpoint',
            digitLimit: 3,
            ifDigitLimit: 'Dewpoint must be between (-999°C) — (999°C)',
            autofillText: 'Dewpoint: ${MenuLogic.formatNumber(variable ?? 0)}°C'
        );
      case InputType.indicatedAlt:
        return MenuLogic(
            variable: variable,
            optionName: InputType.indicatedAlt.title,
            inCaseInvalid: 'Invalid Indicated Altitude',
            checkNegative: true,
            ifNegative: 'Indicated Altitude must be greater than 0ft',
            ifDigitLimit: 'Indicated Altitude must less than 100,000ft',
            autofillText: 'Indicated Altitude: ${MenuLogic.formatNumber(variable ?? 0)}ft'
        );
      case InputType.baro:
        return MenuLogic(
            variable: variable,
            optionName: InputType.baro.title,
            inCaseInvalid: 'Invalid Altimeter',
            checkNegative: true,
            digitLimit: 2,
            ifNegative: 'Altimeter setting must be greater than 0 InHg',
            autofillText: 'Baro: ${MenuLogic.formatNumber(variable ?? 0)} InHg'
        );
      case InputType.distance:
        return MenuLogic(
            variable: variable,
            optionName: InputType.distance.title,
            inCaseInvalid: 'Invalid Distance',
            checkNegative: true,
            ifNegative: 'Distance must be greater than 0nm',
            ifDigitLimit: 'Distance must less than 100,000nm',
            autofillText: 'Distance: ${MenuLogic.formatNumber(variable ?? 0)}nm'
        );
      case InputType.time:
        return MenuLogic(
            variable: variable,
            optionName: InputType.time.title,
            inCaseInvalid: 'Invalid Time. Ex. 1.5.',
            checkNegative: true,
            digitLimit: 2,
            ifDigitLimit: 'Time must be less 100hr',
            ifNegative: 'Time must be greater than 0 hr',
            autofillText: 'Time: ${MenuLogic.formatNumber(variable ?? 0)} hr'
        );
      case InputType.calibratedAir:
        return MenuLogic(
            variable: variable,
            optionName: InputType.calibratedAir.title,
            inCaseInvalid: 'Invalid Calibrated Airspeed',
            checkNegative: true,
            digitLimit: 3,
            ifDigitLimit: 'Calibrated Airspeed must less than 1,000kt',
            ifNegative: 'Calibrated Airspeed must be greater than 0kt',
            autofillText: 'Calibrated Airspeed: ${MenuLogic.formatNumber(variable ?? 0)}kt'
        );
      case InputType.pressureAlt:
        return MenuLogic(
            variable: variable,
            optionName: InputType.pressureAlt.title,
            inCaseInvalid: 'Invalid Pressure Altitude',
            checkNegative: true,
            ifDigitLimit: 'Pressure Altitude must less than 100,000ft',
            ifNegative: 'Pressure Altitude must be greater than 0ft',
            autofillText: 'Pressure Altitude: ${MenuLogic.formatNumber(variable ?? 0)}ft'
        );
      case InputType.windDirection:
        return MenuLogic(
            variable: variable,
            optionName: InputType.windDirection.title,
            inCaseInvalid: 'Invalid Wind Direction',
            checkDir: true,
            invalidDir: 'Wind Direction must be between 0° — 360°',
            autofillText: 'Wind Direction: ${MenuLogic.formatNumber(variable ?? 0)}°'
        );
      case InputType.windSpeed:
        return MenuLogic(
            variable: variable,
            optionName: InputType.windSpeed.title,
            inCaseInvalid: 'Invalid Wind Speed',
            checkNegative: true,
            digitLimit: 3,
            ifDigitLimit: 'Wind Speed must less than 1,000kt',
            ifNegative: 'Wind Speed must be greater than 0kt',
            autofillText: 'Wind Speed: ${MenuLogic.formatNumber(variable ?? 0)}kt'
        );
      case InputType.runway:
        return MenuLogic(
            variable: variable,
            optionName: InputType.runway.title,
            inCaseInvalid: 'Invalid Runway',
            checkRunway: true,
            autofillText: 'Runway ${MenuLogic.formatNumber(variable ?? 0)}'
        );
      case InputType.trueCourse:
        return MenuLogic(
            variable: variable,
            optionName: InputType.trueCourse.title,
            inCaseInvalid: 'Invalid Course',
            checkDir: true,
            invalidDir: 'The Course must be between 0° — 360°',
            autofillText: 'Course: ${MenuLogic.formatNumber(variable ?? 0)}°'
        );
      case InputType.trueAirspeed:
        return MenuLogic(
            variable: variable,
            optionName: InputType.trueAirspeed.title,
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
            optionName: InputType.fuelVolume.title,
            inCaseInvalid: 'Invalid Fuel Volume',
            ifDigitLimit: 'Fuel Volume must be less than 100,000 Gal',
            checkNegative: true,
            ifNegative: 'Fuel Volume must be positive',
            autofillText: 'Fuel Volume: ${MenuLogic.formatNumber(variable ?? 0)} Gal'
        );
      case InputType.fuelRate:
        return MenuLogic(
            variable: variable,
            optionName: InputType.fuelRate.title,
            inCaseInvalid: 'Invalid Fuel Rate',
            digitLimit: 4,
            ifDigitLimit: 'Fuel Rate must be less 10,000 Gal/hr',
            checkNegative: true,
            ifNegative: 'Fuel Rate must be greater than 0 Gal/hr',
            autofillText: 'Fuel Rate: ${MenuLogic.formatNumber(variable ?? 0)} Gal/hr'
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

        } else if (checkNegative && double.tryParse(userInput!)! <= 0) {
          error = ifNegative;
          break;

        } else if (checkDir && _directionCheck(userInput!, invalidDir)) {
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
    if (numberDouble! < 0 || numberDouble > 360) {
      error = errorMessage;
      return true;
    }

    return false;
  }



}
