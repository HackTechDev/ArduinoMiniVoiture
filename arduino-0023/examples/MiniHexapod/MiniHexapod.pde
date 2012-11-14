#include <Servo.h>

// define IO pins

// ===== SERVO PINS =====
#define llegpin         6  // digital pin  6 - Left  hip   servo
#define neckpin         5  // digital pin  5 - Right hip   servo
#define mlegpin         8  // digital pin  8 - Left  knee  servo
#define rlegpin         7  // digital pin  7 - Right knee  servo


// ==== IR EYE PINS =====
#define IRpin          13  // digital pin 13 - IR    Eye   LEDs
#define Uppin           3  // analog  pin  3 - upper eye   sensor
#define Downpin         1  // analog  pin  1 - lower eye   sensor
#define Leftpin         2  // analog  pin  2 - left  eye   sensor
#define Rightpin        0  // analog  pin  0 - right eye   sensor

// ==== IR FEET PINS ====
#define LeftIRpin      10  // digital pin 10 - left  foot  IR LED
#define RightIRpin      9  // digital pin  9 - right foot  IR LED
#define Leftsensorpin   5  // analog  pin  5 - left  foot  IR sensor
#define Rightsensorpin  4  // analog  pin  4 - right foot  IR sensor

// ==== IR COMS PINS ====
#define IRIpin          3  // digital pin  3 - IR Interrupt
#define IRXpin          0  // digital pin  0 - IR RX
#define ITXpin          1  // digital pin  1 - IR TX
#define ITMpin          4  // digital pin  4 - IR TX modulate (38KHz)

// == LED/SPEAKER PINS ==
#define LEDpin          2  // digital pin  2 - General purpose LED
#define Speakerpin      4  // digital pin  4 - Speaker output


// define constants
#define llegc        1500
#define rlegc        1500
#define mlegc        1400

#define LRmax        2100
#define LRmin         900


#define stride        200
#define twist         180

#define distancemax   120
#define bestdistance  600

#define neckLRcenter 1350
#define neckUDcenter 1500

// define global variables

int count;
volatile int flag;

byte LRscalefactor=20;
byte UDscalefactor=20;

int pan=neckLRcenter;
int tilt=neckUDcenter;
int panscale;

int Direction=0;
int Steer=0;
int Mode=0;                                                     // Mode 0 = Autonomous  --  Mode 1 = Remote control 

int leftposition=llegc;                                         // set left legs servo to center position to 1500uS
int rightposition=rlegc;                                        // set right legs servo to center position to 1500uS
int middleposition=mlegc;                                       // set middle legs servo to center position to 1500uS

int IRC;                                                        // Infra Red Command from remote control
int pulse;                                                      // used to measure the pulse width of IR signals
int i;
int temp;
unsigned long Speed=120000;
int leftright;
int leftIRvalue;                                                // Eye left  sensors
int rightIRvalue;                                               // Eye right sensors
int upIRvalue;                                                  // Eye up    sensors
int downIRvalue;                                                // Eye down  sensors
int distance;                                                   // average reading of all Eye sensors
int lookUD;                                                     // Up - Down    evaluation
int lookLR;                                                     // Left - Right evaluation


// define servos
Servo Lleg;
Servo Rleg;
Servo Mleg;
Servo Neck;

void setup()
{
  Lleg.attach(llegpin);                                         // assign processor pin to Lleg servo
  Rleg.attach(rlegpin);                                         // assign processor pin to Rleg servo
  Mleg.attach(mlegpin);                                         // assign processor pin to Mleg servo
  Neck.attach(neckpin);                                         // assign processor pin to Neck servo



  pinMode(IRpin,OUTPUT);                                        // White LED
  pinMode(LEDpin,OUTPUT);                                       // Red LED
  pinMode(Speakerpin,OUTPUT);                                   // Speaker
  digitalWrite(IRIpin,1);                                       // turn on D3 pullup resistor for IR receiver interrupt pin

  //----------------------------- play tune on powerup / reset -----------------------------------------
  //                        tone command is not used to save memory

  int melody[] = {
    262,196,196,220,196,1,247,262    };
  int noteDurations[] = {
    4,8,8,4,4,4,4,4    };
  for (byte Note = 0; Note < 8; Note++)                         // Play eight notes
  {
    long pulselength = 1000000/melody[Note];                    
    long noteDuration = 1000/noteDurations[Note];
    long pulses=noteDuration*1000/pulselength;
    if (pulselength>100000)                                     // Play pause
    {
      delay(noteDuration);
    }
    else
    {
      for(int p=0;p<pulses;p++)                                 // tone command not used to save memory
      {
        digitalWrite(Speakerpin,HIGH);
        delayMicroseconds(pulselength/2);
        digitalWrite(Speakerpin,LOW);
        delayMicroseconds(pulselength/2);
      }
      int pauseBetweenNotes = noteDuration * 0.30;
      delay(pauseBetweenNotes);
    }
  } 
  //Serial.begin(57600);
  attachInterrupt(1,IRdetect,FALLING);
}

