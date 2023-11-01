enum InputInfo {
  temperature('Temperature: ', ' °C'),
  dewpoint('Dewpoint: ', ' °C'),
  indicatedAlt('Indicated Altitude: ', ' FT'),
  baro('Baro: ', ' In Hg'),
  distance('Distance: ', ' NM'),
  time('Time: ', ' HR'),
  calibratedAir('Calibrated Airspeed: ', ' KT'),
  pressureAlt('Pressure Altitude: ', ' FT'),
  windDirection('Wind Direction: ', '°'),
  windSpeed('Wind Speed: ', ' KT'),
  runway('Runway: ', '°'),
  trueCourse('Course: ', '°'),
  trueAirspeed('True Airspeed: ', ' KT'),
  fuelVolume('Fuel Volume: ', ' GAL'),
  groundSpeed('Ground Speed: ', ' KT'),
  fuelRate('Fuel Rate: ', ' GAL/HR');

  const InputInfo(this.title, this.unit);
  final String title;
  final String unit;
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