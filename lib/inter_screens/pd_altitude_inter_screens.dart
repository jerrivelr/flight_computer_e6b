import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/data_parsing/airport_data.dart';
import 'package:flight_e6b/data_parsing/metar_data.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

String? airportId;
bool missingValue = true;

Future<String?> conditionsAirportScreen() async {
  List<dynamic>? downloadMetar;
  Metar? metarData;

  comm.selectedOption = null;
  comm.screenCleared = true;

  double? elevation;
  double? temperature;
  double? dewpoint;
  double? altimeter;

  //               //                   //
  while(comm.selectedOption == null) {
    comm.console.showCursor();
    screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');

    airportId ??= retrieveAirport();

    if (airportId == null) {
      comm.console.clearScreen();
      comm.error = '';
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
      comm.error = '';
      continue;
    }

    // Downloads METAR information from the selected airport.
    // downloadMetar ??= await metar(airportId);
    downloadMetar ??= testMetar();

    // This is to display the downloading screen when downloading process.
    if (comm.screenCleared) {
      comm.screenCleared = false;
      comm.error = '';
      continue;
    }

    // Checks for no internet connection and when the connection comes back.
    if (_checkConnectErrors()) continue;

    if (downloadMetar?.isEmpty ?? false) {
      comm.error = 'No Weather Information Available for $airpName';
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
      final tempInput = MenuLogic.screenType(InputType.temperature, metarData.temperature?.toDouble());
      comm.error = 'Temperature is missing from download. Type it out.';

      if (_repeatIfMissingValue()) continue;

      metarData.temperature = tempInput.optionLogic();
      if (repeatLoop(metarData.temperature)) continue;

      continue;

    } else if (metarData.dewpoint == null || metarData.dewpoint! > metarData.temperature!) {

      final dewInput = MenuLogic.screenType(InputType.dewpoint, metarData.dewpoint?.toDouble());
      comm.error = 'Dewpoint is missing from download. Make sure dewpoint is less than or equal to temperature (${metarData.temperature}°C).';

      if (_repeatIfMissingValue()) continue;

      metarData.dewpoint = dewInput.optionLogic();
      if (repeatLoop(metarData.dewpoint)) {
        continue;
      } else if (metarData.dewpoint! > metarData.temperature!) {
        comm.error = 'Dewpoint must be less than or equal to ${metarData.temperature}°C (Temperature)';

        metarData.dewpoint = null;
        comm.console.clearScreen();
        continue;
      }

      continue;
    } else if (metarData.altimeterInHg == null) {
      final altimeterInput = MenuLogic.screenType(InputType.baro, metarData.altimeterInHg?.toDouble());
      comm.error = 'The altimeter setting is missing from download. Type it out.';

      if (_repeatIfMissingValue()) continue;

      metarData.altimeterInHg = altimeterInput.optionLogic();
      if (repeatLoop(metarData.altimeterInHg)) continue;

      continue;
    }
    //               //             //            //                //

    // Data for calculation.
    elevation = airpElevation?.toDouble();
    temperature = metarData.temperature?.toDouble();
    dewpoint = metarData.dewpoint?.toDouble();
    altimeter = metarData.altimeterInHg?.toDouble();

    final result = {
      'Airport: ': '$airpName ($airportId)\n',
      'METAR: ': '${metarData.rawMetar}\n',
      'Elevation: ': '${elevation?.round()}ft\n',
      'Temperature: ': '${formatNumber(temperature ?? 0)}°C\n',
      'Dewpoint: ': '${formatNumber(dewpoint ?? 0)}°C\n',
      'Altimeter: ': '${formatNumber(altimeter ?? 0)} InHg\n'
    };

    printDownData(result); // Prints downloaded data with colors.

    // Calculated pressure altitude.
    final pressure = pressureAlt(elevation!, altimeter!);
    comm.dataResult['pressureAlt'] = pressure.toDouble();

    // Calculated density altitude
    final density = densityAlt(
        tempC: temperature ?? 0,
        stationInches: altimeter,
        dewC: dewpoint ?? 0,
        elevation: elevation
    );
    // Sending calculated density altitude to comm dataResult Map.
    comm.dataResult['densityAlt'] = density;

    resultPrinter([
      'Pressure Altitude: ${formatNumber(pressure)}ft',
      'Density Altitude: ${formatNumber(density)}ft']
    );

    if (!backToMenu(text: 'Back to Pressure/Density Altitude Menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt2')) {
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

  return comm.selectedOption;
}

String? manualScreen() {
  double? indicatedAlt;
  double? pressInHg;
  double? temperature;
  double? dewpoint;

  comm.selectedOption = null;

  while (comm.selectedOption == null) {
    final indicatedAltInput = MenuLogic.screenType(InputType.indicatedAlt, indicatedAlt);
    final pressInHgInput = MenuLogic.screenType(InputType.baro, pressInHg);
    final tempInput = MenuLogic.screenType(InputType.temperature, temperature);
    final dewInput = MenuLogic.screenType(InputType.dewpoint, dewpoint);

    screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');

    // Getting indicated altitude
    indicatedAlt = indicatedAltInput.optionLogic();
    if (repeatLoop(indicatedAlt)) continue;

    // Getting altimeter setting
    pressInHg = pressInHgInput.optionLogic();
    if (repeatLoop(pressInHg)) continue;

    // Calculated pressure altitude.
    final pressure = pressureAlt(indicatedAlt!, pressInHg!);

    // Sending calculated pressure altitude to comm dataResult Map.
    comm.dataResult['pressureAlt'] = pressure.toDouble();
    resultPrinter(['Pressure Altitude: ${formatNumber(pressure)}ft']);

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (repeatLoop(temperature)) continue;

    comm.dataResult['temperature'] = temperature!;

    // Getting dewpoint.
    dewpoint = dewInput.optionLogic();
    if (repeatLoop(dewpoint)) {
      continue;
    } else if (dewpoint! > temperature) {
      comm.error = 'Dewpoint must be less than or equal to temperature';
      dewpoint = null;
      comm.console.clearScreen();
      continue;
    }

    final density = densityAlt(
        tempC: temperature,
        stationInches: pressInHg,
        dewC: dewpoint,
        elevation: indicatedAlt
    );

    // Sending calculated pressure altitude to comm dataResult Map.
    comm.dataResult['densityAlt'] = density;
    resultPrinter(['Density Altitude: ${formatNumber(density)}ft']);

    // Asking user weather to make a new calculation or back to menu.
    if (!backToMenu(text: 'Back to Pressure/Density Altitude Menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt2')) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      indicatedAlt = null;
      pressInHg = null;
      temperature = null;
      dewpoint = null;

      continue;
    }
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
  comm.error = 'Enter a valid ICAO/IATA Airport Code';

  return true;
}

bool _airportNotFound(String? airportName) {

  if (airportName == null) {
    comm.console.clearScreen();
    comm.error = 'Airport Not Found';
    return true;
  }

  return false;
}

bool _checkConnectErrors() {
  if (comm.noInternet) {
    comm.error = 'Check your internet connection...';
    comm.noInternet = false;
    comm.console.clearScreen();
    airportId = null;

    return true;
  }  else if (comm.formatError) {
    comm.error = 'Downloaded data is corrupted. Try another airport or try again.';
    comm.formatError = false;
    comm.console.clearScreen();
    airportId = null;

    return true;
  } else if (comm.handShakeError) {
    comm.error = 'There is has been a problem when downloading the data. Try again.';
    comm.handShakeError = false;
    comm.console.clearScreen();
    airportId = null;

    return true;
  } else if (comm.httpError) {
    comm.error = 'A problem occurred when downloading the weather data from aviationweather.gov. Try again.';
    comm.httpError = false;
    comm.console.clearScreen();
    airportId = null;

    return true;
  } else if (comm.timeoutError) {
    comm.error = 'aviationweather.gov took too long to response. Try again.';
    comm.timeoutError = false;
    comm.console.clearScreen();
    airportId = null;

    return true;
  }

  comm.error = '';

  return false;
}

bool _repeatIfMissingValue() {
  if (missingValue) {
    missingValue = false;
    comm.console.clearScreen();

    return true;
  }

  missingValue = true;
  comm.error = '';

  return false;
}
