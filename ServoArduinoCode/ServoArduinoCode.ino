// Arduino Code for Touch-Free Remote-Controlled Object Detection
// For the Servo Motor Arduino
// CS5041 P3 Special Project
// Author = Joseph Manfredi Cameron

#include <Servo.h>

// Servo Motor
Servo myServo;

// For reading messages from Processing
byte incomingByte;

// LED for indicating that an image has been saved
const int redLEDPin = 7;

// ------------------------------------------------

void setup() {
  // Setup LED for indicating saved images
  pinMode(redLEDPin, OUTPUT);
  digitalWrite(redLEDPin, LOW);
  // Setup servo motor
  myServo.attach(9);
  Serial.begin(9600);
  myServo.write(0);
}

// ------------------------------------------------

void loop() {
  // Angle for the servo motor
  byte angle;
  if (Serial.available()) {
    // Read message from Processing
    incomingByte = Serial.read();
    if (incomingByte == byte(998)) {
      // Turn on LED
      digitalWrite(redLEDPin, HIGH);
    } else if (incomingByte == byte(999)) {
      // Turn off LED
      digitalWrite(redLEDPin, LOW);
    } else if (incomingByte == byte(997)) {
      // Play sound at 1000Hz from the piezo buzzer
      tone(8, 1000, 50);
    } else {
      // Turn servo motor to the angle sent from Processing
      angle = incomingByte;
      myServo.write(angle);
    }
    Serial.println(angle);
  }
}
