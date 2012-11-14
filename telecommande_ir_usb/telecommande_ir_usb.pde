/*
 * Arduino Uno
 * Emetteur infrarouge
 * Télécommande Infra-rouge par l'ordinateur 
 * IDE : 0.23
 */
 
 /*
 Branchement émetteur infrarouge
 Fil rouge => 5V
 Fil noir => GND (cote VIN)
 Fil vert => 3
 */
 
/*
    Liens :
      http://stackoverflow.com/questions/5697047/convert-serial-read-into-a-useable-string-using-arduino
      http://www.dfrobot.com/wiki/index.php?title=Digital_IR_Transmitter_Module%28SKU:DFR0095%29
      http://www.arcfn.com/2009/08/multi-protocol-infrared-remote-library.html
 */

#include <IRremote.h>

IRsend irsend;

char inData[20]; // Allocate some space for the string
char inChar=-1; // Where to store the character read
byte index = 0; // Index into array; where to store the character

int amplitude = 100;

void setup() {
  Serial.begin(9600);
}

char Comp(char* This) {
    while (Serial.available() > 0) // Don't read unless
                                   // there you know there is data
    {
        if(index < 19) // One less than the size of the array
        {
            inChar = Serial.read(); // Read a character
            inData[index] = inChar; // Store it
            index++; // Increment where to write next
            inData[index] = '\0'; // Null terminate the string
        }
    }

    if (strcmp(inData,This)  == 0) {
        for (int i=0;i<19;i++) {
            inData[i]=0;
        }
        index=0;
        return(0);
    }
    else {
        return(1);
    }
}

void loop() {
  
   if (Comp("avancer") == 0 || Comp("a") == 0) {
        for (int i = 0; i < amplitude; i++) {
           Serial.print("Avancer\n");
           irsend.sendNEC(0xFD807F, 32);
           delay(100);
        }          
        Serial.print("Arreter\n");
        irsend.sendNEC(0xFD00FF, 32);
    }

   if (Comp("reculer") == 0 || Comp("r") == 0) {
        for (int i = 0; i < amplitude; i++) {
           Serial.print("Reculer\n");
           irsend.sendNEC(0xFD906F, 32);
           delay(100);
        }          
        Serial.print("Arreter\n");
        irsend.sendNEC(0xFD00FF, 32);
    }

   if (Comp("droite") == 0 || Comp("d") == 0) {     
        for (int i = 0; i < amplitude/3; i++) {
           Serial.print("Droite\n");
           irsend.sendNEC(0xFD609F, 32);
           delay(100);
        }          
        Serial.print("Arreter\n");
        irsend.sendNEC(0xFD00FF, 32);
    }

   if (Comp("gauche") == 0 || Comp("g") == 0) {
        for (int i = 0; i < amplitude/3; i++) {
           Serial.print("Gauche\n");
           irsend.sendNEC(0xFD20DF, 32);
           delay(100);
        }
        Serial.print("Arreter\n");
        irsend.sendNEC(0xFD00FF, 32);       
    }
 
   if (Comp("zero") == 0 || Comp("0") == 0) {
           amplitude=100;
           Serial.print("amplitude moyenne : ");
           Serial.print(amplitude);
           Serial.print("\n");           
           irsend.sendNEC(0xFD30CF, 32);
    }

   if (Comp("un") == 0 || Comp("1") == 0) {
           if(amplitude>0){
             amplitude-=10;
           }
           Serial.print("amplitude Diminue : ");
           Serial.print(amplitude);
           Serial.print("\n");
           irsend.sendNEC(0xFD8877, 32);
    }

   if (Comp("deux") == 0 || Comp("2") == 0) {
           if(amplitude<200){
             amplitude+=10;
           }
           Serial.print("amplitude Augmente : ");
           Serial.print(amplitude);
           Serial.print("\n");
           irsend.sendNEC(0xFD08F7, 32);
           delay(100);
    }
    
}
