/* This Script is the bare bones needed to Keep a Uptime counter that will survive the 50 days timer rollover
This will not give a uptime of great accuracy over long periods, but it will let you see if your arduino has reset
if you want better accuracy, pull the Unix time from the IOT, External RTC or GPS module
Also Reconnecting the serial com's will reset the arduino. So this is mainly useful for a LCD screen

Michael Ratcliffe  Mike@MichaelRatcliffe.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see .
*/

#include <Arduino.h>

struct Uptime
{
  long Days = 0;
  int Hours = 0;
  int Minutes = 0;
  int Seconds = 0;
  int HighMillis = 0;
  int Rollover = 0;

  const long DAY = 86400000; // 86400000 milliseconds in a day
  const long HOUR = 3600000; // 3600000 milliseconds in an hour
  const long MINNUTE = 60000; // 60000 milliseconds in a minute
  const long SECOND = 1000;  // 1000 milliseconds in a second

  ulong lastUpdateTime = millis();
  const ulong updateDelay = 1000;

  // Runs the uptime script located below the main loop and reenters the main loop
  void update()
  {
    ulong milliesNow = millis();

    if ((milliesNow - lastUpdateTime) > updateDelay)
    {
      lastUpdateTime = milliesNow;

      //** Making Note of an expected rollover *****//
      if (milliesNow >= 3000000000)
      {
        HighMillis = 1;
      }

      //** Making note of actual rollover **//
      if (milliesNow <= 100000 && HighMillis == 1)
      {
        Rollover++;
        HighMillis = 0;
      }

      // First portion takes care of a rollover [around 50 days]
      Days = (milliesNow / DAY) + (Rollover * 50);
      Hours = (milliesNow % DAY) / HOUR;
      Minutes = ((milliesNow % DAY) % HOUR) / MINNUTE;
      Seconds = (((milliesNow % DAY) % HOUR) % MINNUTE) / SECOND;

      // debug
      // Days = (((milliesNow % DAY) % HOUR) % MINNUTE) % SECOND;
    }
  };

  // Get system uptime as string
  String getUptime()
  {
    String secs_o = ":";
    String mins_o = ":";
    String hours_o = ":";

    if (Seconds < 10)
      secs_o = ":0";

    if (Minutes < 10)
      mins_o = ":0";

    if (Hours < 10)
      hours_o = ":0";

    return Days + hours_o + Hours + mins_o + Minutes + secs_o + Seconds;
  }
};
