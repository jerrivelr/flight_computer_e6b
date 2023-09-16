import 'package:flight_e6b/airport_database/airport_data.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/data_parsing/aviation_weather.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/data_parsing/metar_data.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';

final console = Console();

Future<String?> conditionsAirportScreen() async {
  AirportData? airportData;

  MenuLogic.selectedOption = null;
  MenuLogic.screenCleared = true;

  while(MenuLogic.selectedOption == null) {
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
      console.clearScreen();
      MenuLogic.screenCleared = false;
      MenuLogic.error = '';
      continue;
    }

    // Downloads METAR information from the selected airport.
    final downloadMetar = await metar(airportId);
    // Checks for no internet connection and when the connection comes back.
    if (MenuLogic.noInternet) {
      MenuLogic.error = 'Check your internet connection. Waiting...';
      MenuLogic.backOnline = MenuLogic.noInternet;
      await Future.delayed(Duration(seconds: 2));
      console.clearScreen();
      continue;

    } else if (MenuLogic.backOnline) {
      MenuLogic.error = '';
      MenuLogic.backOnline = false;
      console.clearScreen();
      continue;

    } else if (downloadMetar.isEmpty) {
      MenuLogic.error = 'No Weather Information Available for $airpName';
      airportData = null;

      MenuLogic.screenCleared = true;
      console.clearScreen();
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
    MenuLogic.dataResult['pressureAlt'] = pressure.toDouble();

    // Calculated density altitude
    final density = densityAlt(
        tempC: temperature ?? 0,
        stationInches: altimeter,
        dewC: dewpoint ?? 0,
        elevation: elevation
    );

    // Sending calculated density altitude to the dataResult Map.
    MenuLogic.dataResult['densityAlt'] = density;
    resultPrinter([
      'Pressure Altitude: ${formatNumber(pressure)}ft',
      'Density Altitude: ${formatNumber(density)}ft']
    );

    if (!MenuLogic.backToMenu(text: 'Back to Pressure/Density Altitude Menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt2')) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      airportData = null;
      MenuLogic.screenCleared = true;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

String? manualScreen() {
  double? indicatedAlt;
  double? pressInHg;
  double? temperature;
  double? dewpoint;

  MenuLogic.selectedOption = null;

  while (MenuLogic.selectedOption == null) {
    // Sending calculated pressure altitude to the dataResult Map.
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

    // Sending calculated pressure altitude to the dataResult Map.
    MenuLogic.dataResult['pressureAlt'] = pressure.toDouble();
    resultPrinter(['Pressure Altitude: ${formatNumber(pressure)}ft']);

    // Getting temperature.
    temperature = tempInput.optionLogic();
    if (MenuLogic.repeatLoop(temperature)) continue;

    MenuLogic.dataResult['temperature'] = temperature!;

    // Getting dewpoint.
    dewpoint = dewInput.optionLogic();
    if (MenuLogic.repeatLoop(dewpoint)) {
      continue;
    } else if (dewpoint! > temperature) {
      MenuLogic.error = 'Dewpoint must be less than or equal to temperature';
      dewpoint = null;
      console.clearScreen();
      continue;
    }

    final density = densityAlt(
        tempC: temperature,
        stationInches: pressInHg,
        dewC: dewpoint,
        elevation: indicatedAlt
    );

    // Sending calculated pressure altitude to the dataResult Map.
    MenuLogic.dataResult['densityAlt'] = density;
    resultPrinter(['Density Altitude: ${formatNumber(density)}ft']);

    // Asking user weather to make a new calculation or back to menu.
    if (!MenuLogic.backToMenu(text: 'Back to Pressure/Density Altitude Menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt2')) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      indicatedAlt = null;
      pressInHg = null;
      temperature = null;
      dewpoint = null;

      continue;
    }
  }

  return MenuLogic.selectedOption;
}

bool _invalidAirportFormat(String id) {
  // Airport invalid and screens updates.
  final validAirport = RegExp(r'^\w{3,4}$'); // To check the airport identifier.

  if (validAirport.hasMatch(id)) {
    return false;
  }
  console.clearScreen();
  MenuLogic.error = 'Enter ICAO/IATA Airport Code';

  return true;
}

bool _airportNotFound(String? airportName) {

  if (airportName == null) {
    console.clearScreen();
    MenuLogic.error = 'Airport Not Found';
    return true;
  }

  return false;
}

