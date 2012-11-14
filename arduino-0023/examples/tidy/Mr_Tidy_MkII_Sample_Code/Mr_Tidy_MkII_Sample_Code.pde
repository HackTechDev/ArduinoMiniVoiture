// Demo code for Mr.tidy MkII

#include <EEPROM.h>
#include "IOpindefinitions.h"
#include "constants.h"
#include "pitches.h"


// define Global Variables
                                                                    
int batteryvoltage;                                                      // analog input * 14.97                   
byte voltindex;                                                          // index for batteryvoltage
int averagevoltage;                                                      // average of last 4 readings
int oldbatteryvoltage;                                                   // old average battery voltage
int batterymode;                                                         // 0=normal 1=flat or recharge
long sampletime;                                                         // used to measure time period for checking battery voltage
long time;                                                               // used for chasing the LEDs              used to measure elapsed time
int lightchase;                                                          // used for chasing the LEDs              pattern 1 to 4

int frontfarleftvalue;                                                   // value of front far left IR sensor       analog input
int frontmidleftvalue;                                                   // value of front middle left IR sensor    analog input
int frontmidrightvalue;                                                  // value of front middle right IR sensor   analog input
int frontfarrightvalue;                                                  // value of front far right IR sensor      analog input
int frontmidaverage;                                                     // Value of front middle IR sensors 
int frontfaraverage;                                                     // Value of front far IR sensors 
int frontaverage;                                                        // average of the 4 front sensor inputs
int objectsize;                                                          // used to determine if object can be picked up


int frontfarleftvalueon;                                                 // value of front far left IR sensor when turned on facing free space
int frontmidleftvalueon;                                                 // value of front middle left IR sensor when turned on facing free space
int frontmidrightvalueon;                                                // value of front middle right IR sensor when turned on facing free space
int frontfarrightvalueon;                                                // value of front far right IR sensor when turned on facing free space
int frontfarleftvalueoff;                                                // value of front far left IR sensor when turned off facing free space
int frontmidleftvalueoff;                                                // value of front middle left IR sensor when turned off facing free space
int frontmidrightvalueoff;                                               // value of front middle right IR sensor when turned off facing free space
int frontfarrightvalueoff;                                               // value of front far left IR sensor when turned off facing free space
int frontfarleftvaluebase;                                               // Ambient value of front far left IR sensor
int frontmidleftvaluebase;                                               // Ambient value of front middle left IR sensor 
int frontmidrightvaluebase;                                              // Ambient value of front middle right IR sensor
int frontfarrightvaluebase;                                              // Ambient value of front far right IR sensore

byte frontleftside;                                                      // value of front left side IR sensor      digital input
byte frontrightside;                                                     // value of front right side IR sensor     digital input
byte rearleft;                                                           // value of rear left IR sensor            digital input
byte rearright;                                                          // value of rear right IR sensor           digital input

int redvalue;                                                            // value of LDR with RED   led on          analog  input
int greenvalue;                                                          // value of LDR with GREEN led on          analog  input
int bluevalue;                                                           // value of LDR with BLUE  led on          analog  input
int ambientvalue;                                                        // value of LDR with ALL leds off          analog  input
int lightvalue;                                                          // average value of colours
int objectcolour;                                                        // colour of an object

byte haveobject;                                                         // 0=no object, 1=red object, 2=green object, 3=blue object

volatile int leftencodervalue;                                           // left encoder pulse counter              digital input interupt 0
volatile int rightencodervalue;                                          // left encoder pulse counter              digital input interupt 1
volatile int armencodervalue;                                            // left encoder pulse counter              digital input interupt 4
volatile int gripencodervalue;                                           // left encoder pulse counter              digital input interupt 5

int armspeed=0;                                                          // Arm Speed variable
int gripspeed=0;                                                         // Grip speed variable
int leftspeed;                                                           // speed of left motor                    -255 to 255
int rightspeed;                                                          // speed of right motor                   -255 to 255
int lcount=0;                                                            // counts failed attempts if left motor stalls
int rcount=0;                                                            // counts failed attempts if right motor stalls
int acount=0;                                                            // counts failed attempts if arm jams
int gcount=0;                                                            // counts failed attempts if gripper jams
int objectattempt;                                                       // counts failed attepts to locate object
int leftcurrent;                                                         // current drawn by left motor             analog input
int rightcurrent;                                                        // current drawn by right motor            analog input
int armcurrent;                                                          // current drawn by arm motor              analog input
int gripcurrent;                                                         // current drawn by gripper motor          analog input

