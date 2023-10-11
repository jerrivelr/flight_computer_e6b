# Flight Computer E6B
This is a command-line application that performs common E6B calculations
## It Calculates the Following:
- Cloud Base
- Pressure and Density Altitude from an airport's current METAR (if available)
- Pressure and Density Altitude using manual values
- Ground Speed using distance and time, and wind
- True Airspeed
- Heading
- Wind Correction Angle
- Fuel Consumption
## File Purposes:
- **\bin\ _flight_computer.dart_:** contains the main function
- **\lib\airport_database\ _airports.json_:** contains a database of almost all airports
- **\lib\data_parsing\ _airport_data.dart_:** contains functions to parse data from the airport database
- **\lib\data_parsing\ _metar_data.dart_:** contains the function to download METAR information
- **\lib\inter_screens:** contains files for the menus inside other options
- **\lib\main_screens:** contains the file for all functions for each screen
- **\lib\ _aviation_math.dart_:** contains all the functions used to make E6B calculations
- **\lib\ _communication_var.dart:** contains all the global variable shared between menu options for communication
- **\lib\ _menu_logic.dart_:** contains a class and enums that are used for the logic on each option
- **\lib\ _read_line_custom.dart_:** contains a custom implementation of the readLine function inside the Console class
- **\lib\ _shortcuts.dart_:** contains all shortcuts used in the application
- **\lib\ _simple_io.dart_:** contains functions for input and output especially suited for this application
