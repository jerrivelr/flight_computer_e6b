import 'package:dart_console/dart_console.dart';

final console = Console();

// List of possible options while inside a certain screen.
const optionList = ['opt1', 'opt2', 'opt3', 'opt4', 'opt5', 'opt6', 'opt7', 'menu', 'exit'];

var error = ''; // Stores errors messages if any.
String? selectedOption; // Stores values that are part of the optionList if userInput equals to one of the options
Map<String, num> dataResult = {}; // This Map will contain the calculated data for reuse in other options.
bool noInternet = false; // Checks when there is no internet.
bool backOnline = false; // Checks when the internet comes back.
bool screenCleared = false; // To check the screen has been clear
bool formatError = false; // Check if there is a format error with the downloaded json