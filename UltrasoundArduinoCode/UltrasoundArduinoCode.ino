// Arduino Code for Touch-Free Remote-Controlled Object Detection
// For the Ultrasound Arduino
// CS5041 P3 Special Project
// Author = Joseph Manfredi Cameron

#define trigPin 10
#define echoPin 13

// Time spent for ultrasound signal to be sent and received
float duration;
// Calculated distance to object
int distance;

// ------------------------------------------------

void setup() {
  // Setup serial communication
  Serial.begin(9600);
  // Setup pins for the ultrasound sensor
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

// ------------------------------------------------

void loop() {
  
  // Send an initial ultrasound pulse
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  
  // Measure the duration of the pulse
  duration = pulseIn(echoPin, HIGH);
  
  // Calculate the distance based on speed of sound in air
  distance = (int) ((duration/2)*0.0343);
  
  // Ultrasound sensor only measures from 2cm to 400cm
  // So, eliminate all other readings
  if ((distance <= 2) || (distance >= 400)) {
    // Send a default message if there are no readings
    Serial.println("NA");
  } else {
    // Send the measured distance over serial
    Serial.println(distance);
    // Delay to get smoother readings
    delay(500);
  }

  // Another delay to get even smoother readings
  delay(500);
  
}
