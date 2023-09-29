import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

enum InputTitle {
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

  const InputTitle(this.title);
  final String title;
}

enum OptionIdent {
  menu('menu', 'menu'),
  exit('exit', 'exit'),
  cloudBase('cloud base', 'op1'),
  pressDenAlt('altitude', 'op2'),
  airport('airport', 'op2'),
  manual('manual', 'op2'),
  groundSpeed('ground speed', 'op3'),
  trueAirspeed('true airspeed', 'op4'),
  windComp('wind component', 'op5'),
  windCorrection('wind correction', 'op6'),
  fuel('fuel', 'op7'),
  fuelVol('fuel volume', 'op7'),
  fuelDur('fuel duration', 'op7'),
  fuelRate('fuel rate', 'op7');

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
  static String? userInput;
  static var condition = comm.optionList.contains(userInput?.toLowerCase());

  MenuLogic({
    required this.variable,
    required this.optionName,
    required this.inCaseInvalid,
    required this.autofillText,
    this.digitLimit = 5,
    this.ifDigitLimit = 'Invalid number',
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
  String ifNegative;
  String ifDigitLimit;
  String invalidDir;
  Map<String, String> autofillText;
  bool checkNegative;
  bool checkDir;
  bool checkRunway;

  factory MenuLogic.screenType(InputTitle t, double? variable) {
    switch (t) {
      case InputTitle.temperature:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.temperature.title,
            inCaseInvalid: 'Invalid Temperature',
            digitLimit: 3,
            ifDigitLimit: 'Temperature must be between (-999°C) — (999°C)',
            autofillText: {'Temperature: ': '${formatNumber(variable ?? 0)}°C '});
      case InputTitle.dewpoint:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.dewpoint.title,
            inCaseInvalid: 'Invalid Dewpoint',
            digitLimit: 3,
            ifDigitLimit: 'Dewpoint must be between (-999°C) — (999°C)',
            autofillText: {'Dewpoint: ': '${formatNumber(variable ?? 0)}°C'}
        );
      case InputTitle.indicatedAlt:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.indicatedAlt.title,
            inCaseInvalid: 'Invalid Indicated Altitude',
            checkNegative: true,
            ifNegative: 'Indicated Altitude must be greater than 0ft',
            ifDigitLimit: 'Indicated Altitude must less than 100,000ft',
            autofillText: {'Indicated Altitude: ': '${formatNumber(variable ?? 0)}ft'}
        );
      case InputTitle.baro:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.baro.title,
            inCaseInvalid: 'Invalid Altimeter',
            checkNegative: true,
            digitLimit: 2,
            ifNegative: 'Altimeter setting must be greater than 0 InHg',
            autofillText: {'Baro: ': '${formatNumber(variable ?? 0)} InHg'}
        );
      case InputTitle.distance:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.distance.title,
            inCaseInvalid: 'Invalid Distance',
            checkNegative: true,
            ifNegative: 'Distance must be greater than 0nm',
            ifDigitLimit: 'Distance must less than 100,000nm',
            autofillText: {'Distance: ': '${formatNumber(variable ?? 0)}nm'}
        );
      case InputTitle.time:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.time.title,
            inCaseInvalid: 'Invalid Time. Ex. 1.5.',
            checkNegative: true,
            digitLimit: 2,
            ifDigitLimit: 'Time must be less 100hr',
            ifNegative: 'Time must be greater than 0 hr',
            autofillText: {'Time: ': '${formatNumber(variable ?? 0)} hr'}
        );
      case InputTitle.calibratedAir:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.calibratedAir.title,
            inCaseInvalid: 'Invalid Calibrated Airspeed',
            checkNegative: true,
            digitLimit: 3,
            ifDigitLimit: 'Calibrated Airspeed must less than 1,000kt',
            ifNegative: 'Calibrated Airspeed must be greater than 0kt',
            autofillText: {'Calibrated Airspeed: ': '${formatNumber(variable ?? 0)}kt'}
        );
      case InputTitle.pressureAlt:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.pressureAlt.title,
            inCaseInvalid: 'Invalid Pressure Altitude',
            checkNegative: true,
            ifDigitLimit: 'Pressure Altitude must less than 100,000ft',
            ifNegative: 'Pressure Altitude must be greater than 0ft',
            autofillText: {'Pressure Altitude: ': '${formatNumber(variable ?? 0)}ft'}
        );
      case InputTitle.windDirection:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.windDirection.title,
            inCaseInvalid: 'Invalid Wind Direction',
            checkDir: true,
            invalidDir: 'Wind Direction must be between 0° — 360°',
            autofillText: {'Wind Direction: ': '${formatNumber(variable ?? 0)}°'}
        );
      case InputTitle.windSpeed:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.windSpeed.title,
            inCaseInvalid: 'Invalid Wind Speed',
            checkNegative: true,
            digitLimit: 3,
            ifDigitLimit: 'Wind Speed must less than 1,000kt',
            ifNegative: 'Wind Speed must be greater than 0kt',
            autofillText: {'Wind Speed: ': '${formatNumber(variable ?? 0)}kt'}
        );
      case InputTitle.runway:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.runway.title,
            inCaseInvalid: 'Invalid Runway',
            checkRunway: true,
            autofillText: {'Runway ': formatNumber(variable ?? 0)}
        );
      case InputTitle.trueCourse:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.trueCourse.title,
            inCaseInvalid: 'Invalid Course',
            checkDir: true,
            invalidDir: 'The Course must be between 0° — 360°',
            autofillText: {'Course: ': '${formatNumber(variable ?? 0)}°'}
        );
      case InputTitle.trueAirspeed:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.trueAirspeed.title,
            inCaseInvalid: 'Invalid True Airspeed',
            digitLimit: 3,
            checkNegative: true,
            ifDigitLimit: 'True Airspeed must less than 1,000kt',
            ifNegative: 'True Airspeed must be positive',
            autofillText: {'True Airspeed: ': '${formatNumber(variable ?? 0)}kt'}
        );
      case InputTitle.fuelVolume:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.fuelVolume.title,
            inCaseInvalid: 'Invalid Fuel Volume',
            ifDigitLimit: 'Fuel Volume must be less than 100,000 Gal',
            checkNegative: true,
            ifNegative: 'Fuel Volume must be positive',
            autofillText: {'Fuel Volume: ': '${formatNumber(variable ?? 0)} Gal'}
        );
      case InputTitle.fuelRate:
        return MenuLogic(
            variable: variable,
            optionName: InputTitle.fuelRate.title,
            inCaseInvalid: 'Invalid Fuel Rate',
            digitLimit: 4,
            ifDigitLimit: 'Fuel Rate must be less 10,000 Gal/hr',
            checkNegative: true,
            ifNegative: 'Fuel Rate must be greater than 0 Gal/hr',
            autofillText: {'Fuel Rate: ': '${formatNumber(variable ?? 0)} Gal/hr'}
        );
    }
  }

  double? optionLogic() {
    while (!condition) {
      if (variable == null) {
        userInput = _inputChecker(optionName, ifInvalid: inCaseInvalid, digitAmount: digitLimit, ifDigitLimit: ifDigitLimit);

        if (userInput == inCaseInvalid || userInput == ifDigitLimit) {
          comm.error = userInput!;
          break;

        } else if (comm.optionList.contains(userInput!)) {
          comm.console.clearScreen();
          comm.selectedOption = userInput;
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

  String? _inputChecker(String printOut, {required int digitAmount, String ifDigitLimit = 'Invalid Digit', String ifInvalid = 'Invalid number', }) {
    digitAmount++;
    final digitChecker = RegExp('^-?\\d{$digitAmount,}\$');

    String? userInput;

    // Make sure the input lowercase.
    userInput = input(printOut)?.toLowerCase();

    if (comm.optionList.contains(userInput)) {
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

bool checkValueExits(List<bool> listOfConditions) {
  if (listOfConditions.contains(true)) {
    comm.console.setTextStyle(italic: true);
    comm.console.writeLine('Autofill previously calculated/input values: [Y] yes ——— [N] no (any key)?');
    var userInput = input(': ')?.toLowerCase();

    comm.console.clearScreen();
    if (userInput == 'y' || userInput == 'yes') {
      userInput = null;
      return true;
    }
  }

  return false;
}

bool backToMenu({String text = 'Back to main menu: [Y] yes (any key) ——— [N] no?', String backMenuSelection = 'menu'}) {
  comm.console.setTextStyle(italic: true);
  comm.console.writeLine(text);
  final userInput = input(': ')?.toLowerCase().trim();

  if (userInput == 'n' || userInput == 'no') {
    comm.error = '';
    return false;
  }

  comm.selectedOption = backMenuSelection;
  comm.console.clearScreen();
  return true;
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
