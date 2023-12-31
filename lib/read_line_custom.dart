import 'dart:math';

import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/enums.dart';
import 'package:flight_e6b/shortcuts.dart';
import 'package:flight_e6b/communication_var.dart' as comm;

extension CustomConsole on Console {
  String? input({String? printOut, bool onlyNumbers = true, int charLimit = 10, String inputContent = '', String unit = '',
      int inputRow = 0, int inputCol = 0, bool liveReturn = false, void Function(String text, Key lastPressed)? callback}) {

    var buffer = inputContent + unit;
    var index = buffer.length - unit.length; // cursor position relative to buffer, not screen

    final regexDigit = '\\d{0,$charLimit}';
    final regexSymbols = r'-|\.|-\.';

    final letterFilter = RegExp('^\\w{0,$charLimit}\$');
    final numberFilter = RegExp('^(($regexSymbols)?$regexDigit\$)\$|^(-?$regexDigit(\\.\\d{0,6})?)\$');
    final noReturn = RegExp(r'^[.-]{1,2}$');

    final screenRow = cursorPosition?.row ?? inputRow;
    final screenColOffset = cursorPosition?.col ?? inputCol;

    final bufferMaxLength = windowWidth - screenColOffset - 3;

    if (printOut != null) {
      write(printOut);
    }

    setForegroundExtendedColor(180);
    write(buffer);

    final currentCol = cursorPosition?.col ?? inputCol;
    cursorPosition = Coordinate(screenRow, currentCol - unit.length);

    while (true) {
      final key = readKey();

      if (key.isControl) {
        comm.keyPressed = key.controlChar;

        final selection = shortcuts(key);
        if (selection != null) return null;

        switch (key.controlChar) {
          case ControlCharacter.enter:
            if (scrollbackBuffer != null) scrollbackBuffer!.add(buffer);

            if (buffer.isEmpty) break;

            comm.currentPosition++;

            return buffer.substring(0, buffer.length - unit.length).trim();
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
            if (comm.currentPosition > 0) {
              comm.currentPosition--;
            }

            return buffer.substring(0, buffer.length - unit.length);
          case ControlCharacter.arrowDown:
            if (scrollbackBuffer != null) {
              final temp = scrollbackBuffer!.down();
              if (temp != null) {
                buffer = temp;
                index = buffer.length;
              }
            }
            comm.currentPosition++;

            return buffer.substring(0, buffer.length - unit.length).trim();
          case ControlCharacter.arrowRight:
            if (index < buffer.length &&  index + 1 <= buffer.length - unit.length) {
              index++;
            }

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
            index = buffer.length - unit.length;
            break;
          case ControlCharacter.unknown:
            comm.selectedOption = OptionIdent.menu;
            comm.unknownInput = ControlCharacter.unknown;
            comm.errorMessage = 'Invalid Input';
            break;
          default:
            break;
        }
      } else if (buffer.length < bufferMaxLength && key.char != ' ') {
        key.char = key.char.toUpperCase();

        var nextBuffer = buffer.substring(0, index) + key.char + buffer.substring(index);
        nextBuffer = nextBuffer.substring(0, nextBuffer.length - unit.length).trim();

        if (onlyNumbers && !numberFilter.hasMatch(nextBuffer)) {
          key.char = '';
        } else if (!onlyNumbers && !letterFilter.hasMatch(nextBuffer)) {
          key.char = '';
        } else if (index == buffer.length) {
          buffer += key.char;
          index++;
        } else {
          buffer = buffer.substring(0, index) + key.char + buffer.substring(index);
          index++;
        }
      }

      cursorPosition = Coordinate(screenRow, screenColOffset);
      eraseCursorToEnd();
      write(buffer); // allow for backspace condition
      cursorPosition = Coordinate(screenRow, screenColOffset + index);

      if (callback != null) callback(buffer, key);

      final returnString = buffer.substring(0, buffer.length - unit.length).trim();

      if (noReturn.hasMatch(returnString)) continue;
      if (liveReturn) return returnString;
    }
  }
}