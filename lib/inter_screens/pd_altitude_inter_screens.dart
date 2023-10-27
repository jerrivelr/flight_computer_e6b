import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/communication_var.dart' as comm;
import 'package:flight_e6b/cursor_position.dart' as pos;
import 'package:flight_e6b/data_parsing/airport_data.dart';
import 'package:flight_e6b/data_parsing/metar_data.dart';
import 'package:flight_e6b/input_type.dart' as tp;
import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';

String? airportId;
bool missingValue = true;

Future<OptionIdent?> conditionsAirportScreen() async {
  comm.console.showCursor();

  List<dynamic>? downloadMetar;
  Metar? metarData;

  comm.selectedOption = null;
  comm.screenCleared = true;

  //               //                   //
  while(comm.selectedOption == null) {
    screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');

    airportId ??= retrieveAirport();

    if (airportId == null) {
      comm.console.clearScreen();
      comm.errorMessage = '';
      return comm.selectedOption;
    }

    final airpName = airportName(airportId);
    final airpElevation = airportElevation(airportId);

    if (_invalidAirportFormat(airportId)) {
      // Airport invalid and screens updates.
      airportId = null;
      continue;

    } else if (_airportNotFound(airpName)) {
      // Airport not in the airports.json file
      airportId = null;
      continue;

    } else if (repeatLoop(airportId)) {
      // Makes one loop to redraw the screen.
      comm.console.clearScreen();
      comm.screenCleared = false;
      comm.errorMessage = '';
      continue;
    }

    // Downloads METAR information from the selected airport.
    downloadMetar ??= await metar(airportId);
    // downloadMetar ??= testMetar();

    // This is to display the downloading screen when downloading process.
    if (comm.screenCleared) {
      comm.screenCleared = false;
      comm.errorMessage = '';
      continue;
    }

    // Checks for no internet connection and when the connection comes back.
    if (_checkConnectErrors()) continue;

    if (downloadMetar?.isEmpty ?? false) {
      comm.errorMessage = 'No Weather Information Available for $airpName';
      airportId = null;
      downloadMetar = null;

      comm.screenCleared = true;
      comm.console.clearScreen();
      continue;
    }

    // Makes a map with all downloaded METAR data from easier access.
    metarData ??= Metar.fromJson(downloadMetar!);
    //               //             //            //                //

    // This is in the rare case temperature, dewpoint, or altimeter are missing from the download.
    if (metarData.temperature == null) {
      final tempInput = MenuLogic.screenType(InputInfo.temperature, variable: metarData.temperature?.toDouble());
      comm.errorMessage = 'Temperature is missing from download. Type it out.';

      if (_repeatIfMissingValue()) continue;

      metarData.temperature = tempInput.optionLogic();
      if (repeatLoop(metarData.temperature)) continue;

      continue;

    } else if (metarData.dewpoint == null || metarData.dewpoint! > metarData.temperature!) {

      final dewInput = MenuLogic.screenType(InputInfo.dewpoint, variable: metarData.dewpoint?.toDouble());
      comm.errorMessage = 'Dewpoint is missing from download. Make sure dewpoint is less than or equal to temperature (${metarData.temperature}°C).';

      if (_repeatIfMissingValue()) continue;

      metarData.dewpoint = dewInput.optionLogic();
      if (repeatLoop(metarData.dewpoint)) {
        continue;
      } else if (metarData.dewpoint! > metarData.temperature!) {
        comm.errorMessage = 'Dewpoint must be less than or equal to ${metarData.temperature}°C (Temperature)';

        metarData.dewpoint = null;
        comm.console.clearScreen();
        continue;
      }

      continue;
    } else if (metarData.altimeterInHg == null) {
      final altimeterInput = MenuLogic.screenType(InputInfo.baro, variable: metarData.altimeterInHg?.toDouble());
      comm.errorMessage = 'The altimeter setting is missing from download. Type it out.';

      if (_repeatIfMissingValue()) continue;

      metarData.altimeterInHg = altimeterInput.optionLogic();
      if (repeatLoop(metarData.altimeterInHg)) continue;

      continue;
    }
    //               //             //            //                //

    // Data for calculation.
    final elevation = airpElevation?.toDouble();
    final temperature = metarData.temperature?.toDouble();
    final dewpoint = metarData.dewpoint?.toDouble();
    final altimeter = metarData.altimeterInHg?.toDouble();

    final result = {
      'Airport: ': '$airpName ($airportId)\n',
      'METAR: ': '${metarData.rawMetar}\n',
      'Elevation: ': '${elevation?.round()} FT\n',
      'Temperature: ': '${formatNumber(temperature)} °C\n',
      'Dewpoint: ': '${formatNumber(dewpoint)} °C\n',
      'Altimeter: ': '${formatNumber(altimeter)} InHg\n'
    };

    printDownData(result); // Prints downloaded data with colors.

    // Calculated pressure altitude.
    final pressure = pressureAlt(elevation, altimeter);
    // comm.dataResult['pressureAlt'] = pressure.toDouble();

    // Calculated density altitude
    final density = densityAlt(
        tempC: temperature,
        stationInches: altimeter,
        dewC: dewpoint,
        elevation: elevation
    );

    if (density == null) {
      comm.console.clearScreen();
      comm.errorMessage = 'Invalid Result';

      airportId = null;
      downloadMetar = null;
      metarData = null;

      comm.screenCleared = true;
      missingValue = true;

      continue;
    }
    // Sending calculated density altitude to comm dataResult Map.
    comm.dataResult['densityAlt'] = density;

    resultPrinter([
      'Pressure Altitude: ${formatNumber(pressure)}ft',
      'Density Altitude: ${formatNumber(density)}ft']
    );

    final backOrNot = insideMenus(goBack: 'Back to Pressure/Density Altitude Menu', backMenuSelection: OptionIdent.pressDenAlt);
    if (backOrNot == null) continue;

    if (backOrNot) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      airportId = null;
      downloadMetar = null;
      metarData = null;

      comm.screenCleared = true;
      missingValue = true;

      continue;
    }
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

  const options = {
    'Return to:': null,
    'Pressure/Density Altitude Menu': OptionIdent.pressDenAlt,
    'Main Menu': OptionIdent.menu
  };

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

  if (validAirport.hasMatch(id ?? '')) {
    return false;
  }
  comm.console.clearScreen();
  comm.errorMessage = 'Enter a valid ICAO/IATA Airport Code';

  return true;
}

