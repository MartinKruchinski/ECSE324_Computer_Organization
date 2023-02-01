# **ECSE324**
Laboratories coded in ARM Assembly 2021.

****Lab 1:**** 

1- The first problem was to create an iterative algorithm that calculates the inputted Fibonacci number the user wants to get.

2- The second problem was to create a recursive version of the Fibonacci algorithm.

3- In part 3 of the laboratory, I worked on a 2d convolution algorithm, which is usually used in image processing applications. The convolution algorithm is used to implement image filters and to detect objects using machine learning.

4- In the last part of the lab, I implemented the bubble sort algorithm, which sorts an input array in ascending and descending order. The user enters as input an array of size “size” and the program returns the same array in ascending or descending order.

****Lab 2:****

1- For the first task of the lab, I implemented an application that detects when you write to any of the 0 to 9 switches of the DE1-SoC computer and displays the pressed switch in the corresponding LEDs (0 to 9).

2- For the second task of the lab, I implemented an application that uses Switches (SW0-SW3, SW9), LEDs (LED0-LED3), Pushbuttons (PB0-PB3) and HEX displays (HEX0-HEX5). The way the program works is that we use Switches (SW0-SW3) to choose a value from 0 to 15 (in binary), and we choose in what HEX display (HEX0-HEX4) we want to display the value in base 16 by pressing and releasing any of the Pushbuttons (PB0-PB3). HEX4 and HEX4 are not used so all the segments are turned on all the time. However, while SW9 is pressed the program erases everything in the HEX displays, including HEX4 and HEX5.

3- Task 3 of this lab, consists of a counter that counts from 0 to F (hex value for 15) in the format: 0..1..2..A..F..0..1.. and displays the numbers in HEX0 and LEDs3-0. The counter uses the ARM A9 private timer to measure and count in intervals of one second

4- Task 4 of this lab consists of a polling-based stopwatch that counts in increments of 10ms from 10ms to 59 minutes 59 seconds and 590ms. The stopwatch uses the ARM A9 private timer to synchronize the intervals of 10ms and uses HEX1-0 to display milliseconds, HEX3-2 to display seconds, and HEX5-4 to display minutes. In addition, it uses the Pushbuttons2-0 to reset, stop, and start the watch respectively.

5- Task 5 of this lab consists of a interrupt-based stopwatch that counts in increments of 10ms from 10ms to 59 minutes 59 seconds and 590ms. The stopwatch uses the ARM A9 private timer to synchronize the intervals of 10ms and uses HEX1-0 to display milliseconds, HEX3-2 to display seconds, and HEX5-4 to display minutes. In addition, it uses the Pushbuttons2-0 to reset, stop, and start the watch respectively.

****Lab 3:****

1- For the first part of the lab, we were tasked to create a VGA driver that would draw a certain sentence into the character buffer and color the VGA pixel buffer using many colors. In our case the assignment was to write “Hello World” to the Character buffer.

2- For the second part of the lab, we implemented a program that reads keyboard input using a PS/2 driver and writes the respective make and break codes of the typed character into the character buffer using the drivers created in the last part.

3- For the third part of the lab, we were given the task to implement a TIC-TAC-TOE game using the numbers from the keyboard 0-9 to select the place where we want to put our mark and the pixel and character buffers. We used the pixel buffer to draw the TIC-TAC-TOE board and the player’s moves that would be represented as a “+” sign and an unfilled square. Also, we used the character buffer to write the status of the game, meaning while the game is running, we write the player’s turn and when the game is concluded we write the results of the game: either “Player-1 Wins”, “Player-2 Wins” or “Draw”.