void loop()
{//------------------------------------------ Walking Routine -------------------------------------------
  
  if(flag==1)
  {
    flag=0;
    if(pulseIn(IRXpin, LOW,Speed) >1800) IRcommand();             // if start bit is greater than 1800uS then read remote control. Timeout value controls robot speed
  }
   
  Neck.writeMicroseconds(pan);
  
  middleposition=mlegc-twist*abs(Direction);                      // change position of middle leg. If direction=0 then leg moves to center position.
  Mleg.writeMicroseconds(middleposition);                         // update servo position
  if(Mode==0) 
  {
    IReye();
    IRfollow();
  }
  else
  {
    delay(30);
  }
  
  if(flag==1)
  {
    flag=0;
    if(pulseIn(IRXpin, LOW,Speed) >1800) IRcommand();             // if start bit is greater than 1900uS then read remote control. Timeout value controls robot speed
  }
  delay(90);
  leftposition=-stride*Direction;
  if (Steer==1) leftposition*=-1;
  rightposition=-stride*Direction;
  if (Steer==-1) rightposition*=-1;
  Lleg.writeMicroseconds(llegc+leftposition);
  Rleg.writeMicroseconds(rlegc+rightposition);
  if(Mode==0) 
  {
    IReye();
    IRfollow();
  }
  else
  {
    delay(30);
  }
  
  if(flag==1)
  {
    flag=0;
    if(pulseIn(IRXpin, LOW,Speed) >1800) IRcommand();             // if start bit is greater than 1900uS then read remote control. Timeout value controls robot speed
  }
  delay(90);

  middleposition=mlegc+twist*abs(Direction);
  Mleg.writeMicroseconds(middleposition);
  
  if(Mode==0) 
  {
    IReye();
    IRfollow();
  }
  else
  {
    delay(30);
  }
  
  if(flag==1)
  {
    flag=0;
    if(pulseIn(IRXpin, LOW,Speed) >1800) IRcommand();             // if start bit is greater than 1900uS then read remote control. Timeout value controls robot speed
  }
  delay(90);
  leftposition=stride*Direction;
  if (Steer==1) leftposition*=-1;
  rightposition=stride*Direction;
  if (Steer==-1) rightposition*=-1;
  Lleg.writeMicroseconds(llegc+leftposition);
  Rleg.writeMicroseconds(rlegc+rightposition);
  if(Mode==0) 
  {
    IReye();
    IRfollow();
  }
  else
  {
    delay(30);
  }
  
  if(flag==1)
  {
    flag=0;
    if(pulseIn(IRXpin, LOW,Speed) >1800) IRcommand();             // if start bit is greater than 1900uS then read remote control. Timeout value controls robot speed
  }
  delay(90);
}

void IRcommand() 
{//----------------------------------------- Receive IR commands from remote control ----------------------------------

  digitalWrite(LEDpin,HIGH);                                    // Turn on red indication LED to show signal received
  IRC=0;                                                        // reset Infra Red Command variable
  int j=1;                                                      // reset binary multiplier
  for(int k=0;k<7;k++)                                          // read 7 data bits (ignore 5 bit device ID)
  {		                        
    pulse = pulseIn(IRXpin, LOW,2500);                          // measure pulse from IR receiver
    if(pulse > 900)                                             // a pulse greater than 900uS is considered to be a 1
    {		                        
      IRC+=j;                                                   // if it is a 1 then add 2 to the power of i
    }  
    j*=2; 
  }
  delay(100);                                                   // Slow down responce to button press
  digitalWrite(LEDpin,LOW);                                     // Turn off red indication LED

  if(IRC==20) Mode=!Mode;                                       // toggle mode when green button is pressed
  //Serial.println(IRC);

  if (Mode==1)                                                  // respond to IR commands in remote control mode
  {
    switch (IRC)                                                // respond to valid IR commands
    {
    case 16:                                                    // go forward
      Direction=1;
      Steer=0;
      break;

    case 17:                                                    // go backward
      Direction=-1;
      Steer=0;
      break;

    case 18:                                                    // turn right
      Direction=1;
      Steer=-1;
      break;

    case 19:                                                    // turn left
      Direction=1;
      Steer=1;
      break;

    case 37:                                                    // stop!
      Direction=0;
      Steer=0;
      break;
    } 
    pan=neckLRcenter-500*Steer;
  }
}

