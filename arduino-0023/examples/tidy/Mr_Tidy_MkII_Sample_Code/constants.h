// define constant values 

#define speedcontrol         70        // Motor speed - Global value for left/right motor
#define goodgrip            500        // current draw required by gripper motor for good grip - maximum current @ 100% dutycycle aproximately 600
#define keepgrip             80        // gripspeed value (0-255) required to keep a good grip on object
#define creeppulse           10        // number of mS to pulse the motors for to creep forward

#define batteryflat         660        // Battery reading when flat
#define batteryfull         820        // Battery reading when fully charged
#define batteryjump          16        // Sudden change in battery voltage caused by charger connect / disconnect

#define gripstallcurrent    200        // Gripper stall current
#define armstallcurrent     200        // Arm stall current
#define motorstallcurrent   400        // Stall current for left and right motors

#define pwmred              255        // Red   LED PWM value used to calibrate colour sensor
#define pwmgreen            180        // Green LED PWM value used to calibrate colour sensor
#define pwmblue             120        // Blue  LED PWM value used to calibrate colour sensor
#define coloursensitivity   110        // Colour sensitivity as a percentage of average

#define ldrdelay            50         // Time in milliseconds required for LDR to give accurate reading
#define IRdelay             120        // Time in microseconds required for IR phototransistor to give good range reading

#define Lencoderinterrupt   0          // Interrupt used for left  encoder - depends on input pin
#define Rencoderinterrupt   1          // Interrupt used for right encoder - depends on input pin
#define Aencoderinterrupt   4          // Interrupt used for arm   encoder - depends on input pin
#define Gencoderinterrupt   5          // Interrupt used for grip  encoder - depends on input pin

#define objectsensitivity   120        // A front sensor input must be this percentage higher than the average to register as an object
#define maxdistance         200        // Front sensor readings smaller than this are considered empty space.
#define blockeddistance     500        // If distance is greater than this and no objects then path is blocked
#define bestdistanceIR      800        // Best distance for picking object up according to IR sensors.
#define bestdistanceLDR     200        // Best distance for gripping object according to LDR.