int chosencolour=0;                                                      // temp store for storing colour of current pickup "Pair"
long rand_number;                                                        // Random number store
int cupcounter=0;                                                        // Keeps count of raised cups
int cyan_counter=0;                                                      // Keeps count of cyan cups
int red_counter=0;                                                       // Keeps count of red cups
int objectcounter=0;                                                     // Keeps count of objects
int stalltimer=0;                                                        // Timer value used for time_ing gripper/arm movement ie if greater than 5 seconds assume motor has stalled
int dist2object=2;                                                       // distance to pick up cups 
int storeleftspeed;                                                      // Temp store for leftspeed - ie after some other speed action......the old motor speed can be restored
int storerightspeed;                                                     // Temp store forrightspeed - ie after some other speed action......the old motor speed can be restored
int colourbrightness=2;                                                  // reduces the intensity of RGB signal ie 0=full power 5=fullpower/5

int boredom_patience=30;                                                 // the higher this value the more patience he has  ie 
int boredom_counter=0;                                                   // If he does the same thing more than the boredom_patience amount then make a random direction
int new_objectsize=0;                                                    // used for boredom counter
int old_objectsize=0;                                                    // used for boredom counter

//============================================================ Initialization =======================================================
void setup()
{
  Serial.begin(57600);
    
  attachInterrupt(Lencoderinterrupt,LeftEncoderInterrupt,CHANGE);        // interrupt to count encoder pulses from left    motor
  attachInterrupt(Rencoderinterrupt,RightEncoderInterrupt,CHANGE);       // interrupt to count encoder pulses from right   motor
  attachInterrupt(Aencoderinterrupt,ArmEncoderInterrupt,CHANGE);         // interrupt to count encoder pulses from arm     motor
  attachInterrupt(Gencoderinterrupt,GripEncoderInterrupt,CHANGE);        // interrupt to count encoder pulses from gripper motor
                                                                          
  pinMode(Lmotordirpin,OUTPUT);                                          // left    motor direction pin             low=reverse : high=forward
  pinMode(Rmotordirpin,OUTPUT);                                          // right   motor direction pin             low=reverse : high=forward
  pinMode(Amotordirpin,OUTPUT);                                          // arm     motor direction pin             low=lower   : high=raise
  pinMode(Gmotordirpin,OUTPUT);                                          // gripper motor direction pin             low=open    : high=close

  pinMode(RedLEDpin,OUTPUT);                                             // colour sensor red   LED pin             PWM used for calibration
  pinMode(GreenLEDpin,OUTPUT);                                           // colour sensor green LED pin             PWM used for calibration
  pinMode(BlueLEDpin,OUTPUT);                                            // colour sensor blue  LED pin             PWM used for calibration

  pinMode(FrontIRledspin,OUTPUT);                                        // front four object sensor LEDs pin       low=off     : high=on
  pinMode(LeftsideIRledpin,OUTPUT);                                      // left  side object sensor LED  pin       low=off     : high=on
  pinMode(RightsideIRledpin,OUTPUT);                                     // right side object sensor LED  pin       low=off     : high=on
  pinMode(LeftrearIRledpin,OUTPUT);                                      // left  rear object sensor LED  pin       low=off     : high=on
  pinMode(RightrearIRledpin,OUTPUT);                                     // right rear object sensor LED  pin       low=off     : high=on

  pinMode(Linefollowledpin,OUTPUT);                                      // front four line   sensor LEDs pin       low=off     : high=on

  pinMode(Speakerpin,OUTPUT);                                            // speaker pin                             audio output 
  
  digitalWrite(Amotorlimpin,HIGH);                                       // enable pull up resistor 
  digitalWrite(Gmotorlimpin,HIGH);                                       // enable pull up resistor
  
    
  //---------------------------------------------------- play tune on powerup / reset -----------------------------------------------
  // NOTE: the "tone" function disables some PWM outputs and prevents colour recognition from working :(
/*
  int melody[] = {NOTE_G3,NOTE_F3,NOTE_G3,NOTE_B3,NOTE_A3,0,NOTE_B3,NOTE_C4};
  int noteDurations[] = {4,8,8,4,4,4,4,4};
  for (byte Note = 0; Note < 8; Note++)                                  // Play eight notes
  {
    int noteDuration = 1000/noteDurations[Note];
    tone(Speakerpin,melody[Note],noteDuration);
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
  }
  TCCR2B = (1 << CS22);                                                  // set timer2 prescale factor to 64
  TCCR2A = ( 1 << WGM20) ;                                               // configure timer2 for phase correct pwm (8-Bit)
  TIMSK2 = 0;                                                            // disable all timer2 interrupts
  
  boredom_counter= boredom_patience;                                     // he is very patient to start with
*/
  //------------------------------------------------- set gripper and arm to home position ------------------------------------------
  ResetGripper();                                                        // Reset Gripper with open pincers
  ArmDown();                                                             // Lower Arm to lowest position ie to limit switch
  ArmUp();                                                               // lift them back up into the air
  oldbatteryvoltage=1200;                                                // nonsense value 
  sampletime=millis();                                                   // reset sample time to current time
} 


