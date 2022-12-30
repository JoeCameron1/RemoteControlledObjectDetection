// Touch-Free Remote-Controlled Object Detection
// Processing Code
// CS5041 P3 Special Project
// Author = Joseph Manfredi Cameron

// Import Statements
import de.voidplus.leapmotion.*;
import processing.serial.*;
import processing.video.*;

// The Leap Motion Sensor
LeapMotion leap;

// Servo motor angle
int angle;
// Servo motor rotation lock variables
boolean servoToggle;
boolean toggled;
int servoToggleTimer;

// Ultrasound distance from ultrasound Arduino
String ultrasoundDistance;

// Serial ports
Serial servoPort; // Serial port to servo motor arduino
Serial ultrasoundPort; // Serial port to ultrasound arduino

// Live video feed from webcam
Capture video;

// Save photo variables
int pinchTimer;
boolean pinched;
ArrayList<PImage> savedImages;
ArrayList<int[]> informationOnObjects;

// Variables to enable scroll via translation
float translateX, translateY;

// Gesture variables for selecting parameters
int parameterSelection;
boolean gestureMade;
int gestureTimer;

// -----------------------------------------------------------

public void setup() {
  // Setup Window
  size(1200, 720);

  // Setup LeapMotion Object
  leap = new LeapMotion(this).allowGestures("circle");

  // Setup Serial Port
  // NOTE: THIS DIFFERS BASED ON YOUR COMPUTER
  servoPort = new Serial(this, Serial.list()[8], 9600);
  servoPort.bufferUntil(' ');
  ultrasoundPort = new Serial(this, Serial.list()[9], 9600);
  ultrasoundPort.bufferUntil('\n');
    
  // Setup Live Video Feed from Webcam
  // NOTE: THIS DIFFERS BASED ON YOUR COMPUTER
  video = new Capture(this, Capture.list()[1]);
  video.start();
    
  // Setup the capability of saving photos
  savedImages = new ArrayList<PImage>();
  pinchTimer = 0;
  pinched = false;
  informationOnObjects = new ArrayList<int[]>();
    
  // Setup the capability of locking the servo motor's rotation
  servoToggleTimer = 0;
  toggled = false;
  servoToggle = false;
  
  // Setup the capability of selecting different parameters
  // Parameter Selection defaults to 1 (distance)
  parameterSelection = 1;
  gestureMade = false;
  gestureTimer = 0;
}

// -----------------------------------------------------------

// This is called whenever the camera gets a new image to display
void captureEvent(Capture video) {
  video.read();
}

// -----------------------------------------------------------

// This is called whenever Processing receives a serial message from one of the Arduinos
void serialEvent(Serial port) {
  if (port == ultrasoundPort) {
    ultrasoundDistance = ultrasoundPort.readString();
  }
}

// -----------------------------------------------------------

