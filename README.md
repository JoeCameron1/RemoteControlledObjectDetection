# Touch-Free Remote-Controlled Object Detection

This project was inspired by the circumstances presented during the COVID-19 global pandemic and was created by me, Joseph Manfredi Cameron, for an assignment in the Interactive Software & Hardware (CS5041) module at the University of St Andrews.

A **report** of this project's details, software and hardware specifications, and creation can be found [here](Report/CS5041-P3-Report.pdf).

## Abstract

In this project, the aim was to exploit the interactive capabilities of the [Leap Motion sensor](https://www.ultraleap.com/product/leap-motion-controller/) to create an effective and intuitive system for detecting objects where users are not required to touch physical objects but instead make use of their bodies to achieve interaction.
The system for detecting objects additionally has the capability for remote control, as the detection rig makes use of a camera which provides the user with a live video feed, hence users do not necessarily need to be present with the objects being detected.
The context of this object-detection system is that it may be used on-board robots or rovers to explore new territory, or for high-pressure scenarios such as bomb diffusion where operators need to efficiently survey the surrounding area without being physically present.

There are a couple of main motivations for making a touch-free remote-controlled system in this project.
Firstly, with the presence of the COVID-19 global pandemic, there has been a highlighted need for systems that minimise contamination spread via both lack of physical contact with objects, and remote working where the distance between people is large enough to prevent viral spread.
This system successfully allows for both factors to be accounted for.
Also, most systems that require expertise to operate, particularly in this field of remote-object detection via controlling robots and rovers etc., usually are operated via touching joysticks and buttons that require users to learn and memorise abstract and arbitrary interactions.
However, the Leap Motion controller allows users to instead interact via natural touch-free interactions that we as humans are more naturally familiar with.
Interacting with the Leap Motion controller can trick the human brain into “feeling” like part of the system, rather than traditional methods that very much reinforce that you are operating a foreign system.
It is insightful to see the effects on users that these intuitive interactions (via the Leap Motion controller) allowed when operating a versatile object- detection system of this nature.

This project was developed with [Processing](https://processing.org), two [Arduino Uno microcontrollers](https://www.arduino.cc), and of course the [Leap Motion sensor](https://www.ultraleap.com/product/leap-motion-controller/) and its accompanying software libraries.
The Leap Motion sensor acts as a main input to the system, where it can track users’ hands to move/activate hardware components connected to the Arduino microcontrollers or change settings of the system software in Processing.
The software developed in Processing acts as a central hub for the entire system, and also serves as one of the main outputs of the system as it displays a live camera feed and continuously provides feedback to users via a display screen.

## How to run the Touch-Free Remote-Controlled Object Detection Rig and Processing Sketch Code
* Arduino Code:
First, upload the [UltrasoundArduinoCode.ino](UltrasoundArduinoCode/UltrasoundArduinoCode.ino) file located in the "UltrasoundArduinoCode" folder to the Arduino Uno micro controller that controls the ultrasonic sensor specified in the [project report](Report/CS5041-P3-Report.pdf).
Next, upload the [ServoArduinoCode.ino](ServoArduinoCode/ServoArduinoCode.ino) file located in the "ServoArduinoCode" folder to the Arduino Uno micro controller that controls the servo motor, LED, and piezo buzzer circuit as specified in the [project report](Report/CS5041-P3-Report.pdf).
* Processing Code:
Open the 'CS5041_P3' sketch folder and run the [CS5041_P3.pde](CS5041_P3/CS5041_P3.pde) file in the Processing IDE.
NOTE: You may have to update lines 56, 58, and 63 in the [CS5041_P3.pde](CS5041_P3/CS5041_P3.pde) file with your computer's details (as your computer will be different from the one I developed this on).

## Video
A brief video demonstration of this touch-free remote-controlled object detection rig in action can be accessed by clicking on the preview image below or by clicking [here](https://youtu.be/TFleQi-fThE).

[![Watch the video](https://img.youtube.com/vi/TFleQi-fThE/hqdefault.jpg)](https://youtu.be/TFleQi-fThE)
