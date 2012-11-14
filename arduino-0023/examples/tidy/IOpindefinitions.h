// Define IO pins for Mr. Tidy MkII

#define USB_RXpin 0           // Digital input  0  - Used for programming
#define USB_TXpin 1           // Digital output 1  - Used for programming

#define Lmotordirpin 22       // Digital output 22 - HIGH=forward LOW=reverse
#define Lmotorpwmpin 4        // Digital output 4  - PWM speed control
#define Lmotorencpin 2        // Digital input  2  - Interrupt 0
#define Lmotorcurpin 0        // Analog  input  0  - Current drawn by motor

#define Rmotordirpin 23       // Digital output 23 - HIGH=forward LOW=reverse
#define Rmotorpwmpin 5        // Digital output 5  - PWM speed control
#define Rmotorencpin 3        // Digital input  3  - Interrupt 1
#define Rmotorcurpin 1        // Analog  input  1  - Current drawn by motor

#define Amotordirpin 24       // Digital output 24 - HIGH=raise LOW=lower
#define Amotorpwmpin 6        // Digital output 6  - PWM speed control
#define Amotorencpin 19       // Digital input  19 - Interrupt 4
#define Amotorcurpin 2        // Analog  input  2  - Current drawn by motor
#define Amotorlimpin 42       // Digital input  42 - LOW=arm all the way down       Use internal pullup resistor

#define Gmotordirpin 25       // Digital output 25 - HIGH=close LOW=open
#define Gmotorpwmpin 7        // Digital output 7  - PWM speed control
#define Gmotorencpin 18       // Digital input  18 - Interrupt 5
#define Gmotorcurpin 3        // Analog  input  3  - Current drawn by motor
#define Gmotorlimpin 41       // Digital input  41 - LOW=gripper completely open    Use internal pullup resistor

#define RGBLDRpin 12          // Analog  input  12 - Colour sensing LDR
#define RedLEDpin 8           // Digital output 8  - PWM adjust brightness of Red   LED
#define GreenLEDpin 9         // Digital output 9  - PWM adjust brightness of Green LED
#define BlueLEDpin 10         // Digital output 10 - PWM adjust brightness of Blue  LED

#define FrontIRledspin 29     // Digital output 29 - HIGH turns on 4x IR LEDs at front for detecting object to pick up
#define Frontfarleftsenpin 4  // Analog  input  4  - Detects objects front far left
#define Frontmidleftsenpin 5  // Analog  input  5  - Detects objects front middle left
#define Frontmidrightsenpin 6 // Analog  input  6  - Detects objects front middle right
#define Frontfarrightsenpin 7 // Analog  input  7  - Detects objects front far right

#define LeftsideIRledpin 30   // Digital output 30 - HIGH turns on left side IR LED
#define Leftsidesenpin 35     // Digital input  35 - HIGH when object in close proximity

#define RightsideIRledpin 31  // Digital output 31 - HIGH turns on right side IR LED
#define Rightsidesenpin 36    // Digital input  36 - HIGH when object in close proximity

#define LeftrearIRledpin 32   // Digital output 32 - HIGH turns on rear left IR LED
#define Leftrearsenpin 37     // Digital input  37 - HIGH when object in close proximity

#define RightrearIRledpin 33  // Digital output 33 - HIGH turns on rear right IR LED
#define Rightrearsenpin 38    // Digital input  38 - HIGH when object in close proximity

#define BatteryVoltpin 13     // Analog  input  13 - Monitor battery voltage for docking / recharging
#define IRreceiverpin 39      // Digital input  39 - IR beacon navigation input
#define Speakerpin 40         // Digital output 40 - 32ohm Speaker

// Optional line following PCB
#define Linefollowledpin 34   // Digital output 34 - HIGH turns on line following IR LEDs
#define LFfarleftsenpin 8     // Analog  input  8  - Line follower far left  sensor input
#define LFmidleftsenpin 9     // Analog  input  9  - Line follower mid left  sensor input
#define LFmidrightsenpin 10   // Analog  input  10 - Line follower mid right sensor input
#define LFmidrightsenpin 11   // Analog  input  11 - Line follower far right sensor input

// Optional serial LCD display
#define LCD_RXpin 17          // Digital input  17 - Used for LCD display
#define LCD_TXpin 16          // Digital output 16 - Used for LCD display

// Optional Xbee module
#define Xbe_RXpin 15          // Digital input  15 - Used for Xbee module
#define Xbe_TXpin 14          // Digital output 14 - Used for Xbee module

// Optional I2C devices
#define I2C_SDApin 21         // Digital I/O    21 - Used for I2C devices with internal pullup resistor if required 
#define I2C_SCLpin 20         // Digital I/O    20 - Used for I2C devices with internal pullup resistor if required

