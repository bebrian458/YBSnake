# YBSnake

Created by:
	Brian Be
	Yamato Sasaki
	Sulmie Tran

__Introduction__

The objective of this project was to create a typical game of Snake, with additional power-up features. The user can navigate through the map with the buttons on the FPGA board, and control the snake. The purpose of the game is to collect foods to make the snake grow longer while avoiding the wall (the border of the map). Unlike the typical Snake game, the user can choose to pick up power-ups, such as speed up and slowdown, in order to assist himself/herself. The game is equipped with a pause switch and a reset button.
 
__Design Description__

The game is implemented in Verilog language, using 4 modules. These modules include a clock divider to enable moving the snake at different speeds (due to power ups). Also included is a module to display the game via VGA. A third module is used to implement the game console, and a fourth top module is used to connect all of the previous modules.

 
__Simulation__

Since we cannot generate 100MHz clock with the testbench, we were unable to use the simulation feature. Instead, we tested by writing the program onto the FPGA board. We played the game for several minutes, and checked that all intended features are working.
We checked the following:
* The snake moves in the direction the user specified
* If user does not input anything, it moves in the direction it moved last
* If the head of the snake overlaps the food (green), the food is consumed (disappeared) and the snake length grows by 1 (until the snake length is equal to 8, which was the maximum number the FPGA board could handle)
* If the snake is at the maximum length, and the snake consumes a food, it does not grow, but does every other action (food is respawned, etc.)
* Snake cannot go into the opposite direction it is currently moving
* The game resets if the snake hits the boundaries
* The game resets if the snake head hits any part of its body
* The snake moves at 2 times the normal rate if the speedup power-up is obtained (red) for approximately 10 seconds
* The snake moves at ½ times the normal rate if the slowdown power-up is obtained (blue) for approximately 10 seconds
* After 10 seconds of powerup spawning, the powerup expires and disappears
* Pause switch works as intended (the states of all objects including snake, powerup, powerup remaining time, food, etc. are maintained)
* Food and powerup spawn location is random
* When the game starts/resets (by crashing/ pressing the reset button), the snake spawns at top-left, with default moving direction set to right
* Food should not spawn as the same location as the snake’s head
* When the food is consumed, it spawns at the new (random) location
 
 
__Conclusion__

Overall, we ended up with the successful snake game implementation. We struggled with the rendering of the objects. Initially, we tried 64x48 dimension snake game, but the FPGA board was unable to handle the bitmap array holding the information. Therefore, we had to decrease the resolution to 32x24. Also, unlike other games, the snake was able to move in any of the 32x24 coordinates, and therefore the VGA modules had to have a flexible interface in which it takes in any input coordinate, and output the specified object in the specified coordinate. 
