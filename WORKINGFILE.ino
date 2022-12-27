#include <Adafruit_PWMServoDriver.h>
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

// our servo # counter
uint8_t servonum = 5;
int incomingClass = 0;

void setup() {
  Serial.begin(250000);
  for (int i=5; i<=12; i++){
    pinMode(i, OUTPUT);
  }
  
 pwm.begin();
 pwm.setPWMFreq(60);  // Analog servos run at ~60 Hz updates

              }


void Gesture0 () {
        //relaxed
   pwm.setPWM(11, 11, 300);   //150 = closed, 500 = open
   pwm.setPWM(12, 12, 400);   //150 = closed, 500 = open 
   pwm.setPWM(13, 13, 400);   //150 = closed, 500 = open
   pwm.setPWM(14, 14, 400);   //150 = closed, 500 = open
   pwm.setPWM(15, 15, 400);   //150 = closed, 500 = open     
   Serial.println("relaxed");
   Serial.write(incomingClass);
}

void Gesture1 () {
        //Thumb
   pwm.setPWM(11, 11, 500);   //150 = closed, 500 = open
   pwm.setPWM(12, 12, 150);   //150 = closed, 500 = open 
   pwm.setPWM(13, 13, 150);   //150 = closed, 500 = open
   pwm.setPWM(14, 14, 150);   //150 = closed, 500 = open
   pwm.setPWM(15, 15, 150);   //150 = closed, 500 = open
   Serial.println("thumb flexion");
   Serial.write(incomingClass);
}

void Gesture2() {
   //Index
   pwm.setPWM(11, 11, 150);   //150 = closed, 500 = open
   pwm.setPWM(12, 12, 560);   //150 = closed, 500 = open 
   pwm.setPWM(13, 13, 150);   //150 = closed, 500 = open
   pwm.setPWM(14, 14, 150);   //150 = closed, 500 = open
   pwm.setPWM(15, 15, 150);   //150 = closed, 500 = open
   Serial.println("Index Flexion");
   Serial.write(incomingClass);
}

   void Gesture3() {
   //Middle
   pwm.setPWM(11, 11, 150);   //150 = closed, 500 = open
   pwm.setPWM(12, 12, 150);   //150 = closed, 500 = open 
   pwm.setPWM(13, 13, 560);   //150 = closed, 500 = open
   pwm.setPWM(14, 14, 150);   //150 = closed, 500 = open
   pwm.setPWM(15, 15, 150);   //150 = closed, 500 = open
   Serial.println("Middle Flexion");
   Serial.write(incomingClass);
 }

   void Gesture4() {
   //Ring
   pwm.setPWM(11, 11, 150);   //150 = closed, 500 = open 
   pwm.setPWM(12, 12, 150);   //150 = closed, 500 = open 
   pwm.setPWM(13, 13, 150);   //150 = closed, 500 = open
   pwm.setPWM(14, 14, 560);   //150 = closed, 500 = open
   pwm.setPWM(15, 15, 150);   //150 = closed, 500 = open
   Serial.println("Ring Flexion");
   Serial.write(incomingClass);
 }

  void Gesture5(){
   //Pinky
   pwm.setPWM(11, 11, 150);   //150 = closed, 500 = open 
   pwm.setPWM(12, 12, 150);   //150 = closed, 500 = open 
   pwm.setPWM(13, 13, 150);   //150 = closed, 500 = open
   pwm.setPWM(14, 14, 150);   //150 = closed, 500 = open
   pwm.setPWM(15, 15, 560);   //150 = closed, 500 = open
   Serial.println("Pinky Flexion");
   Serial.write(incomingClass);
  }

  void Gesture6() {
  //grasp
   pwm.setPWM(11, 11, 150);   //150 = closed, 500 = open 
   pwm.setPWM(12, 12, 150);   //150 = closed, 500 = open 
   pwm.setPWM(13, 13, 150);   //150 = closed, 500 = open
   pwm.setPWM(14, 14, 150);   //150 = closed, 500 = open
   pwm.setPWM(15, 15, 150);   //150 = closed, 500 = open
   Serial.println("Grasp");
   Serial.write(incomingClass);
  }
  
void loop() {
  if (Serial.available() > 0){
    incomingClass = Serial.read();
    Serial.println(incomingClass);
    switch (incomingClass){
     case 0:
      Gesture0();
      break;
     case 1:
      Gesture1();
      break;
      ///////////////////////   
     case 2:
      Gesture2();
      break;
     case 3:
      Gesture3();
      break; 
     ///////////////////////
    case 4:
      Gesture4();
      break;
    case 5:
      Gesture5();
      break; 
     ///////////////////////
     case 6:
      Gesture6();
      break;
     ///////////////////////
  }
}
}