bool _airportNotFound(String? airportName) {

  if (airportName == null) {
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
    comm.screenCleared = true;
    comm.console.clearScreen();
    airportId = null;

    return true;
  }  else if (comm.formatError) {
    comm.errorMessage = 'Downloaded data is corrupted. Try another airport or try again.';
    comm.formatError = false;
    comm.screenCleared = true;
    comm.console.clearScreen();
    airportId = null;

    return true;
  } else if (comm.handShakeError) {
    comm.errorMessage = 'There is has been a problem when downloading the data. Try again.';
    comm.handShakeError = false;
    comm.screenCleared = true;
    comm.console.clearScreen();
    airportId = null;

    return true;
  } else if (comm.httpError) {
    comm.errorMessage = 'A problem occurred when downloading the weather data from aviationweather.gov. Try again.';
    comm.httpError = false;
    comm.screenCleared = true;
    comm.console.clearScreen();
    airportId = null;

    return true;
  } else if (comm.timeoutError) {
    comm.errorMessage = 'aviationweather.gov took too long to response. Try again.';
    comm.timeoutError = false;
    comm.screenCleared = true;
    comm.console.clearScreen();
    airportId = null;

    return true;
  }

  comm.errorMessage = '';

  return false;
}

bool _repeatIfMissingValue() {
  if (missingValue) {
    missingValue = false;
    comm.console.clearScreen();

    return true;
  }

  missingValue = true;
  comm.errorMessage = '';

  return false;
}
