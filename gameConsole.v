`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:29:07 05/25/2017 
// Design Name: 
// Module Name:    gameConsole 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//

//////////////////////////////////////////////////////////////////////////////////
module gameConsole(
	 input clk,
    input game_en,
	 input pause,
    input rst,
	 input isUp,
	 input isDown,
	 input isLeft,
	 input isRight,
    output [0:`MAX_BITS*`MAX_LEN_SNAKE - 1] PSX, //change later
    output [0:`MAX_BITS*`MAX_LEN_SNAKE - 1] PSY, //change later
    output reg [`LOG_LEN_SNAKE - 1:0] len_Snake = 1,
    output [0:`MAX_BITS*`MAX_FOODS -1] PFX,
    output [0:`MAX_BITS*`MAX_FOODS -1] PFY,
    output reg [`LOG_FOODS - 1:0] num_Foods = 1,
	 output reg [0:((2*`MAX_BITS)-1)+2] PPU = 0
    
    );


reg [0:`MAX_BITS - 1] SX [0:`MAX_LEN_SNAKE-1];
reg [0:`MAX_BITS - 1] SY [0:`MAX_LEN_SNAKE-1];
reg [0:`MAX_BITS - 1] FX [0:`MAX_FOODS - 1];
reg [0:`MAX_BITS - 1] FY [0:`MAX_FOODS - 1];
reg[9:0] i;
reg[0:10] xclock;
reg[0:10] yclock;
reg[0:10] pxclock;
reg[0:10] pyclock;
reg[0:`MAX_BITS - 1] randFX;
reg[0:`MAX_BITS - 1] randFY;
reg[0:`MAX_BITS - 1] randX, randY;
reg[1:0] currDir = `RIGHT;
reg gameOver = 0; 
reg [1:0] gameClock = 0;
reg [1:0] gameState = `GAME_NORMAL;
reg [5:0] stateCount = 0;
reg[0:`MAX_BITS - 1] randPUX;
reg[0:`MAX_BITS - 1] randPUY;


genvar y,z;
generate
    for(y = 0; y < `MAX_LEN_SNAKE; y= y + 1)
        for(z = 0; z < `MAX_BITS; z= z + 1)
        begin
            assign PSX[`MAX_BITS*y + z] = SX[y][z];
            assign PSY[`MAX_BITS*y + z] = SY[y][z];
        end
    for(y= 0; y < `MAX_FOODS; y = y+1)
        for(z = 0; z < `MAX_BITS; z = z +1)
        begin
            assign PFX[`MAX_BITS*y +z] = FX[y][z];
            assign PFY[`MAX_BITS*y +z] = FY[y][z];
        end
endgenerate

always@(posedge clk)
begin
	if (rst)
	begin
		xclock <= 10;
		yclock <= 0;
		pxclock <= 54;
		pyclock <= 68;
	end
	xclock <= xclock + 1;
	yclock <= yclock + 1;
	pxclock <= pxclock + 1;
	pyclock <= pyclock + 1;
    if(xclock == 346)
        xclock <= 0;
    if(yclock == 721)
        yclock <= 0;
	 if(pxclock == 432)
		pxclock <= 0;
	 if(pyclock == 617)
		pyclock <= 0;
	randFX <= xclock % `DISP_H;
	randFY <= yclock % `DISP_V;
	randPUX <= pxclock % `DISP_H;
	randPUY <= pyclock % `DISP_V;
end

always@(posedge game_en, posedge rst)
begin
	 
    if(rst || gameOver)
    begin
        for(i = 0; i < `MAX_LEN_SNAKE; i = i +1)
        begin
            SX[i] <= 0;
            SY[i] <= 0;
        end
        len_Snake <= 1;
        num_Foods <= 1;
		  currDir <= `RIGHT;
		  FX[0] <= 8; 
		  FY[0] <= 15;
        gameOver <= 0;
		  gameState <= `GAME_NORMAL;
		  stateCount <= 0;
		  gameClock <= 0;
          PPU <= 0;
	 end
	 else if(pause)
	 begin
		  for(i = 0; i < `MAX_LEN_SNAKE; i = i +1)
        begin
            SX[i] <= SX[i];
            SY[i] <= SY[i];
        end
	 end
    else
    begin
			gameClock <= gameClock + 1;
			stateCount <= stateCount + 1;
			if(stateCount == 63 && (gameState == `GAME_FAST || gameState == `GAME_SLOW))
				gameState <= `GAME_NORMAL;
			else if(stateCount == 63 && gameState == `GAME_NORMAL)
			begin
                if(PPU[0] == 0)
                begin
                    PPU[2+:`MAX_BITS] <= randPUX;
                    PPU[(2+`MAX_BITS)+:`MAX_BITS] <=randPUY;
                    PPU[0] <= 1;
                    PPU[1] <= randPUX[2];
                end
                else
                begin
                    PPU[0] <= 0;
                end
			end
		 if((gameState == `GAME_NORMAL && gameClock % 2 != 0) || (gameState == `GAME_SLOW && gameClock % 4 != 0))
		 begin
			//do nothing
		 end
		else
		begin
            randX <= randFX;
            randY <= randFY;
			if (SX[0] == FX[0] && SY[0] == FY[0] && len_Snake < `MAX_LEN_SNAKE)
			begin
				SX[len_Snake] <= SX[len_Snake - 1];
				SY[len_Snake] <= SY[len_Snake - 1];
                if(len_Snake != `MAX_LEN_SNAKE - 1)
						len_Snake <= len_Snake + 1;
                
                
				if (SX[0] == randX && SY[0] == randY)
				begin
					FX[0] <= (randX + 13)%`DISP_H;
					FY[0] <= (randY + 7)%`DISP_V;
				end
				else
				begin
					FX[0] <= randX;
					FY[0] <= randY;
				end
			end
			if(PPU[0] == 1 && PPU[2+:`MAX_BITS] == SX[0] && PPU[(2+`MAX_BITS)+:`MAX_BITS] == SY[0])
			begin
				PPU[0] <= 0;
				gameState <= PPU[1];
				stateCount <= 0;
			end
            for(i = 1; i < len_Snake; i = i + 1)
            begin
                if(SX[0] == SX[i] && SY[0] == SY[i])
                    gameOver <= 1;
            end
			//check len_snake
			for(i = 1; i < len_Snake; i = i +1)
			begin
				SX[i] <= SX[i-1];
            SY[i] <= SY[i-1];
			end
			if (isUp && currDir != `DOWN)
			begin
				currDir <= `UP;
            if(SY[0] == 0)
					gameOver <= 1;
            else
					SY[0] <= SY[0] - 1'b1;
			end
			else if (isDown && currDir != `UP)
			begin
				currDir <= `DOWN;
                if(SY[0] == `DISP_V)
                    gameOver <= 1;
                else
                    SY[0] <= SY[0] + 1'b1;
			end
			else if (isLeft && currDir != `RIGHT)
			begin
				currDir <= `LEFT;
                if(SX[0] == 0)
                    gameOver <= 1;
                else
                    SX[0] <= SX[0] - 1'b1;
			end
			else if (isRight && currDir != `LEFT)
			begin
				currDir <= `RIGHT;
                if(SX[0] == `DISP_H)
                    gameOver <= 1;
                else
                    SX[0] <= SX[0] + 1'b1;
			end
			else
			begin
				 if (currDir == `UP)
                begin
					if(SY[0] == 0)
                        gameOver <= 1;
                    else
                        SY[0] <= SY[0] - 1'b1;
                end
				 if (currDir == `DOWN)
                begin
					if(SY[0] == `DISP_V)
                        gameOver <= 1;
                    else
                        SY[0] <= SY[0] + 1'b1;
                end
				 if (currDir == `LEFT)
                begin
					if(SX[0] == 0)
                        gameOver <= 1;
                    else
                        SX[0] <= SX[0] - 1'b1;
                end
				 if (currDir == `RIGHT)
                begin
					 if(SX[0] == `DISP_H)
                        gameOver <= 1;
                    else
                        SX[0] <= SX[0] + 1'b1;
                end
				 end
			end
			
			
        
        
    end
 end


endmodule
