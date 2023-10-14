import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

OptionIdent? shortcuts(Key key) {

  switch (key.controlChar) {
    case ControlCharacter.F1:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.helpConfig;
      return comm.selectedOption;
    case ControlCharacter.ctrlF:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.exit;
      return comm.selectedOption;
    case ControlCharacter.ctrlN:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.menu;
      return comm.selectedOption;
    case ControlCharacter.ctrlQ:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.cloudBase;
      return comm.selectedOption;
    case ControlCharacter.ctrlW:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.pressDenAlt;
      return comm.selectedOption;
    case ControlCharacter.ctrlE:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.groundSpeed;
      return comm.selectedOption;
    case ControlCharacter.ctrlR:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.trueAirspeed;
      return comm.selectedOption;
    case ControlCharacter.ctrlT:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.windComp;
      return comm.selectedOption;
    case ControlCharacter.ctrlY:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.windCorrection;
      return comm.selectedOption;
    case ControlCharacter.ctrlU:
      comm.console.clearScreen();
      comm.selectedOption = OptionIdent.fuel;
      return comm.selectedOption;
    default:
      return null;
  }

}