void IReye()//===============================================================Read IR compound eye================================================
{
  digitalWrite(IRpin,HIGH);                                     // turn on IR LEDs to read TOTAL IR LIGHT (ambient + reflected)
  delayMicroseconds(100);                                        // Allow time for phototransistors to respond. (may not be needed)
  upIRvalue=analogRead(Uppin);                                  // TOTAL IR = AMBIENT IR + LED IR REFLECTED FROM OBJECT
  downIRvalue=analogRead(Downpin);                              // TOTAL IR = AMBIENT IR + LED IR REFLECTED FROM OBJECT
  leftIRvalue=analogRead(Leftpin);                              // TOTAL IR = AMBIENT IR + LED IR REFLECTED FROM OBJECT
  rightIRvalue=analogRead(Rightpin);                            // TOTAL IR = AMBIENT IR + LED IR REFLECTED FROM OBJECT
  

  digitalWrite(IRpin,LOW);                                      // turn off IR LEDs to read AMBIENT IR LIGHT (IR from indoor lighting and sunlight)
  delayMicroseconds(100);                                        // Allow time for phototransistors to respond. (may not be needed)
  upIRvalue=upIRvalue-analogRead(Uppin);                        // REFLECTED IR = TOTAL IR - AMBIENT IR
  downIRvalue=downIRvalue-analogRead(Downpin);                  // REFLECTED IR = TOTAL IR - AMBIENT IR
  leftIRvalue=leftIRvalue-analogRead(Leftpin);                  // REFLECTED IR = TOTAL IR - AMBIENT IR
  rightIRvalue=rightIRvalue-analogRead(Rightpin);               // REFLECTED IR = TOTAL IR - AMBIENT IR
  

  distance=(leftIRvalue+rightIRvalue+upIRvalue+downIRvalue)/4;  // distance of object is average of reflected IR
  //Serial.println(distance);
  if (distance>distancemax)                                     // object in range
  {
    int sound=1024-distance;                                    // generate sound to indicate distance
    for(int p=0;p<10;p++)
    {
      digitalWrite(Speakerpin,HIGH);
      delayMicroseconds(sound);
      digitalWrite(Speakerpin,LOW);
      delayMicroseconds(sound);
    }
  }
  else
  {
    Steer=0;
    Direction=0;
  }
  /*
   Serial.print("Left:");
   Serial.print(leftIRvalue);
   Serial.print("  Right:");
   Serial.print(rightIRvalue);
   Serial.print("  Up:");
   Serial.print(upIRvalue);
   Serial.print("  Down:");
   Serial.print(downIRvalue);
   Serial.print("  Up/down:");
   Serial.print(lookUD);
   Serial.print("  Left/right:");
   Serial.println(lookLR);
  */
}
void IRfollow ()//==============================================Track object in range================================================================
{
  if (distance<distancemax)
  {
    if (pan>neckLRcenter)pan=pan-50;
    if (pan<neckLRcenter)pan=pan+50;
  }
  else
  {
    //-------------------------------------------------------------Track object with head------------------------------------------------
    panscale=(leftIRvalue+rightIRvalue)/LRscalefactor;
    if (leftIRvalue>rightIRvalue)
    {
      leftright=(leftIRvalue-rightIRvalue)*5/panscale;
      pan=pan-leftright;
    }
    if (leftIRvalue<rightIRvalue)
    {
      leftright=(rightIRvalue-leftIRvalue)*5/panscale;
      pan=pan+leftright;
    }
    
    //-------------------------------------------------------------Turn body to follow object--------------------------------------------
    if (Direction==0) Direction=1;
    Steer=0;
    temp=LRmax-pan;
    if (temp<500)
    {
      Steer=-1;
    }
    temp=pan-LRmin;
    if (temp<500)
    {
      Steer=1;
    }

    //------------------------------------------------------Move forward or backward to follow object------------------------------------
    
    temp=distance-bestdistance;
    temp=abs(temp);

    if (temp>10)
    {
      temp=temp-10;
      if (distance>bestdistance)
      {
        Direction=-1;
        Steer=0;
      }
      else
      {
        Direction=1;
      }
    }
    else
    {
      if(Steer==0) Direction=0;
    }
  }
}

void IRdetect()
{
  flag=1;
}


