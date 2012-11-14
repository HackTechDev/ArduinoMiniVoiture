/*

Battery Voltage monitor resolution aproximately 0.015V
Using the formula: batteryvoltage = analog input * 15/10
Gives the result in 1/100th's of a volt eg. 523 = 5.23V

Note: The formula for battery voltage has been simplified so as not to use long or floating numbers and therefor is only about 99% accurate.

--------------------------------------------------------------------------------------------------------------------------------------------

This simple colour table can be used for VERY BASIC colour recognition.

 Red | Green | Blue |
-----+-------+------+
   0 |     0 |    0 | White
   0 |     0 |    1 | Blue
   0 |     1 |    0 | Green
   0 |     1 |    1 | Aqua
   1 |     0 |    0 | Red
   1 |     0 |    1 | Pink
   1 |     1 |    0 | Yellow

--------------------------------------------------------------------------------------------------------------------------------------------

Output from "FrontSensor" routine

DEC|FL|ML|MR|FR|  Description                 |  MODE 1   Action taken      |  
---+--+--+--+--+------------------------------+-----------------------------+
 0 | 0| 0| 0| 0|  nothing in range            |  continue forward           |
 1 | 0| 0| 0| 1|  object   far right          |  go right to investigate    |
 2 | 0| 0| 1| 0|  object   mid right          |  go right to investigate    |
 3 | 0| 0| 1| 1|  obstacle to  right          |  go left  to avoid          |
 4 | 0| 1| 0| 0|  object   mid left           |  go left  to investigate    |
 5 | 0| 1| 0| 1|  definite object   mid left  |  go left  to investigate    |
 6 | 0| 1| 1| 0|  obstacle ahead              |  turn in previous direction |
 7 | 0| 1| 1| 1|  obstacle to  right          |  go left  to avoid          |
 8 | 1| 0| 0| 0|  object   far left           |  go left  to investigate    |
 9 | 1| 0| 0| 1|  object   far left and right |  turn in previous direction |
10 | 1| 0| 1| 0|  object   mid right          |  go right to investigate    |
11 | 1| 0| 1| 1|  obstacle to  right          |  go left  to avoid          |
12 | 1| 1| 0| 0|  obstacle to  left           |  go right to avoid          |
13 | 1| 1| 0| 1|  obstacle to  left           |  go right to avoid          |
14 | 1| 1| 1| 0|  obstacle to  left           |  go right to avoid          |
15 | 1| 1| 1| 1|  path blocked                |  turn in previous direction |
---+--+--+--+--+------------------------------+-----------------------------+




*/   
