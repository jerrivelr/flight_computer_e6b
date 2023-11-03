enum InputInfo {
  temperature('Temperature: '),
  dewpoint('Dewpoint: '),
  indicatedAlt('Indicated Altitude: '),
  baro('Baro: '),
  distance('Distance: '),
  time('Time: '),
  calibratedAir('Calibrated Airspeed: '),
  pressureAlt('Pressure Altitude: '),
  windDirection('Wind Direction: '),
  windSpeed('Wind Speed: '),
  runway('Runway: '),
  trueCourse('Course: '),
  trueAirspeed('True Airspeed: '),
  fuelVolume('Fuel Volume: '),
  groundSpeed('Ground Speed: '),
  fuelRate('Fuel Rate: ');

  const InputInfo(this.title);
  final String title;
}

enum OptionIdent {
  helpSetting,
  help,
  setting,
  menu,
  exit,
  cloudBase,
  pressDenAlt,
  airport,
  manual,
  groundSpeed,
  calGroundSpeed,
  groundDur,
  groundDis,
  trueAirspeed,
  windComp,
  windCorrection,
  fuel,
  fuelVol,
  fuelDur,
  fuelRate,
  yes,
  no;
}