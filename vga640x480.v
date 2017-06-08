`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    00:30:38 03/19/2013
// Design Name:
// Module Name:    vga640x480
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
module vga640x480(
	input wire pix_en,		//pixel clock: 25MHz
	input wire clk,			//100MHz
	input wire rst,			//asynchronous reset
    input [0:`MAX_LEN_SNAKE*`MAX_BITS - 1] PSX, //change later
    input [0:`MAX_LEN_SNAKE*`MAX_BITS - 1] PSY, //change later
    input [`LOG_LEN_SNAKE - 1:0] len_Snake,
    input [0:`MAX_FOODS*`MAX_BITS - 1] PFX,
    input [0:`MAX_FOODS*`MAX_BITS - 1] PFY,
    input [`LOG_FOODS - 1:0] num_Foods,
	input [0:((2*`MAX_BITS)-1)+2] PPU,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;
reg [9:0] mhc;
reg [9:0] mvc;
wire [0:`MAX_BITS - 1] SX [0:`MAX_LEN_SNAKE - 1]; //change later
wire [0:`MAX_BITS - 1] SY [0:`MAX_LEN_SNAKE - 1]; //change later
wire [0:`MAX_BITS - 1] FX [0:`MAX_FOODS - 1];
wire [0:`MAX_BITS - 1] FY [0:`MAX_FOODS - 1];
reg [6:0] i,j,k; //change later
reg [1:0]dispReset = 0;
reg snakePos [0:`DISP_H - 1][0:`DISP_V -1];
reg foodPos [0:`DISP_H - 1][0:`DISP_V - 1];

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=

//set all bits to 0



//unpack
genvar y,z;
generate
    for(y = 0; y < `MAX_LEN_SNAKE; y= y + 1)
        for(z = 0; z < `MAX_BITS; z= z + 1)
        begin
            assign SX[y][z] = PSX[`MAX_BITS*y + z];
            assign SY[y][z] = PSY[`MAX_BITS*y + z] ;
        end
    for(y = 0; y < `MAX_FOODS; y= y + 1)
        for(z = 0; z < `MAX_BITS; z= z + 1)
        begin
            assign FX[y][z] = PFX[`MAX_BITS*y + z];
            assign FY[y][z] = PFY[`MAX_BITS*y + z] ;
        end
endgenerate

//writing to bitmap block
always@(PSX, PSY)
begin
	/*if(dispReset == 0)
	begin*/
		for(i = 0; i < `DISP_H; i = i + 1)
			for(j = 0; j < `DISP_V; j = j +1)
            begin
                snakePos[i][j] <= 0;
                foodPos[i][j] <= 0;
            end
        for(i =0; i < len_Snake; i = i + 1)
            snakePos[SX[i]][SY[i]] <= 1;
        for(i =0; i < num_Foods; i = i +1)
            foodPos[FX[i]][FY[i]] <= 1;
end

always @(posedge clk)
begin
	// reset condition
	if (rst == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else if (pix_en == 1)
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
            begin
				vc <= 0;

            end
		end

	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(clk, rst, pix_en)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp)
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		//if snake (x,y) bits are on, show that coordinate to 0
		if(snakePos[(hc-hbp)/20][(vc-vbp)/20])
		begin
			red = 3'b111;
			green = 3'b111;
			blue = 2'b11;
		end
        else if(foodPos[(hc-hbp)/20][(vc-vbp)/20])
        begin
            red = 3'b000;
            green = 3'b111;
            blue = 2'b00;
        end
		  else if(PPU[0] == 1 && (hc-hbp)/20 == PPU[2+:`MAX_BITS] && (vc-vbp)/20 == PPU[(2+`MAX_BITS)+:`MAX_BITS])
		  begin
				if(PPU[1] == `GAME_FAST)
				begin
					red = 3'b111;
					green = 3'b000;
					blue = 2'b00;
				end
				else
				begin
					red = 3'b000;
					green = 3'b000;
					blue = 2'b11;
				end
					
		  end
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule
