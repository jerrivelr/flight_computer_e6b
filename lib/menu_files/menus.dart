import 'package:flight_e6b/menu_files/menu_logic.dart';
import 'package:flight_e6b/menu_files/menu_builder.dart';

final mainMenu = MenuBuilder(
    title: 'FLIGHT COMPUTER (E6B)',
    menuOptions: {
      'Help/Settings': OptionIdent.helpSetting,
      'Cloud Base (ft)': OptionIdent.cloudBase,
      'Pressure/Density Altitude (ft)': OptionIdent.pressDenAlt,
      'Ground Speed (GS)': OptionIdent.groundSpeed,
      'True Airspeed (TAS)': OptionIdent.trueAirspeed,
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
     'Ground Speed (KT)': OptionIdent.calGroundSpeed,
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
      'Endurance (hr)': OptionIdent.fuelDur,
      'Rate (US GPH)': OptionIdent.fuelRate,
      'Main Menu': OptionIdent.menu
   }
);