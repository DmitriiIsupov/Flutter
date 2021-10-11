/**** Flash a given pin for a given sequence for one time, or forever.
In the folowing example, the flasher1 is  blinking an LED for given pattern one time when `start()`
if called. While flasher3 wil start blinking the same LED forever for given pattern on `start()`
and will only stop and `stop()`. Flasher named flasher3 is also blinking an LED forever on given pattern.

uint32_t sequence1[] = {100, 80, 100, 80, 100, 80, 0};
uint32_t sequence2[] = {500, 250, 0};
uint32_t sequence3[] = {1500, 800, 0};

Flasher flasher1(_PIN_OUT_LED, sequence1, false);
Flasher flasher2(_PIN_OUT_BEEPER, sequence2, true);
Flasher flasher3(_PIN_OUT_LED, sequence3, true);

void setup()
{
  flasher1.setup();
  flasher2.setup();
  flasher3.setup();

  flasher2.start();
  flasher3.start();
}

void loop()
{
  flasher1.loop();
  flasher2.loop();
  flasher3.loop();
}

*** Source: https://forum.arduino.cc/index.php?topic=452096.0
*** Modified by ch3ckmat3 (13-Feb-2019)
*** */
#include <Arduino.h>

struct Flasher
{
  const byte pin;
  const uint32_t *sequence;
  const boolean flashForever = false;

  int sequenceIndex;
  boolean flashOn = false;
  boolean startFlag = false;
  uint32_t startTime;

  Flasher(byte attachPin, const uint32_t *sequence, const boolean flashForever)
      : pin(attachPin), sequence(sequence), flashForever(flashForever)
  {
    flashOn = false;
    startFlag = false;
    sequenceIndex = 0;
  }

  void setup()
  {
    pinMode(pin, OUTPUT);
    //start with the LED off
    digitalWrite(pin, LOW);
  }

  void start()
  {
    startTime = millis();
    startFlag = true;
  }

  void stop()
  {
    startFlag = false;
  }

  void loop()
  {
    if (startFlag)
    {
      if (millis() - startTime >= sequence[sequenceIndex])
      {
        sequenceIndex++;
        if (sequence[sequenceIndex] == 0)
        {
          sequenceIndex = 0;
          if (!flashForever)
            startFlag = false;
        }

        startTime = millis();

        flashOn = !flashOn;
        digitalWrite(pin, flashOn ? HIGH : LOW);
      }
    }
  }
};

struct Fader
{
  const byte pin;
  const uint32_t fadeTime;

  uint32_t startTime;
  boolean gettingBrighter;

  Fader(byte attachPin, uint32_t fadeTime) : pin(attachPin), fadeTime(fadeTime)
  {
    startTime = millis();
    gettingBrighter = true;
  }

  void setup()
  {
    pinMode(pin, OUTPUT);
  }

  void loop()
  {
    if (millis() - startTime >= fadeTime)
    {
      startTime = millis();
      gettingBrighter = !gettingBrighter;
    }

    if (gettingBrighter)
    {
      analogWrite(pin, (millis() - startTime) / ((double)fadeTime) * 255);
    }
    else
    {
      analogWrite(pin, 255 - (millis() - startTime) / ((double)fadeTime) * 255);
    }
  }
};

/*
Fader fader1(5, 1000L), fader2(6, 1616L);

uint32_t sequence1[] = {1000, 0};
uint32_t sequence2[] = {250, 500, 250, 2000, 0};

Flasher flasher1(9, sequence1), flasher2(10, sequence2);

void setup()
{
  flasher1.setup();
  flasher2.setup();
  fader1.setup();
  fader2.setup();
}

void loop()
{
  // put your main code here, to run repeatedly:
  flasher1.loop();
  flasher2.loop();
  fader1.loop();
  fader2.loop();
}
*/