//=============================================================== Main Loop =========================================================
void loop()
{
  delay(5000);  
  ArmDown();                                                             // Lower Arm to lowest position ie to limit switch
  delay(5000);     
  ArmUp();                                             
  // lift them back up into the air

  /*  
  if (millis()-time>199)                                                 // Check if 200mS has elapsed
  {
    time=millis();
    lightchase=lightchase+1-4*(lightchase>3);                            // counts from 1-4 repeatedly to chase LEDs
  }
  if (millis()-sampletime>1000)                                          // Check if 1 seconds have elapsed
  {
    averagevoltage+=analogRead(BatteryVoltpin)*15/10;                    // average 20 samples of battery voltage
    voltindex++;
    if (voltindex>19)                                                       
    {
      voltindex=0;
      averagevoltage/=20;
      // robot goes into power saving mode when battery is flat or being recharged
      // press restart after charging battery
      if ((averagevoltage-oldbatteryvoltage)>batteryjump || averagevoltage<batteryflat) batterymode=1;  
      Serial.print("Average battery voltage: ");
      Serial.print(averagevoltage);
      Serial.print("  --  battery mode:");
      Serial.println(batterymode);
      oldbatteryvoltage=averagevoltage;
      batteryvoltage=averagevoltage;
      averagevoltage=0;
      sampletime=millis();
    }
  }
  //batteryvoltage=analogRead(BatteryVoltpin)*15/10;
  
  if (batterymode==1) // powersaving mode
  {
    // turn off motors
    gripspeed=0;
    armspeed=0;
    leftspeed=0;
    rightspeed=0;
    MotorUpdate();
    // turn off object detection LEDs
    digitalWrite(LeftsideIRledpin,LOW);
    digitalWrite(RightsideIRledpin,LOW);
    digitalWrite(LeftrearIRledpin,LOW);
    digitalWrite(RightrearIRledpin,LOW);
    // turn off 4 front IR LEDs
    digitalWrite(FrontIRledspin,LOW);                                      
    return;
  }
  
  CollisionAvoidance();     // check the 4 Side IRs to see if there is an obstruction to side or back
  FrontSensors();        // check the 4 Front IRs to see if there is object or obstruction in front                                          
  ObjectDetectAction();  // from frontsensor scan make the appropriate action
  
  if (gripencodervalue>8)                                                // gripper has closed, object has been dropped
  {
    Serial.println("DROPPED OBJECT!!!!");                                // reset object related variables
    chosencolour=0;
    objectattempt=0;
    ResetGripper();                                                      // reset the arm
    ArmUp();
  }
  
  */
}






//--------------------------------------- Front IR sensors --------------------------------------------
void FrontSensors()
{
  digitalWrite(FrontIRledspin,HIGH);                                     // turn on 4 front IR LEDs
  delayMicroseconds (IRdelay);                                           // required for accurate reading
  frontfarleftvalue=analogRead(Frontfarleftsenpin);                      // read total IR for front far    left  IR sensor
  frontmidleftvalue=analogRead(Frontmidleftsenpin);                      // read total IR for front middle left  IR sensor
  frontmidrightvalue=analogRead(Frontmidrightsenpin);                    // read total IR for front middle right IR sensor
  frontfarrightvalue=analogRead(Frontfarrightsenpin);                    // read total IR for front far    right IR sensor
  
  digitalWrite(FrontIRledspin,LOW);                                      // turn off 4 front IR LEDs
  delayMicroseconds (IRdelay);                                           // required for accurate reading
  frontfarleftvalue-=analogRead(Frontfarleftsenpin);                     // read total IR for front far    left  IR sensor
  frontmidleftvalue-=analogRead(Frontmidleftsenpin);                     // read total IR for front middle left  IR sensor
  frontmidrightvalue-=analogRead(Frontmidrightsenpin);                   // read total IR for front middle right IR sensor
  frontfarrightvalue-=analogRead(Frontfarrightsenpin);                   // read total IR for front far    right IR sensor
  
  frontaverage=(frontfarleftvalue+frontmidleftvalue+frontmidrightvalue+frontfarrightvalue)/4;      // average of 4 front IRs inputs
  /*
  Serial.print("Far left:");
  Serial.print(frontfarleftvalue);
  Serial.print("   Mid left:");
  Serial.print(frontmidleftvalue);
  Serial.print("   Mid right:");
  Serial.print(frontmidrightvalue);
  Serial.print("   Far right:");
  Serial.print(frontfarrightvalue);
  */
  //------------------------------------------- Determine size and position of objects ----------------------------------------------
    // NOTE: This part compares individual sensor readings with the average of all readings. Readings significantly higher than average
  // are assumed to be closer and given a binary value acording to the sensor. The end result is a 4 bit number from 0-15.
  
  // Examples: 
  // --0011-- would be object detected on middle right and far right sensors. 
  // --0110-- now the object is being detected by the middle left and middle right sensors only. This is an ideal candidate to be picked up.
  // --0100-- This would indicate an object being detected by the middle left sensor only - this might be a table or chair leg if at close range.
  // --1110-- This is a big object to the left - too big to pick up, might be a wall.
  
  // normally to calculate percentage you might use sensor reading/average*100 but to keep the values within integer range (-32768 to 32767)
  // we use sensor reading*10/average*10. The result is the same but the values don't overflow. Alternatively use long variables for greater precision
  
  objectsize=0;                                                                  // start with no objects
  if ((frontfarleftvalue*10/frontaverage*10)>objectsensitivity)  objectsize+=8;  // object detected by far left sensor - weighted so far left/right is less sensitive
  if ((frontmidleftvalue*10/frontaverage*10)>objectsensitivity)  objectsize+=4;  // object detected by mid left sensor -weighted so mid left/right is more sensitive
  if ((frontmidrightvalue*10/frontaverage*10)>objectsensitivity) objectsize+=2;  // object detected by mid right sensor - weighted so mid left/right is more sensitive
  if ((frontfarrightvalue*10/frontaverage*10)>objectsensitivity) objectsize+=1;  // object detected by far right sensor - weighted so far left/right is less sensitive
  if (objectsize==0 && frontaverage>maxdistance) objectsize=15;                  // path is blocked 
  //Serial.print("  Object size front sensors: ");Serial.println(objectsize);
  
}

