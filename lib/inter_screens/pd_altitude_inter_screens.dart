import 'package:flight_e6b/airport_database/airport_data.dart';
import 'package:flight_e6b/aviation_math.dart';
import 'package:flight_e6b/data_parsing/aviation_weather.dart';
import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/data_parsing/metar_data.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/simple_io.dart';

final console = Console();

Future<String?> conditionsAirportScreen() async {
  final validAirport = RegExp(r'^\w{3,4}$'); // To check the airport identifier.
  AirportData? airportData;

  MenuLogic.selectedOption = null;
  MenuLogic.screenCleared = true;

  while(MenuLogic.selectedOption == null) {
    MenuLogic.screenHeader(title: 'PRESSURE/DENSITY ALTITUDE');
    airportData ??= AirportData.inputCheck();

    final airportId = airportData.airportId;

    final airpName = airportName(airportId ?? '');
    final airpElevation = airportElevation(airportId ?? '');
    final airpName = await airportData.airportName();
    final airpElevation = await airportData.airportElevation();

    if (!validAirport.hasMatch(airportId!)) {
      // Airport invalid and screens updates.
      console.clearScreen();
      MenuLogic.error = 'Invalid Airport';
      airportId = null;
      continue;

    } else if (airpName == null) {
      // Airport not in the airports.json file
      console.clearScreen();
      MenuLogic.error = 'Airport Not Found';
      airportId = null;
      continue;

    } else if (MenuLogic.repeatLoop(airportId)) {
      // Makes one loop to redraw the screen.
      console.clearScreen();
      MenuLogic.screenCleared = false;
      MenuLogic.error = '';
      continue;
    }

    // Prints the airport name, not the identifier.
    console.writeLine('Airport: $airpName');

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
      console.clearScreen();
      MenuLogic.backOnline = false;
      continue;
    }

    // Makes a map with all downloaded METAR data from easier access.
    final metarData = Metar.fromJson(downloadMetar);

    // Data for calculation.
    final elevation = airpElevation?.toDouble();
    final temperature = metarData.temperature?.toDouble();
    final dewpoint = metarData.dewpoint?.toDouble();
    final altimeter = metarData.altimeterInHg.toDouble();

    console.writeLine(
      'METAR: ${metarData.rawMetar}\n'
      'Elevation: ${elevation?.round()}ft\n'
      'Temperature: ${MenuLogic.formatNumber(temperature ?? 0)}°C\n'
      'Dewpoint: ${MenuLogic.formatNumber(dewpoint ?? 0)}°C\n'
      'Altimeter: ${MenuLogic.formatNumber(altimeter)} InHg'
    );

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
      'Pressure Altitude: ${MenuLogic.formatNumber(pressure)}ft',
      'Density Altitude: ${MenuLogic.formatNumber(density)}ft']
    );

    if (!MenuLogic.backToMenu(text: 'Back to Pressure/Density Altitude Menu: [Y] yes (any key) ——— [N] no?', backMenuSelection: 'opt2')) {
      console.clearScreen();
      // Resetting all the variables for new calculations.
      airportId = null;
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
    resultPrinter(['Pressure Altitude: ${MenuLogic.formatNumber(pressure)}ft']);

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
    resultPrinter(['Density Altitude: ${MenuLogic.formatNumber(density)}ft']);

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
