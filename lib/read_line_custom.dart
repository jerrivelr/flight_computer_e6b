import 'dart:math';

import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_logic.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

extension CustomConsole on Console {
  String? readLineCustom(
      {bool cancelOnBreak = false,
        bool cancelOnEscape = false,
        bool cancelOnEOF = false,
        void Function(String text, Key lastPressed)? callback}) {
    var buffer = '';
    var index = 0; // cursor position relative to buffer, not screen

    final screenRow = cursorPosition!.row;
    final screenColOffset = cursorPosition!.col;

    final bufferMaxLength = windowWidth - screenColOffset - 3;

    while (true) {
      final key = readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.enter:
            if (scrollbackBuffer != null) {
              scrollbackBuffer!.add(buffer);
            }
            writeLine();
            return buffer;
          case ControlCharacter.ctrlF:
            comm.selectedOption = OptionIdent.exit;
            return null;
          case ControlCharacter.ctrlN:
            comm.selectedOption = OptionIdent.menu;
            return null;
          case ControlCharacter.ctrlQ:
            comm.selectedOption = OptionIdent.cloudBase;
            return null;
          case ControlCharacter.ctrlW:
            comm.selectedOption = OptionIdent.pressDenAlt;
            return null;
          case ControlCharacter.ctrlE:
            comm.selectedOption = OptionIdent.groundSpeed;
            return null;
          case ControlCharacter.ctrlR:
            comm.selectedOption = OptionIdent.trueAirspeed;
            return null;
          case ControlCharacter.ctrlT:
            comm.selectedOption = OptionIdent.windComp;
            return null;
          case ControlCharacter.ctrlY:
            comm.selectedOption = OptionIdent.windCorrection;
            return null;
          case ControlCharacter.ctrlU:
            comm.selectedOption = OptionIdent.fuel;
            return null;
          case ControlCharacter.ctrlC:
            if (cancelOnBreak) return null;
            break;
          case ControlCharacter.escape:
            if (cancelOnEscape) return null;
            break;
          case ControlCharacter.backspace:
          case ControlCharacter.ctrlH:
            if (index > 0) {
              buffer = buffer.substring(0, index - 1) + buffer.substring(index);
              index--;
            }
            break;
          case ControlCharacter.ctrlS:
            buffer = buffer.substring(index, buffer.length);
            index = 0;
            break;
          case ControlCharacter.delete:
          case ControlCharacter.ctrlD:
            if (index < buffer.length) {
              buffer = buffer.substring(0, index) + buffer.substring(index + 1);
            } else if (cancelOnEOF) {
              return null;
            }
            break;
          case ControlCharacter.ctrlK:
            buffer = buffer.substring(0, index);
            break;
          case ControlCharacter.arrowLeft:
          case ControlCharacter.ctrlB:
            index = index > 0 ? index - 1 : index;
            break;
          case ControlCharacter.arrowUp:
            if (scrollbackBuffer != null) {
              buffer = scrollbackBuffer!.up(buffer);
              index = buffer.length;
            }
            break;
          case ControlCharacter.arrowDown:
            if (scrollbackBuffer != null) {
              final temp = scrollbackBuffer!.down();
              if (temp != null) {
                buffer = temp;
                index = buffer.length;
              }
            }
            break;
          case ControlCharacter.arrowRight:
            index = index < buffer.length ? index + 1 : index;
            break;
          case ControlCharacter.wordLeft:
            if (index > 0) {
              final bufferLeftOfCursor = buffer.substring(0, index - 1);
              final lastSpace = bufferLeftOfCursor.lastIndexOf(' ');
              index = lastSpace != -1 ? lastSpace + 1 : 0;
            }
            break;
          case ControlCharacter.wordRight:
            if (index < buffer.length) {
              final bufferRightOfCursor = buffer.substring(index + 1);
              final nextSpace = bufferRightOfCursor.indexOf(' ');
              index = nextSpace != -1
                  ? min(index + nextSpace + 2, buffer.length)
                  : buffer.length;
            }
            break;
          case ControlCharacter.home:
          case ControlCharacter.ctrlA:
            index = 0;
            break;
          case ControlCharacter.end:
            index = buffer.length;
            break;
          default:
            break;
        }
      } else {
        if (buffer.length < bufferMaxLength) {
          if (index == buffer.length) {
            buffer += key.char;
            index++;
          } else {
            buffer = buffer.substring(0, index) + key.char + buffer.substring(index);
            index++;
          }
        }
      }

      cursorPosition = Coordinate(screenRow, screenColOffset);
      eraseCursorToEnd();
      write(buffer); // allow for backspace condition
      cursorPosition = Coordinate(screenRow, screenColOffset + index);

      if (callback != null) callback(buffer, key);
    }
  }

}