public void draw() {
  background(0);
  translate(translateX, translateY); // Scroll by translation
  textSize(20);
  textAlign(CENTER);
  stroke(255);
    
  // Pinch gesture to save photo (only with second hand)
  // Determines that it can only be done every few seconds
  if (pinched) {
    fill(255, 0, 0);
    rectMode(CENTER);
    rect(920, 460, 500, 30);
    fill(255);
    text("You saved a screenshot of the camera display!", 920, 465);
    pinchTimer--;
  }
  if (pinchTimer <= 10 && pinchTimer >= 1) {
    servoPort.write(999); // Send a message to the Servo Arduino that turns off the red LED
  }
  if (pinchTimer <= 0) {
    pinched = false;
    pinchTimer = 0;
  }
    
  // Pinch gesture for locking/unlocking the servo motor (only with initial hand)
  // Determines that it can only be done every few seconds
  if (toggled) {
    servoToggleTimer--;
  }
  if (servoToggleTimer <= 0) {
    toggled = false;
    servoToggleTimer = 0;
  }
  
  // Circle gesture to switch parameter mode
  // Determines that it can only be done every few seconds
  if (gestureMade) {
    gestureTimer--;
  }
  if (gestureTimer <=0) {
    gestureMade = false;
    gestureTimer = 0;
  }
  
  // Display Live Video Feed from Webcam
  image(video, 0, 0);
    
  // Keeps track of distance between two hands if two hands are present
  // Resets to 0 whenever there are less than two hands present
  int distanceBetweenHands = 0;
    
  if (leap.getHands().size() > 0) {
    Hand firstHand = leap.getHands().get(0);
    text("Rotate this hand to rotate the servo motor.", 920, 180);
    // Lock/Unlock servo motor rotation pinch gesture
    if ((firstHand.getPinchStrength() > .8) && (!toggled)) {
      toggled = true;
      toggleServoAngle();
      servoToggleTimer = 60;
    }
    if (!servoToggle && !toggled) {
      text("Rotation = Unlocked (Pinch to lock)", 920, 240);
      int yaw = (int) firstHand.getYaw(); // Getting yaw angle of hand from leap motion sensor
      yaw = yaw + 90;
      if (yaw < 0) {
        angle = 0;
      } else if (yaw > 180) {
        angle = 180;
      } else {
        angle = yaw;
      }
    } else {
      text("Rotation = Locked (Pinch to unlock)", 920, 240);
    }
    if (leap.getHands().size() > 1) {
      Hand secondHand = leap.getHands().get(1);
      text("The distance between your hands controls the option parameters.", 920, 300);
      // Distance between both hands is used for all mappings for all parameters
      distanceBetweenHands = (int) dist(firstHand.getPosition().x, firstHand.getPosition().y, secondHand.getPosition().x, secondHand.getPosition().y);
      
      if (parameterSelection == 1) {
        
        // DISTANCE PARAMETER
        
        int sensorDistance = (int) map(distanceBetweenHands, 150, 1000, 2, 100);
        if (sensorDistance > 5) {
          text("Sensing at a distance of: " + sensorDistance, 920, 360);
          if (sensorDistance >= parseUltrasoundDistance(ultrasoundDistance)) {
            fill(0, 0, 255);
            rectMode(CENTER);
            rect(920, 420, 300, 50);
            fill(255);
            text("OBJECT DETECTED", 920, 425);
            servoPort.write(997); // Send a message to the Servo Arduino that plays the piezo buzzer sound
          }
        }
        
      } else if (parameterSelection == 2) {
        
        // BRIGHTNESS PARAMETER
        
        loadPixels();
 
        for (int x = 0; x < video.width; x++ ) {
          for (int y = 0; y < video.height; y++ ) {

            // Calculate the pixel index for 1D array
            int pixelIndex = x + y*width;

            // Get the R,G,B values from pixel
            float r = red(pixels[pixelIndex]);
            float g = green(pixels[pixelIndex]);
            float b = blue(pixels[pixelIndex]);

            // Brightness adjustment
            float adjustBrightness = map(distanceBetweenHands, 150, 1000, 0, 8);
            
            // New brightness
            r *= adjustBrightness;
            g *= adjustBrightness;
            b *= adjustBrightness;
            r = constrain(r, 0, 255); 
            g = constrain(g, 0, 255);
            b = constrain(b, 0, 255);

            // Replace pixel value with this new colour
            color c = color(r, g, b);
            pixels[pixelIndex] = c;
          }
        }

        updatePixels();
        
      } else if (parameterSelection == 3) {
        
        // SATURATION PARAMETER
        
        loadPixels();
        colorMode(HSB, 255);
 
        for (int x = 0; x < video.width; x++ ) {
          for (int y = 0; y < video.height; y++ ) {

            // Calculate the pixel index for 1D array
            int pixelIndex = x + y*width;

            // Get the H,S,B values from pixel
            color c = pixels[pixelIndex];
            float hue = hue(c);
            float saturation = saturation(c);
            float brightness = brightness(c);

            // Saturation adjustment
            float adjustSaturation = map(distanceBetweenHands, 150, 1000, 0, 8);
            
            // New saturation
            saturation *= adjustSaturation;
            saturation = constrain(saturation, 0, 255);

            // Replace pixel value with this new colour
            color newC = color(hue, saturation, brightness);
            pixels[pixelIndex] = newC;
          }
        }

        updatePixels();
        colorMode(RGB);
        
      }
      
      // Save-photo pinch gesture
      if ((secondHand.getPinchStrength() > .8) && (!pinched)) {
        pinched = true;
        savePhoto();
        pinchTimer = 120;
      }
    } else {
      text("Hover your other hand over the leap motion sensor.", 920, 300);
    }
  } else {
    text("Hover a hand over the leap motion sensor.", 920, 180);
  }
    
  // Send the hand angle to the Arduino to move the motor to that angle
  servoPort.write(angle);
    
  // Display Previously Saved Photos and their associated information
  for (int i = 0; i < savedImages.size(); i++) {
    image(savedImages.get(i), 0, 500*(i+1));
    text("Object " + informationOnObjects.get(i)[0], 920, 520*(i+1));
    text("Object Distance = " + informationOnObjects.get(i)[1], 920, (520*(i+1))+60);
    text("Angle of View = " + informationOnObjects.get(i)[2] + " Degrees", 920, (520*(i+1))+120);
    line(0, ((500*(i+1)) + video.height), width, ((500*(i+1)) + video.height));
  }
  
  // Draw Title
  textAlign(CENTER);
  textSize(40);
  text("Touch-Free", 800, 50);
  text("Remote-Controlled", 800, 90);
  text("Object Detection", 800, 130);
  // Draw Parameters
  textSize(15);
  text("Distance", 1050, 30);
  text("Brightness", 1100, 50);
  text("Saturation", 1000, 50);
  stroke(255, 0, 0);
  noFill();
  rectMode(CENTER);
  if (parameterSelection == 1) {
    // Distance
    rect(1050, (30-5), 75, 25);
  } else if (parameterSelection == 2) {
    // Brightness
    rect(1100, (50-5), 75, 25);
  } else if (parameterSelection == 3) {
    // Saturation
    rect(1000, (50-5), 75, 25);
  }
  stroke(255);
  
  // Draw first line separator
  line(0, video.height, width, video.height);
  
  // Draw crosshair
  stroke(255, 0, 0);
  circle(320, 240, 50);
  line(320, 240, 300, 220);
  line(320, 240, 340, 220);
  line(320, 240, 300, 260);
  line(320, 240, 340, 260);
    
}

