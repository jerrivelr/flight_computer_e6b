import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/enums.dart';

final console = Console();

OptionIdent? selectedOption; // Stores values that are part of the optionList if userInput equals to one of the options.
var errorMessage = ''; // Stores errors messages if any.
var inputValues = <InputTitle?, String?>{}; // This Map will contain the calculated data for reuse in other options.
var currentCursorPos = console.cursorPosition;
var currentPosition = 0; // Saves the current input selected

var noInternet = false; // Checks when there is no internet.
var formatError = false; // Checks if there is a format error with the downloaded json.
var handShakeError = false; // Checks if there is a problem during the handShake phase.
var httpError = false; // Checks if there is a problem with http request.
var timeoutError = false; // Checks when the website takes too long to response.

ControlCharacter? keyPressed; // to catch which was pressed