//=================================Read Mid Right/Left IR Sensors ie Fine tune Homein==================================================
//                               NOTE: Readings should be reasonably consistant with changes in ambient IR
void FrontMidSensors()
{
  digitalWrite(FrontIRledspin,HIGH);                                     // turn on 4 front IR LEDs
  delayMicroseconds (IRdelay);                                           // required for accurate reading

  frontmidleftvalue=analogRead(Frontmidleftsenpin);                      // read total IR for front middle left  IR sensor
  frontmidrightvalue=analogRead(Frontmidrightsenpin);                    // read total IR for front middle right IR sensor
 
  digitalWrite(FrontIRledspin,LOW);                                      // turn off 4 front IR LEDs
  delayMicroseconds (IRdelay);                                           // required for accurate reading

  frontmidleftvalue-=analogRead(Frontmidleftsenpin);                     // Relected IR = Total IR -Ambient IR
  frontmidrightvalue-=analogRead(Frontmidrightsenpin);                   // Relected IR = Total IR -Ambient IR
  frontmidaverage=(frontmidleftvalue+frontmidrightvalue)/2;              // average of middle 2 IR inputs
                                                                         // objectsize=0; 
}
 
//=========================================================== Avoid hitting objects =================================================
void CollisionAvoidance()
{
  //Serial.println("Object Detect");
  // turn on object detection IR LEDs
  digitalWrite(LeftsideIRledpin,HIGH);
  digitalWrite(RightsideIRledpin,HIGH);
  digitalWrite(LeftrearIRledpin,HIGH);
  digitalWrite(RightrearIRledpin,HIGH);
  delayMicroseconds(IRdelay);

  // read sensors
  frontleftside=digitalRead(Leftsidesenpin);
  frontrightside=digitalRead(Rightsidesenpin);
  rearleft=digitalRead(Leftrearsenpin);
  rearright=digitalRead(Rightrearsenpin);

  // turn off object detection LEDs
  digitalWrite(LeftsideIRledpin,LOW);
  digitalWrite(RightsideIRledpin,LOW);
  digitalWrite(LeftrearIRledpin,LOW);
  digitalWrite(RightrearIRledpin,LOW);
  delayMicroseconds(IRdelay);

  // turn on indicator LEDs if an object is in range and chase LEDs
  digitalWrite(LeftsideIRledpin,(lightchase==1 || frontleftside==1));
  digitalWrite(RightsideIRledpin,(lightchase==2 || frontrightside==1));
  digitalWrite(LeftrearIRledpin,(lightchase==4 || rearleft==1));
  digitalWrite(RightrearIRledpin,(lightchase==3 || rearright==1));
  
  //if(batterymode==1 && batteryvoltage>batteryfull) return;
  
  // Adjust motor speeds to avoid collision
  if (frontleftside==HIGH )
  { 
    storeleftspeed=leftspeed;
    storerightspeed=rightspeed;    // store values are to restore the original motor speed ie to carry on where it left off before the obstruction hit
    leftspeed=speedcontrol*1.5; 
    rightspeed=-speedcontrol*1.6; 
    MotorUpdate();delay(200);
    leftspeed=storeleftspeed; 
    rightspeed=storerightspeed; 
    MotorUpdate(); //Serial.print("left high");
  }
  if (frontrightside==HIGH)
  { 
    storeleftspeed=leftspeed;
    storerightspeed=rightspeed;
    leftspeed=-speedcontrol*1.6; 
    rightspeed=speedcontrol*1.5; 
    MotorUpdate();
    delay(200);
    leftspeed=storeleftspeed;
    rightspeed=storerightspeed; //Serial.print("right high");
  }
  if (rearleft==HIGH )
  { 
    storeleftspeed=leftspeed;
    storerightspeed=rightspeed;
    leftspeed=speedcontrol*1.6;
    rightspeed=-speedcontrol*1.6; 
    MotorUpdate();
    delay(200);
    leftspeed=storeleftspeed; 
    rightspeed=storerightspeed; 
    MotorUpdate(); //Serial.print("left high");
  }
  if (rearright==HIGH)
  { 
    storeleftspeed=leftspeed;storerightspeed=rightspeed;
    leftspeed=-speedcontrol*1.6; rightspeed=speedcontrol*1.6; MotorUpdate();delay(200);leftspeed=storeleftspeed; rightspeed=storerightspeed; //Serial.print("right high");
  }
}

