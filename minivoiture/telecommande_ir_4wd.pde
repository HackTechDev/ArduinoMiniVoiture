/*
 * Telecommande NEC
 * Microcontrolleur : Nano AtMega328
 * IDE : 0.23
 * Vitesse série : 9600 baud
 */
 
#include <IRremote.h> // use the library 

#define BUZZER 11 // define the buzzer pin
#define LED_RED 12 // define pin red led lights
#define LED_GREEN 13 // set the control green LED digital IO pins

#define EN1 6 // Right Motor Enable Pin
#define IN1 7 // Right Motor Direction Pin
#define EN2 5 // Left Motor Enable Pin
#define IN2 4 // Left Motor Direction Pin


#define FORW 1 // Forward
#define BACK 0 // Backward

#define IR_IN 8 // Infrared Receiver (Digital Pin 8)

int Pulse_Width = 0; // store width
int ir_code = 0x00; // command value
int receiver = 8; // pin 1 of IR receiver to Arduino digital pin 11

int vitesse = 3;

IRrecv irrecv(receiver); // create instance of 'irrecv'
decode_results results;

void Motor_Control (int M1_DIR, int M1_EN, int M2_DIR, int M2_EN) // Motor control function
{
    /* Moteur M1 */

    if (M1_DIR == FORW) // M1 motor direction
        digitalWrite (IN1, HIGH); // set high, set the direction of the forward
    else
        digitalWrite (IN1, LOW); // set low, set the direction of the back

    if (M1_EN == 0) // M1 motor speed
        analogWrite (EN1, LOW); // set low, miniQ stop
    else
        analogWrite (EN1, M1_EN); // Otherwise, set the corresponding value

    /* Moteur 2 */

    if (M2_DIR == FORW) // M2 motor direction
        digitalWrite (IN2, HIGH); // set high, the direction of forward
    else
        digitalWrite (IN2, LOW); // set low, after the direction to

    if (M2_EN == 0) // M2 motor speed
        analogWrite (EN2, LOW); // set low, to stop
    else
        analogWrite (EN2, M2_EN); // set the value given
}

void timer1_init (void) {
    TCCR1A = 0X00;
    TCCR1B = 0X05; // timer clock source to
    TCCR1C = 0X00;
    TCNT1  = 0X00;
    TIMSK1 = 0X00; // disable the timer overflow interrupt
}

void remote_deal (void) {
    unsigned char i, j;
    switch (results.value) {
        case 0xFD00FF:
            Motor_Control (FORW, 0, FORW, 0); // Arret
            Serial.print("Arrêt");
            break;
        case 0xFD807F:
            for(i=0;i<vitesse;i++){
              Motor_Control (FORW, 200, FORW, 200); // Avancer
            }
            Serial.print("Avancer : ");
            Serial.print(results.value, HEX);
            Serial.print("\n");
            Motor_Control (FORW, 0, FORW, 0); // Arret
            break;
        case 0xFD906F:
            for(i=0;i<vitesse;i++){        
              Motor_Control (BACK, 200, BACK, 200); // Reculer
            }
            Serial.print("Reculer : ");
            Serial.print(results.value, HEX);
            Serial.print("\n");       
            Motor_Control (FORW, 0, FORW, 0); // Arret
            break;
        case 0xFD20DF:
            for(i=0;i<vitesse;i++){
              Motor_Control (FORW, 200, BACK, 200); // Tourner à gauche
            }
            Serial.print("Tourner a Gauche : ");
            Serial.print(results.value, HEX);
            Serial.print("\n");
            Motor_Control (FORW, 0, FORW, 0); // Arret
            break;
        case 0xFD609F:
            for(i=0;i<vitesse;i++){
              Motor_Control (BACK, 200, FORW, 200); // Tourner à droite
            }
            Serial.print("Tourner a Droite : ");
            Serial.print(results.value, HEX);
            Serial.print("\n");
            Motor_Control (FORW, 0, FORW, 0); // Arret
            break;   
        case 0xFD30CF:
            Serial.print("Touche 0 : ");
            Serial.print(results.value, HEX);
            for (i = 0; i <80; i ++) {
                digitalWrite (BUZZER, HIGH); //Make Sound
                delay (1); // Delay 1ms
                digitalWrite (BUZZER, LOW); // do not send sound
                delay (1); // Delay ms
                
                // Modification vitesse : 
                vitesse = 3;
            }
            Serial.print("\n");
            break;
        case 0xFD08F7:
            Serial.print("Touche 1 : Diminuer vitesse");
            Serial.print(results.value, HEX);
            digitalWrite (LED_RED, HIGH); // LED lamp pin high, light LED light
            delay (1000); // delay 1s
            digitalWrite (LED_RED, LOW); // LED pin lights low, turn off LED lights
            delay (1000); // delay 1s
            Serial.print("\n");
            if(vitesse > 0){
              vitesse--;
              Serial.print(vitesse);
              Serial.print("\n");              
            }
            break;    
        case 0xFD8877:
            Serial.print("Touche 2 : Augmenter vitesse");
            Serial.print(results.value, HEX);
            digitalWrite (LED_GREEN, HIGH); // LED lamp pin high, light LED light
            delay (1000); // delay 1s
            digitalWrite (LED_GREEN, LOW); // LED pin lights low, turn off LED lights
            delay (1000); // delay 1s
            Serial.print("\n");
           if(vitesse < 20){
              vitesse++;
              Serial.print(vitesse);
              Serial.print("\n");
            }            
            break;  
        case 0xFD48B7:
            Serial.print("Touche 3 : ");
	    break;	
    }
}

void setup () {
    Serial.begin(9600); // Activer la vitesse sur la console

    unsigned char i;

    for (i = 4; i <= 7; i ++) {
        pinMode (i, OUTPUT);
    }
    pinMode (IR_IN, INPUT);

    pinMode (BUZZER, OUTPUT); 

    pinMode (LED_RED, OUTPUT); // set the red LED light mode for output pin

    pinMode (LED_GREEN, OUTPUT); // set the gree LED light mode for output pin  

  irrecv.enableIRIn(); // Start the receiver
}

void loop () {
    timer1_init ();// initialize the timer function
    
    if (irrecv.decode(&results)) // have we received an IR signal?
    {
     Serial.println(results.value, HEX);// display it on serial monitor in hexadecimal
     remote_deal (); // perform decoding results
     irrecv.resume(); // receive the next value 
    }
}
