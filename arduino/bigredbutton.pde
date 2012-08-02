/*
 * bigredbutton.pde
 * Created by Matt Greensmith, 1 Aug 2012
 */

const int buttonPin = 2;
const int ledPin = 13;

int ledState = HIGH;         // the current state of the output pin
int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin
long lastDebounceTime = 0;  // the last time the output pin was toggled
long debounceDelay = 50;    // the debounce time; increase if the output flickers

int userInput;       // raw input from serial buffer

void setup() 
{ 
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);

  // Open the serial connection, 9600 baud
  Serial.begin(9600);
} 

void loop() 
{ 
  
  // Wait for serial input 
  if (Serial.available()) {
    userInput = Serial.read();
    switch (userInput) {
      case 1:
        ledState = HIGH;
        break;
      case 2:
        ledState = LOW;
        break;
    }
    digitalWrite(ledPin, ledPinState);
  }

  int reading = digitalRead(buttonPin);
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  } 
  
  if ((millis() - lastDebounceTime) > debounceDelay) {
    buttonState = reading;
    //TODO: if buttonstate is high, send the serial packet
  }

  //digitalWrite(ledPin, buttonState);

  lastButtonState = reading;
  
}

