import 'package:flight_e6b/airport_database/airport_data.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/data_parsing/aviation_weather.dart';
import 'package:flight_e6b/data_parsing/metar_data.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';
import 'package:flight_e6b/communication_var.dart' as comm;


Future<String?> conditionsAirportScreen() async {
  AirportData? airportData;

  comm.selectedOption = null;
  comm.screenCleared = true;

  while(comm.selectedOption == null) {
    MenuLogic.screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');
    airportData ??= AirportData.inputCheck();

    final airportId = airportData.airportId;

    final airpName = await airportData.airportName();
    final airpElevation = await airportData.airportElevation();

    if (_invalidAirportFormat(airportId)) {
      // Airport invalid and screens updates.
      airportData = null;
      continue;

    } else if (_airportNotFound(airpName)) {
      // Airport not in the airports.json file
      airportData = null;
      continue;

    } else if (MenuLogic.repeatLoop(airportId)) {
      // Makes one loop to redraw the screen.
      comm.console.clearScreen();
      comm.screenCleared = false;
      comm.error = '';
      continue;
    }

    // Downloads METAR information from the selected airport.
    final downloadMetar = await metar(airportId);
    // Checks for no internet connection and when the connection comes back.
    if (comm.noInternet) {
      comm.error = 'Check your internet connection. Waiting...';
      comm.backOnline = comm.noInternet;
      await Future.delayed(Duration(seconds: 2));
      comm.console.clearScreen();
      continue;

    } else if (comm.backOnline) {
      comm.error = '';
      comm.backOnline = false;
      comm.console.clearScreen();
      continue;

    } else if (downloadMetar.isEmpty) {
      comm.error = 'No Weather Information Available for $airpName';
      airportData = null;

      comm.screenCleared = true;
      comm.console.clearScreen();
      continue;
    }

    // Makes a map with all downloaded METAR data from easier access.
    final metarData = Metar.fromJson(downloadMetar);

    // Data for calculation.
    final elevation = airpElevation?.toDouble();
    final temperature = metarData.temperature?.toDouble();
    final dewpoint = metarData.dewpoint?.toDouble();
    final altimeter = metarData.altimeterInHg.toDouble();

    final result = {
        'Airport: ': '$airpName ($airportId)\n',
        'METAR: ': '${metarData.rawMetar}\n',
        'Elevation: ': '${elevation?.round()}ft\n',
        'Temperature: ': '${formatNumber(temperature ?? 0)}°C\n',
        'Dewpoint: ': '${formatNumber(dewpoint ?? 0)}°C\n',
        'Altimeter: ': '${formatNumber(altimeter)} InHg\n'
    };

    printDownData(result); // Prints downloaded data with colors.

    // Calculated pressure altitude.
    final pressure = pressureAlt(elevation!, altimeter);
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

    if (!MenuLogic.backToMenu(text: 'Back to Pressure/Density Altitude Menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt2')) {
      comm.console.clearScreen();
      // Resetting all the variables for new calculations.
      airportData = null;
      comm.screenCleared = true;

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
    // Sending calculated pressure altitude to comm dataResult Map.
    final indicatedAltInput = MenuLogic.screenType(InputType.indicatedAlt, indicatedAlt);
    final pressInHgInput = MenuLogic.screenType(InputType.baro, pressInHg);
    final tempInput = MenuLogic.screenType(InputType.temperature, temperature);
    final dewInput = MenuLogic.screenType(InputType.dewpoint, dewpoint);

    MenuLogic.screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');

    // Getting indicated altitude
    indicatedAlt = indicatedAltInput.optionLogic();
    if (MenuLogic.repeatLoop(indicatedAlt)) continue;

    // Getting altimeter setting
    pressInHg = pressInHgInput.optionLogic();
    if (MenuLogic.repeatLoop(pressInHg)) continue;

    // Calculated pressure altitude.
    final pressure = pressureAlt(indicatedAlt!, pressInHg!);

    // Sending calculated pressure altitude to comm dataResult Map.
    comm.dataResult['pressureAlt'] = pressure.toDouble();
    resultPrinter(['Pressure Altitude: ${formatNumber(pressure)}ft']);

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (MenuLogic.repeatLoop(temperature)) continue;

    comm.dataResult['temperature'] = temperature!;

    // Getting dewpoint.
    dewpoint = dewInput.optionLogic();
    if (MenuLogic.repeatLoop(dewpoint)) {
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
    if (!MenuLogic.backToMenu(text: 'Back to Pressure/Density Altitude Menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt2')) {
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

bool _invalidAirportFormat(String id) {
  // Airport invalid and screens updates.
  final validAirport = RegExp(r'^\w{3,4}$'); // To check the airport identifier.

  if (validAirport.hasMatch(id)) {
    return false;
  }
  comm.console.clearScreen();
  comm.error = 'Enter ICAO/IATA Airport Code';

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

