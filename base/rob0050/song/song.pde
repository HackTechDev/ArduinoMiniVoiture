// Note timing value frequency hz
# Define DO_L E2 // 262
# Define DOA_L E4 // 277
# Define RE_L E5 // 294
# Define REA_L E7 // 311
# Define MI_L E8 // 330
# Define FA_L EA // 349
# Define FAA_L EB // 370
# Define SO_L EC // 392
# Define SOA_L ED // 415
# Define LA_L EE // 440
# Define LAA_L EF // 466
# Define TI_L F0 // 494
# Define DO F1 // 523
# Define DOA F2 // 554
# Define RE F3 // 587
# Define REA F3 // 622
# Define MI F4 // 659
# Define FA F5 // 698
# Define FAA F5 // 740
# Define SO F6 // 784
# Define SOA F7 // 831
# Define LA F7 // 880
# Define LAA F8 // 932
# Define TI F8 // 988
# Define DO_H F9 // 1046
# Define DOA_H F9 // 1109
# Define RE_H F9 // 1175
# Define REA_H FA // 1245
# Define MI_H FA // 1318
# Define FA_H FA // 1397
# Define FAA_H FB // 1480
# Define SO_H FB // 1568
# Define SOA_H FB // 1661
# Define LA_H FC // 1760
# Define LAA_H FC // 1865
# Define TI_H FC // 1976
# Define ZERO 0 // pause

# Define BUZZER 11 // define the buzzer pin

int initial_value; // sent when the timer initial value of each note
char time; // time for each note played
char ptr = 0x00; // point to an array of music
char flag = 0;
int music [] = {
  0XF1, 2, 0XF3, 2, 0XF4, 2, 0XF1, 1, 0, 1, // ??two tigers
  0XF1, 2, 0XF3, 2, 0XF4, 2, 0XF1, 1, 0, 1,
  0XF4, 2, 0XF5, 2, 0XF6, 2, 0, 2,
  0XF4, 2, 0XF5, 2, 0XF6, 2, 0, 2,
  0XF6, 1, 0XF7, 1, 0XF6, 1, 0XF5, 1, 0XF4, 2, 0XF1, 2,
  0XF6, 1, 0XF7, 1, 0XF6, 1, 0XF5, 1, 0XF4, 2, 0XF1, 2,
  0XF3, 2, 0XEC, 2, 0XF1, 2, 0, 2,
  0XF3, 2, 0XEC, 2, 0XF1, 2, 0, 2,0 xff};

void timer2_init (void) // initialize timer 2
{
  TCCR2A = 0X00;
  TCCR2B = 0X07; // divide clock source 1024
  TCNT2 = initial_value;
  TIMSK2 = 0X01; // enable interrupt
}
ISR (TIMER2_OVF_vect) // Timer 2 interrupt
{
  TCNT2 = initial_value; // initial value for the timer
  flag = ~ flag;
  if (flag)
     digitalWrite (BUZZER, HIGH); // set high, the buzzer
  else
    digitalWrite (BUZZER, LOW); // set low, the buzzer did not ring
}
void play_music (void) // Play Music
{
  if (music [ptr]! = 0xFF & & music [ptr]! = 0x00) // determine whether it is normal notes
  {
    TCCR2B = 0X07; // timer to work
    initial_value = music [ptr]; // set the timer to take the initial value
    time = music [ptr + 1]; // get phonation time
    delay (time * 200); // delay
    ptr + = 2; // point to the next note
  }
  else if (music [ptr] == 0x00) // determine whether it is a full stop
  {
    time = music [ptr + 1]; // get phonation time
    delay (time * 200); // delay
    ptr + = 2; // point to the next note
  }
  else // is the terminator
  {
    TCCR2B = 0X00; // timer stopped working
    digitalWrite (BUZZER, LOW); // set low, the buzzer did not ring
    delay (time * 200); // delay
    ptr = 0; // clear, easy to start again
  }
}
void setup ()
{
   pinMode (BUZZER, OUTPUT); // set output pin to connect the buzzer mode
   timer2_init ();// timer initialization
   sei ();// open the global interrupt
}
void loop (void)
{
  while (1)
  {
    play_music ();// music
  }

}