//======================================= Navigate and Home in on Object =================================================
void ObjectDetectAction()
{
  //Serial.print("Object Size:"); Serial.println(objectsize);
  switch (objectsize) // choose action based on binary representation of front sensor inputs
  {
    case 1:   // turn right  fast  0001
      //storeleftspeed=leftspeed;storerightspeed=rightspeed;
      leftspeed=speedcontrol*1.0; rightspeed=-speedcontrol*1.4; MotorUpdate();delay(90);leftspeed=0; rightspeed=0; MotorUpdate();
      //Serial.println("case1 0001 -  turn right fast ");
      break;
    
    case 3:   // turn right medium   0011
      leftspeed=speedcontrol*1.0; rightspeed=-speedcontrol*1.2; MotorUpdate();delay(90);leftspeed=00; rightspeed=00; MotorUpdate();
      //Serial.println("case2 0011 - turn right slow ");
      break;
    
     case 2:  // turn right Slow 0010
       leftspeed=speedcontrol*1.3; rightspeed=-speedcontrol*0.9; MotorUpdate();delay(70);leftspeed=00; rightspeed=00; MotorUpdate();
       //Serial.println("case2 0010 -turn right slow ");
       break;
     
     case 6:  // object like cup detected, so creep forward a bit and nudge it
       Serial.println("Object Located");
       FrontMidSensors();                                                   // read front mid sensors to judge object distance
       int beforemidaverage;
       int alignment;
       beforemidaverage=frontmidaverage;
       Serial.print("Before Distance:"); Serial.println(frontmidaverage);
       for (int n=0;n<4;n++)                                                // pulse motors 4 times to gently nudge towards the object
       {
         FrontMidSensors();                                                 // read front mid sensors to judge alignment
         alignment=(frontmidleftvalue*25/frontmidaverage*4)-(frontmidrightvalue*25/frontmidaverage*4); //left percent of average - right percent of average
         leftspeed=speedcontrol-alignment;                                  // adjust left motor speed
         rightspeed=speedcontrol+alignment;                                 // adjust right motor speed
         MotorUpdate();delay(creeppulse);                                   // pulse motors to prevent stalling at low speeds
         leftspeed=0;                                          
         rightspeed=0; 
         MotorUpdate();delay(creeppulse);                                   // turn off motors  
       }
       FrontMidSensors();                                                   // re-check object distance  
       Serial.print("After Distance:"); Serial.println(frontmidaverage);
       if(abs(frontmidaverage-beforemidaverage)<frontmidaverage*1/100)     // distance has not changed significantly (<5%) - in range of gripper
       {
         int averagecolour=0;
         for (int a=0;a<3;a++)                                              // take 3 colour readings and average them to get a solid reading
         {
           ObjectColour();                                                  // check object colour
           averagecolour+=objectcolour;                                     // add the results together
         }
         averagecolour/=3;                                                  // divide by three to get the average
         objectcolour=averagecolour;
         Serial.print("average colour:");
         Serial.println(objectcolour);
         objectattempt=0;
         ColourAction();                                                    // perform action based on average object colour
       }
       objectattempt++;
       if (objectattempt<6) break;                                          // make 5 attempts to get object
       objectattempt=0;                                                     // give up
       RandomDirection;                                                     // Go somewhere else
       break;
             
     case 4:  // turn left slow  0100
       leftspeed=-speedcontrol*0.9; rightspeed=speedcontrol*1.3; MotorUpdate();delay(70);leftspeed=00; rightspeed=00; MotorUpdate();
       //Serial.println("case4 0100 - turn left slow ");
       break;
      
     case 12: // turn left medium  1100
       leftspeed=-speedcontrol*1.2; rightspeed=speedcontrol*1.0; MotorUpdate();delay(90);leftspeed=00; rightspeed=00; MotorUpdate();
       //Serial.println("case4 1100 - turn left slow ");
       break;
    
     case 8:  // turn left fast    1000
       // storeleftspeed=leftspeed;storerightspeed=rightspeed;
       leftspeed=-speedcontrol*1.4; rightspeed=speedcontrol*1.0;MotorUpdate();delay(90); leftspeed=0; rightspeed=0;MotorUpdate();
       //Serial.println("case8 1000 - turn left fast");
       break;
//-------------------------------------------------- Special cases  ie obstacle avoidence 
    case 15:  // looks like Brickwall - turn say 90°  1111
       RandomDirection();
       //Serial.println("case15 1111 - brickwall ");
       break;
    case 7:  // looks like Brickwall to the right - turn say 20° away 0111
       RandomDirection();
       //Serial.println("case7 0111 - brickwall right ");
       break;
    case 14: // looks like Brickwall to the left - turn say 20° away  1110
       RandomDirection();
       //Serial.println("case14 1110 - brickwall left ");
       break;
//---------------------------------------   Small object detected by single ODD/EVEN sensor pairs   
    case 5: // thin object far left thin object mid left 0101
       RandomDirection();
       //Serial.println("case5 0101 - thin object far left thin object mid left  ");
       break;  
       
    case 10: // thin object far right thin object mid right 1010
       RandomDirection();
       //Serial.println("case10 1010 - thin object far right thin object mid right  ");
       break;
       
    case 9: // something small left and small right ---- gap in the middle 1001
       rand_number = random(-1, 2);
       if (rand_number==1) { leftspeed=speedcontrol*1.3; rightspeed=-speedcontrol*1.3; MotorUpdate();delay(350);leftspeed=00; rightspeed=00; MotorUpdate();}
       if (rand_number==-1) { leftspeed=-speedcontrol*1.3; rightspeed=+speedcontrol*1.3; MotorUpdate();delay(350);leftspeed=00; rightspeed=00; MotorUpdate();}
       //Serial.println("case9 1001 - looks like a window ");
       break;
 
//---------------------------------------- small and large objects detected        
    case 11: // something big right and small left 1011
       //leftspeed=speedcontrol*1.4; rightspeed=-speedcontrol*1.2; MotorUpdate();delay(150);leftspeed=00; rightspeed=00; MotorUpdate();
       //Serial.println("case11 1011 - brickwall right - open space - something left ");
       break;
       
    case 13: // something big left and small right  1101
       //leftspeed=-speedcontrol*1.2; rightspeed=speedcontrol*1.4; MotorUpdate();delay(150);leftspeed=00; rightspeed=00; MotorUpdate();
       //Serial.println("case13 1101 - brickwall left - open space - something right ");
       break;
       
 //-----------------------------------------       
    case 0:  // Open Road Cruise forwards
      //Serial.println("case0 0000 - all ok  ");
      leftspeed=speedcontrol; rightspeed=speedcontrol; MotorUpdate();delay(50);leftspeed=00; rightspeed=00; MotorUpdate();
      break;
  }
}
  
