import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

bool positionCheck(List<Coordinate> positions) {
  if (comm.currentPosition > positions.length - 1) {
    comm.console.clearScreen();
    comm.currentCursorPos = Coordinate((comm.currentCursorPos?.row ?? 0) + 1, comm.console.cursorPosition?.col ?? 0);
    return true;
  } else if (comm.currentPosition < 0) {
    comm.currentPosition = 0;
  }

  return false;
}

void changePosition(List<Coordinate> positions) {
  comm.console.cursorPosition = positions[comm.currentPosition];
  comm.currentCursorPos = positions[comm.currentPosition];
}