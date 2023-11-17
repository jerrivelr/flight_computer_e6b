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

final genericReturnMenu = MenuBuilder();

final pressReturnMenu = MenuBuilder(
    menuOptions: {
      'Return to:': null,
      'Pressure/Density Altitude Menu': OptionIdent.pressDenAlt,
      'Main Menu': OptionIdent.menu
    }
);

final setReturnMenu = MenuBuilder(
  menuOptions: {
    'Return to:': null,
    'Help/Settings': OptionIdent.helpSetting,
    'Main Menu': OptionIdent.menu
  }
);

final groundReturnMenu = MenuBuilder(
  menuOptions: {
    'Return to:': null,
    'Ground Speed Menu': OptionIdent.groundSpeed,
    'Main Menu': OptionIdent.menu
  }
);

final fuelReturnMenu = MenuBuilder(
  menuOptions: {
    'Return to:': null,
    'Fuel Menu': OptionIdent.fuel,
    'Main Menu': OptionIdent.menu
  }
);