//===================================================== Determines the colour of an object ==========================================
//                    NOTE: Due to the time this takes both robot and object need to be stationary for acurate readings.
//                                  Readings should be reasonably consistant regardless of ambient light.
void ObjectColour()
{
  analogWrite(RedLEDpin,pwmred);                          // turn on red LED to calibrated value and reduce the intensity
  delay(ldrdelay);                                        // allow time for LDR to respond
  redvalue=analogRead(RGBLDRpin);                         // read LDR with red LED on            (total light = ambient + reflected red light)
  analogWrite(RedLEDpin,0);                               // turn off red LED
  
  analogWrite(GreenLEDpin,pwmgreen);                      // turn on green LED to calibrated value
  delay(ldrdelay);                                        // allow time for LDR to respond
  greenvalue=analogRead(RGBLDRpin);                       // read LDR with green LED on          (total light = ambient + reflected green light)
  analogWrite(GreenLEDpin,0);                             // turn off green LED
  
  analogWrite(BlueLEDpin,pwmblue);                        // turn on blue LED to calibrated value
  delay(ldrdelay);                                        // allow time for LDR to respond
  bluevalue=analogRead(RGBLDRpin);                        // read LDR with blue LED on           (total light = ambient + reflected blue light)
  analogWrite(BlueLEDpin,0);                              // turn off blue LED
  delay(ldrdelay);                                        // allow time for LDR to respond
  
  ambientvalue=analogRead(RGBLDRpin);                     // read ambient light 
  redvalue=redvalue-ambientvalue;                         // calculate reflected red light       (reflected red light = total red light - ambient light)
  greenvalue=greenvalue-ambientvalue;                     // calculate reflected green light     (reflected green light = total green light - ambient light)
  bluevalue=bluevalue-ambientvalue;                       // calculate reflected blue light      (reflected blue light = total blue light - ambient light)  
  lightvalue=(redvalue+greenvalue+bluevalue)/3;           // average of all colour readings
  
  //Serial.println(lightvalue);
  //--------------------------------------------------------- Determine object colour------------------------------------------------
  //      Note: uses percentage of average value so that distance / brightness of the object does not affect result greatly
  objectcolour=0;                                         // start with a value of 0 (nothing)
  if (lightvalue>20)
  {
    if ((redvalue*100/lightvalue)>coloursensitivity) objectcolour+=4;  // if red   is at least 10% greater than average
    if ((greenvalue*100/lightvalue)>coloursensitivity) objectcolour+=2;// if green is at least 10% greater than average
    if ((bluevalue*100/lightvalue)>coloursensitivity) objectcolour+=1; // if blue  is at least 10% greater than average
    if (objectcolour==0) objectcolour=7;                               // white or transparent object
  }
}

