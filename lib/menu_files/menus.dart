import 'package:flight_e6b/menu_files/menu_builder.dart';
import 'package:flight_e6b/enums.dart';

final mainMenu = MenuBuilder(
    title: 'FLIGHT COMPUTER (E6B)',
    menuOptions: {},
    errorWindow: true
); // Main Menu

final helpConfigMenu = MenuBuilder(
    title: 'HELP/SETTINGS',
    menuOptions: {
      'Help': OptionIdent.help,
      'Settings': OptionIdent.setting,
      'Main Menu': OptionIdent.menu
    },
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
   menuOptions: {}
);

final fuelMenu = MenuBuilder(
   title: 'FUEL',
   menuOptions: {}
);