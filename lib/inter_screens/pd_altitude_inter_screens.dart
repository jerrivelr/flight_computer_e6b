import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/data_parsing/airport_data.dart';
import 'package:flight_e6b/data_parsing/metar_data.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';

String? _airportId;
List<dynamic>? _downloadMetar;
Metar? _metarData;
String? _airpName;
int? _airpElevation;

const options = {
  'Return to:': null,
  'Pressure/Density Altitude Menu': OptionIdent.pressDenAlt,
  'Main Menu': OptionIdent.menu
};

Future<OptionIdent?> conditionsAirportScreen() async {
  comm.selectedOption = null;
  comm.currentPosition = 0;

  //               //                   //
  while(comm.selectedOption == null) {
    screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');

    comm.console.write('Airport: ');
    final cursorPosition = comm.console.cursorPosition;
    comm.console.writeLine('\n');

    // Data for calculation.
    final elevation = _airpElevation?.toDouble();
    final temperature = _metarData?.temperature?.toDouble();
    final dewpoint = _metarData?.dewpoint?.toDouble();
    final altimeter = _metarData?.altimeterInHg?.toDouble();

    printDownData({
      'ID: ': _airportFormat(),
      'METAR: ': '${_metarData?.rawMetar ?? '--'}\n',
      'Elevation: ': '${formatNumber(elevation)} FT\n',
      'Temperature: ': '${formatNumber(temperature)} °C\n',
      'Dewpoint: ': '${formatNumber(dewpoint)} °C\n',
      'Altimeter: ': '${formatNumber(altimeter)} InHg\n'
    }); // Prints downloaded data with colors.

    // Calculated pressure altitude.
    final pressure = pressureAlt(elevation, altimeter);

    // Calculated density altitude
    final density = densityAlt(
        tempC: temperature,
        stationInches: altimeter,
        dewC: dewpoint,
        elevation: elevation
    );

    resultPrinter([
      'Pressure Altitude: ${formatNumber(pressure)} FT',
      'Density Altitude: ${formatNumber(density)} FT']
    );

    final menu = interMenu(comm.currentPosition > 0, options);
    if (menu) continue;

    comm.console.cursorPosition = cursorPosition;
    _airportId = retrieveAirport();

    // Downloads METAR information from the selected airport.
    _downloadMetar = await metar(_airportId);

    _airpName = airportName(_airportId);
    _airpElevation = airportElevation(_airportId);
    _metarData = Metar.fromJson(_downloadMetar);

    if (_invalidAirportFormat(_airportId) && comm.keyPressed != ControlCharacter.arrowDown) {
      // Airport invalid and screens updates.
      comm.currentPosition = 0;
      continue;
    } else if (_airportNotFound(_airpName) && comm.keyPressed != ControlCharacter.arrowDown) {
      // Airport not in the airports.json file
      comm.currentPosition = 0;
      continue;
    }

    // Checks for no internet connection and when the connection comes back.
    if (_checkConnectErrors() && comm.keyPressed != ControlCharacter.arrowDown) {
      comm.currentPosition = 0;
      continue;
    }

    if ((_downloadMetar?.isEmpty ?? false) && comm.keyPressed != ControlCharacter.arrowDown) {
      comm.errorMessage = 'No Weather Information Available for $_airpName';
      comm.currentPosition = 0;

      comm.console.clearScreen();
      continue;
    }

    comm.console.clearScreen();
  }

  // airportId = null;
  return comm.selectedOption;
}

OptionIdent? manualScreen() {
  tp.indiAltInput.firstOption = true;

  double? indicatedAlt = double.tryParse(comm.inputValues[tp.indiAltInput.inputType] ?? '');
  double? pressInHg = double.tryParse(comm.inputValues[tp.altimeterInput.inputType] ?? '');
  double? temperature = double.tryParse(comm.inputValues[tp.tempInput.inputType] ?? '');
  double? dewpoint = double.tryParse(comm.inputValues[tp.dewInput.inputType] ?? '');

  int? pressure;
  int? density;
  comm.currentPosition = 0;
  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');

    tp.indiAltInput.printInput();
    tp.altimeterInput.printInput();
    tp.tempInput.printInput();
    tp.dewInput.printInput();

    // Calculated pressure altitude.
    pressure = pressureAlt(indicatedAlt, pressInHg);
    density = densityAlt(
        tempC: temperature,
        stationInches: pressInHg,
        dewC: dewpoint,
        elevation: indicatedAlt
    );

    comm.inputValues[InputInfo.pressureAlt] = pressure?.toString();

    resultPrinter([
      'Pressure Altitude: ${formatNumber(pressure)} FT',
      'Density Altitude: ${formatNumber(density)} FT'
    ]);

    final menu = interMenu(comm.currentPosition > 3, options);
    if (menu) continue;

    final positions = [
      Coordinate(tp.indiAltInput.row!, tp.indiAltInput.colum!),
      Coordinate(tp.altimeterInput.row!, tp.altimeterInput.colum!),
      Coordinate(tp.tempInput.row!, tp.tempInput.colum!),
      Coordinate(tp.dewInput.row!, tp.dewInput.colum!),
    ];

    pos.changePosition(positions);

    switch (comm.currentPosition) {
      case 0:
        indicatedAlt = tp.indiAltInput.testLogic();
        break;
      case 1:
        pressInHg = tp.altimeterInput.testLogic();
        break;
      case 2:
        temperature = tp.tempInput.testLogic();
        break;
      case 3:
        dewpoint = tp.dewInput.testLogic();
        break;
    }

    if (pos.positionCheck(positions)) continue;
    pos.changePosition(positions);

    comm.console.clearScreen();
  }

  return comm.selectedOption;
}

bool _invalidAirportFormat(String? id) {
  // Airport invalid and screens updates.
  final validAirport = RegExp(r'^\w{3,4}$'); // To check the airport identifier.

  if (validAirport.hasMatch(id ?? '') || (id?.isEmpty ?? true)) {
    return false;
  }
  comm.console.clearScreen();
  comm.errorMessage = 'Enter a valid ICAO/IATA Airport Code';

  return true;
}

String _airportFormat() {
  if (_airportId == null || _airpName == null) {
    return '--\n';
  }

  return '$_airpName ($_airportId)\n';
}
bool _airportNotFound(String? airportName) {

  if (airportName == null && (_airportId?.isNotEmpty ?? false)) {
    comm.console.clearScreen();
    comm.errorMessage = 'Airport Not Found';
    return true;
  }

  return false;
}

bool _checkConnectErrors() {
  if (comm.noInternet) {
    comm.errorMessage = 'Check your internet connection...';
    comm.noInternet = false;
    comm.console.clearScreen();

    return true;
  }  else if (comm.formatError) {
    comm.errorMessage = 'Downloaded data is corrupted. Try another airport or try again.';
    comm.formatError = false;
    comm.console.clearScreen();

    return true;
  } else if (comm.handShakeError) {
    comm.errorMessage = 'There is has been a problem when downloading the data. Try again.';
    comm.handShakeError = false;
    comm.console.clearScreen();

    return true;
  } else if (comm.httpError) {
    comm.errorMessage = 'A problem occurred when downloading the weather data from aviationweather.gov. Try again.';
    comm.httpError = false;
    comm.console.clearScreen();

    return true;
  } else if (comm.timeoutError) {
    comm.errorMessage = 'aviationweather.gov took too long to response. Try again.';
    comm.timeoutError = false;
    comm.console.clearScreen();

    return true;
  }

  comm.errorMessage = '';

  return false;
}