//========================================== Action to take based on object colour =================================================
void ColourAction()
{
  Serial.print("Object colour=");Serial.println(objectcolour);
  Serial.print("Chosen colour=");Serial.println(chosencolour);
  
  if (chosencolour==objectcolour)                    // found a colour same as the object in the gripper
  {
    Serial.println("Found another object of the same colour!");
    int oldencodervalue=leftencodervalue;            // record left encoder value
    while (abs(leftencodervalue-oldencodervalue)<16) // use left encoder to measure reverse distance for 16 encoder pulses
    {
      leftspeed=-speedcontrol;      // reverse away from new object slowly
      rightspeed=-speedcontrol;
      MotorUpdate();
      delay(creeppulse);            // short ON time to pulse motors
      leftspeed=0;                  // turn off motors
      rightspeed=0;
      MotorUpdate();
      delay(creeppulse);            // short off time to pulse motors
    }
    ArmDown();                      // lower object
    ResetGripper();                 // open gripper
    ArmUp();                        // raise gripper
    chosencolour=0;
  }
  else // gripper does not contain object or colour is different 
  {
    Serial.print("Gripper Encoder Value:"); Serial.println(gripencodervalue);
    if (gripencodervalue==0)        // gripper does not contain object
    {
      ArmDown();
      GripObject();
      ArmUp();
      if (gripencodervalue>0)
      {
        chosencolour=objectcolour;
        Serial.print("Gripper has an object! Size:");
        Serial.println(gripencodervalue);
        Serial.print("  COLOUR: ");   
        switch (objectcolour)
        {
          case 1:
          Serial.println("Blue"); 
          break;

          case 2: 
          Serial.println("Green"); 
          break;

          case 3: 
          Serial.println("Aqua"); 
          break;

          case 4: 
          Serial.println("Red"); 
          break;

          case 5: 
          Serial.println("Pink"); 
          break;

          case 6: 
          Serial.println("Yellow"); 
          break;

          case 7: 
          Serial.println("White"); 
          break;

          default:
          Serial.println("None"); 
          break;
        }
      }
      else  // Gripper contains an object but the colour doesn't match.
      {
        Serial.println("Object colour does not match!");
      }
    }
  }
  RandomDirection();
}
    
//=========================================================== Make gripper Grip something =================================================
void GripObject() 
{
  Serial.println("Grab Object"); 
  gcount=0;
  long gtime=millis();
  gripspeed=120;                                                        // set gripper motor speed 
  MotorUpdate();                                                        // close gripper                                     
  delay(400);                                                           // allow time to close

   while ((gripencodervalue <9) || (analogRead(Gmotorcurpin)<goodgrip)) // squeeze object until good grip is acheived
   {
     if ((millis()-gtime)>50)
     {
       gripspeed+=20;
       gcount++;
       MotorUpdate();
       gtime=millis();
     } 
     if (gcount>5) break; 
     Serial.print(gripspeed);
     Serial.print("  current:");
     Serial.print(analogRead(Gmotorcurpin));
     Serial.print("  clicks:");
     Serial.println(gripencodervalue);
   }
   if (gripencodervalue<9)
   {
     Serial.println("Have object!");
     gripspeed=keepgrip;                                                        // maintain grip
     MotorUpdate(); 
   }     
   else                                                                         // emptyspace
   {
     Serial.println("Nothing in gripper!");
     Serial.print("Grip Encoder:");Serial.println(gripencodervalue);
     ResetGripper();
   }
}
      
//=========================================================== Reset Gripper to open position  ==========================
void ResetGripper()                                        
{
  Serial.println("Reset Gripper");
  gcount=0;                                                  // used to count attempts to open gripper if the gripper is jammed
  long gtime=millis();                                       // used to time each attempt to open gripper
  int glimit=digitalRead(Gmotorlimpin);                      // used to check the status of the gripper limit switch
  if (glimit==0) return;
  gripspeed=-80;                                             // initial speed/direction of gripper travel
  while (glimit==HIGH)                                       // open gripper until it reaches the limit switch
  {
    MotorUpdate(); 
    if ((millis()-gtime)>2000)                               // gives gripper 2 seconds to open before the attempt is considered a failure
    {
      gripspeed*=-1.2;                                       // reverse direction and increase strength by 20% 
      gcount++;                                              // counts failed attempts
      gtime=millis();                                        // reset timer for next attempt
    }
    if (gcount>6) break;                                     // gives up after 7 attempts  
    glimit=digitalRead(Gmotorlimpin);                        // re-checks status of limit switch
  }
  int openextra=gripencodervalue-2;
  while (gripencodervalue>openextra)
  {
  }
  
  gripspeed=0;   
  MotorUpdate();                                             // stop gripper motor                                      
  gripencodervalue=0;                                        // reset the grip encoder to zero to stop accumulated errors
} 
 
