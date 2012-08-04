/* 
 
 The circuit:
 * normally open pushbutton attached from pin 8 to +5V
 * 10-kohm resistor attached from pin 8 to ground

*/

const int buttonPin = 8;          // input pin for pushbutton
const long debounceDelay = 50;    // the debounce time; increase if the output flickers

int buttonState;             // the current reading from the input pin
int lastButtonState = LOW;   // the previous reading from the input pin
long lastDebounceTime = 0;  // the last time the output pin was toggled
boolean sentEvent = false;

void setup() {
  pinMode(buttonPin, INPUT);
  Keyboard.begin();
}

void loop() {
  int reading = digitalRead(buttonPin);
    
  // If the switch changed, due to noise or pressing:
  if (reading != lastButtonState) {
    // reset the debouncing timer
    lastDebounceTime = millis();
  } 
  
  if ((millis() - lastDebounceTime) > debounceDelay) {
    // whatever the reading is at, it's been there for longer
    // than the debounce delay, so take it as the actual current state:
    buttonState = reading;
    if ( buttonState == HIGH ) {
      if ( sentEvent == false ) {
        //it's the rising edge of the button press, send the key!
        Keyboard.print(" ");
        sentEvent = true;
      }
    } else {
      //button is low
      sentEvent = false;
    }
  }
  
  // save the current button state for comparison next time:
  lastButtonState = reading; 
}

