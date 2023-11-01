import 'package:dart_console/dart_console.dart';
import 'package:flight_e6b/menu_files/menu_logic.dart';

final console = Console();

var errorMessage = ''; // Stores errors messages if any.
OptionIdent? selectedOption; // Stores values that are part of the optionList if userInput equals to one of the options.
var inputValues = <InputInfo?, String?>{}; // This Map will contain the calculated data for reuse in other options.
var currentCursorPos = console.cursorPosition;
var currentPosition = 0; // Saves the current input selected

var noInternet = false; // Checks when there is no internet.
var screenCleared = false; // To check the screen has been clear.
var formatError = false; // Checks if there is a format error with the downloaded json.
var handShakeError = false; // Checks if there is a problem during the handShake phase.
var httpError = false; // Checks if there is a problem with http request.
var timeoutError = false; // Checks when the website takes too long to response.

ControlCharacter? keyPressed; // to catch which was pressed