//================================================= Lift up arm with cup =================================================
void ArmUp()
{
  Serial.println("Raise arm");
  acount=0;
  long atime=millis();
  int alimit=digitalRead(Amotorlimpin);                      // used to check the status of the gripper limit switch
  armspeed=100;                                               // set arm motor speed
  while (armencodervalue<15)
  {
    MotorUpdate();
    if ((millis()-atime)>5000)                                // give arm 5 seconds to raise
    {
      armspeed*=1.2;                                          // increase power by 20%
      acount++;                                               // count failed attempt
      atime=millis();                                         // reset timer
    }
    if (acount>3) break;                                      // give up after 4 attempts    
  }
  armspeed=0;
  MotorUpdate();                                              // Stop the arm 
}


//===================================================== Reset Arm to base position ie fully dowm   =================================================
   
void ArmDown()
{
  Serial.println("lower arm");
  acount=0;                                                  // used to count attempts to lower the arm if the arm is jammed
  long atime=millis();                                       // used to time each attempt to lower the arm
  armspeed=-80;                                              // initial speed/direction of arm travel
  MotorUpdate();                                             // start lowering arm
  delay(500);                                                // wait 500mS to clear upper limit switch
  int alimit=digitalRead(Amotorlimpin);                      // used to check the status of the arm limit switch
  while (alimit==HIGH)                                       // lower arm until it reaches the lower limit switch
  {
    MotorUpdate(); 
    if ((millis()-atime)>5000)                               // gives arm 5 seconds to hit limit before the attempt is considered a failure
    {
      armspeed*=-1.2;                                        // reverse direction and increase strength by 20% 
      acount++;                                              // counts failed attempts
      atime=millis();                                        // reset timer for next attempt
    }
    if (acount>5) break;                                     // gives up after 6 attempts  
    alimit=digitalRead(Amotorlimpin);                        // re-checks status of limit switch
  }
  armspeed=0;   
  MotorUpdate();                                             // stop arm motor
  armencodervalue=0;                                         // reset the arm encoder to zero to stop accumulated errors
} 
  
//---------------------------------------------- Choose a Random direction
void  RandomDirection()
{
  rand_number = random(-1, 2);  Serial.print("Random Direction: ");
  leftspeed=-speedcontrol*1.3; rightspeed=-speedcontrol*1.3; MotorUpdate();delay(250);leftspeed=00; rightspeed=00; MotorUpdate(); // reverse a little not to bash cups during tight turn away
       
  if (rand_number==1) {leftspeed=speedcontrol*1.3; rightspeed=-speedcontrol*1.3; MotorUpdate();delay(450);leftspeed=00; rightspeed=00; MotorUpdate();Serial.println("clockwise");}
  else { leftspeed=-speedcontrol*1.3; rightspeed=+speedcontrol*1.3; MotorUpdate();delay(450);leftspeed=00; rightspeed=00; MotorUpdate();Serial.println("anti-clockwise");}
}
//========================================================= Motor speed direction management and update =================================================

void MotorUpdate()
{
  digitalWrite(Lmotordirpin,(leftspeed>0));                              // set Left Motor Direction to forward if speed>0
  analogWrite(Lmotorpwmpin,abs(leftspeed));                              // set Left Motor Speed

  digitalWrite(Rmotordirpin,(rightspeed>0));                             // set Right Motor Direction to forward if speed>0
  analogWrite(Rmotorpwmpin,abs(rightspeed));                             // set Right Motor Speed

  digitalWrite(Amotordirpin,(armspeed>0));                               // set Arm Motor Direction to forward if speed>0
  analogWrite(Amotorpwmpin,abs(armspeed));                               // set Arm Motor Speed

  digitalWrite(Gmotordirpin,(gripspeed>0));                              // set Gripper Motor Direction to forward if speed>0
  analogWrite(Gmotorpwmpin,abs(gripspeed));                              // set Gripper Motor Speed

}



void LeftEncoderInterrupt()
{
  leftencodervalue=leftencodervalue+(leftspeed/abs(leftspeed));
}

void RightEncoderInterrupt()
{
  rightencodervalue=rightencodervalue+(rightspeed/abs(rightspeed));
}

void ArmEncoderInterrupt()
{
  armencodervalue=armencodervalue+(armspeed/abs(armspeed));
}

void GripEncoderInterrupt()
{
  gripencodervalue=gripencodervalue+(gripspeed/abs(gripspeed));
}