// -----------------------------------------------------------

// Enables a scroll effect to see other saved photos for the session
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  translateY += e;
}

// -----------------------------------------------------------

// Saves a photo by storing it in the current ArrayList object
public void savePhoto() {
  PImage screenshot = video.get(0, 0, video.width, video.height);
  savedImages.add(screenshot); // Save the video screenshot
  int[] objectInformation = new int[3];
  objectInformation[0] = informationOnObjects.size() + 1;
  objectInformation[1] = parseUltrasoundDistance(ultrasoundDistance);
  objectInformation[2] = angle;
  informationOnObjects.add(objectInformation); // Add associated object info
  servoPort.write(998); // Send a message to the Servo Arduino that turns on the red LED
}

// -----------------------------------------------------------

// Toggle function for either locking or unlocking the servo motor
public void toggleServoAngle() {
  if (servoToggle) {
    servoToggle = false;
  } else {
    servoToggle = true;
  }
}

// -----------------------------------------------------------

// My custom parser to turn the ultrasound distance String provided by Arduino into an int
public int parseUltrasoundDistance(String d) {
  d = d.replaceAll("[^0-9]", ""); // Get rid of any unncessary characters
  int parsedDistance = 0;
  try {
    parsedDistance = Integer.parseInt(d);
  } catch (NumberFormatException nfe) {
    // In case of number format exception, return long distance
    parsedDistance = 1000000;
  }
  return parsedDistance;
}

// -----------------------------------------------------------

// This function is called whenever a circle gesture is recognised from the leap motion sensor
void leapOnCircleGesture(CircleGesture g, int state) {
  float durationSeconds = g.getDurationInSeconds();
  //println(durationSeconds);
  if ((!gestureMade) && (durationSeconds > 0.1)) {
    println("CIRCLE GESTURE DETECTED");
    int direction = g.getDirection();
    if ((parameterSelection == 1) && (direction == 1)) {
      // Clockwise from distance
      parameterSelection = 2;
    } else if ((parameterSelection == 2) && (direction == 1)) {
      // Clockwise from brightness
      parameterSelection = 3;
    } else if ((parameterSelection == 3) && (direction == 1)) {
      // Clockwise from saturation
      parameterSelection = 1;
    } else if ((parameterSelection == 1) && (direction == 0)) {
      // Anti-Clockwise from distance
      parameterSelection = 3;
    } else if ((parameterSelection == 2) && (direction == 0)) {
      // Anti-Clockwise from brightness
      parameterSelection = 1;
    } else if ((parameterSelection == 3) && (direction == 0)) {
      // Anti-Clockwise from saturation
      parameterSelection = 2;
    }
    gestureMade = true;
    gestureTimer = 120;
  }
}
