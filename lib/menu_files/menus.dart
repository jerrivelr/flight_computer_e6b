import 'package:flight_e6b/menu_files/menu_builder.dart';
import 'package:flight_e6b/enums.dart';

import '../setting/setting_lookup.dart';

final mainMenu = MenuBuilder(
    title: 'FLIGHT COMPUTER (E6B)',
    menuOptions: {
      'Help/Settings': OptionIdent.helpSetting,
      'Cloud Base (${altitudeUnit()?.trim()})': OptionIdent.cloudBase,
      'Pressure/Density Altitude (${altitudeUnit()?.trim()})': OptionIdent.pressDenAlt,
      'Ground Speed (${speedUnit()?.trim()})': OptionIdent.groundSpeed,
      'True Airspeed (${speedUnit()?.trim()})': OptionIdent.trueAirspeed,
      'Wind Component': OptionIdent.windComp,
      'Heading/Wind Correction Angle (WCA)': OptionIdent.windCorrection,
      'Fuel': OptionIdent.fuel,
      'Exit': OptionIdent.exit
    }
); // Main Menu

final helpConfigMenu = MenuBuilder(
    title: 'HELP/SETTINGS',
    menuOptions: {
      'Help': OptionIdent.help,
      'Settings': OptionIdent.setting,
      'Main Menu': OptionIdent.menu
    }
);

final pressDenMenu = MenuBuilder(
   title: 'PRESSURE/DENSITY ALTITUDE',
   menuOptions: {
     'Calculate Pressure/Density Altitude From...': null,
     'Conditions at Airport': OptionIdent.airport,
     'Manual Values': OptionIdent.manual,
     'Main Menu': OptionIdent.menu
   }
);

final groundSpeedMenu = MenuBuilder(
   title: 'GROUND SPEED',
   menuOptions: {
     'Calculate...': null,
     'Ground Speed (${speedUnit()?.trim()})': OptionIdent.calGroundSpeed,
     'Duration (HR)': OptionIdent.groundDur,
     'Distance (NM)': OptionIdent.groundDis,
     'Main Menu': OptionIdent.menu
   }
);

final fuelMenu = MenuBuilder(
   title: 'FUEL',
   menuOptions: {
      'Calculate Fuel...': null,
      'Volume (US Gal)': OptionIdent.fuelVol,
      'Endurance (${timeUnit()?.trim()})': OptionIdent.fuelDur,
      'Rate (US GPH)': OptionIdent.fuelRate,
      'Main Menu': OptionIdent.menu
   }
);