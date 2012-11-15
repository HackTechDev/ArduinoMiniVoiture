/*
 * Telecommande
 * Microcontrolleur : Nano AtMega328
 *
 */

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
    switch (ir_code) {
        case 0xff00:
            Motor_Control (FORW, 0, FORW, 0); // Arret
            break;
        case -511:
            Motor_Control (FORW, 200, FORW, 200); // Avancer
            Serial.print("Avancer : ");
            Serial.print(ir_code);
            Serial.print("\n");
            break;
        case -2551:
            Motor_Control (BACK, 200, BACK, 200); // Reculer
            Serial.print("Reculer : ");
            Serial.print(ir_code);
            Serial.print("\n");       
            break;
        case -1276:
            Motor_Control (FORW, 200, BACK, 200); // Tourner à gauche
            Serial.print("Tourner a Gauche : ");
            Serial.print(ir_code);
            Serial.print("\n");
            break;
        case -1786:
            Motor_Control (BACK, 200, FORW, 200); // Tourner à droite
            Serial.print("Tourner a Droite : ");
            Serial.print(ir_code);
            Serial.print("\n");
            break;   
        case -3316:
            Serial.print("Touche 1 : ");
            Serial.print(ir_code);
            for (i = 0; i <80; i ++) {
                digitalWrite (BUZZER, HIGH); //Make Sound
                delay (1); // Delay 1ms
                digitalWrite (BUZZER, LOW); // do not send sound
                delay (1); // Delay ms
            }
            Serial.print("\n");
            break;
        case -4336:
            Serial.print("Touche 1 : ");
            Serial.print(ir_code);
            digitalWrite (LED_RED, HIGH); // LED lamp pin high, light LED light
            delay (1000); // delay 1s
            digitalWrite (LED_RED, LOW); // LED pin lights low, turn off LED lights
            delay (1000); // delay 1s
            Serial.print("\n");
            break;    
        case -4591:
            Serial.print("Touche 2 : ");
            Serial.print(ir_code);
            digitalWrite (LED_GREEN, HIGH); // LED lamp pin high, light LED light
            delay (1000); // delay 1s
            digitalWrite (LED_GREEN, LOW); // LED pin lights low, turn off LED lights
            delay (1000); // delay 1s
            Serial.print("\n");
            break;  
    }

    /*
     * Recherche de code infrarouge de la telecommande
     */

    /*
       Serial.print("Code : ");
       Serial.print(ir_code);
       Serial.print("\n");
     */
}

char logic_value () {
    while (! (digitalRead (8))); // low latency
    Pulse_Width = TCNT1;
    TCNT1 = 0;
    if (Pulse_Width>= 7 && Pulse_Width <= 10) // low 560us
    {
        while (digitalRead (8 ));// is waiting for another job
        Pulse_Width = TCNT1;
        TCNT1 = 0;
        if (Pulse_Width>= 7 && Pulse_Width <= 10) // then high 560us
            return 0;
        else if (Pulse_Width>= 25 && Pulse_Width <= 27) // then high 1.7ms
            return 1;
    }
    return -1;
}

void pulse_deal () {
    int i;

    // Execute 8 0
    for (i = 0; i<8; i++) {
        if (logic_value() != 0) // not 0
            return;
    }

    // Execute 6 1
    for (i = 0; i <6; i++) {
        if (logic_value ()!= 1) // not a
            return;
    }

    // Execute a 0
    if (logic_value ()!= 0) // not 0
        return;

    // Execute a 1
    if (logic_value ()!= 1) // not a
        return;

    // Parse the command remote control coding instructions
    ir_code = 0x00; // clear
    for (i = 0; i <16; i++) {
        if (logic_value () == 1) {
            ir_code |= (1 <<i);
        }
    }
}


void remote_decode (void) {
    TCNT1 = 0X00;

    while (digitalRead (8)) // is waiting for another job
    {
        if (TCNT1>= 1563) // When the high lasts longer than 100ms, that no button is pressed at this time
        {
            ir_code = 0xff00;
            return;
        }
    }

    // If the high does not last more than 100ms
    TCNT1 = 0X00;

    while (! (digitalRead (8))); // low latency
    Pulse_Width = TCNT1;
    TCNT1 = 0;
    if (Pulse_Width>= 140 && Pulse_Width <= 141) // 9ms
    {

        while (digitalRead (8 ));// is waiting for another job
        Pulse_Width = TCNT1;
        TCNT1 = 0;
        if (Pulse_Width>= 68 && Pulse_Width <= 72) // 4.5ms
        {
            pulse_deal ();
            return;
        }
        else if (Pulse_Width>= 34 && Pulse_Width <= 36) // 2.25ms
        {
            while (! (digitalRead (8 )));// low latency
            Pulse_Width = TCNT1;
            TCNT1 = 0;
            if (Pulse_Width>= 7 && Pulse_Width <= 10) // 560us
            {
                return;
            }
        }
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
}

void loop () {
    timer1_init ();// initialize the timer function
    while (1) {
        remote_decode (); // decode
        remote_deal (); // perform decoding results
    }
}
