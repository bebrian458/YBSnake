`timescale 1ns / 1ps
`include "constants.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
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
module NERP_demo_top(
	input wire clk,			//master clock = 100MHz
	input wire pause,
	input wire clr,			//center pushbutton for reset
	input wire btnU,
	input wire btnD,
	input wire btnL,
	input wire btnR,
	//output wire [6:0] seg,	//7-segment display LEDs
	//output wire [3:0] an,	//7-segment display anode enable
	//output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);

// VGA display clock interconnect
wire pix_en;
wire game_en;
wire [0:`MAX_LEN_SNAKE*`MAX_BITS - 1] PSX; //change later
wire [0:`MAX_LEN_SNAKE*`MAX_BITS - 1] PSY; //change later
wire [`LOG_LEN_SNAKE - 1:0] len_Snake;
wire [0:`MAX_FOODS*`MAX_BITS - 1] PFX;
wire [0:`MAX_FOODS*`MAX_BITS - 1] PFY;
wire [`LOG_FOODS - 1:0] num_Foods;
wire [0:((2*`MAX_BITS)-1)+2] PPU;


	reg rst;
	reg isUp;
	reg isDown;
	reg isLeft;
	reg isRight;
	reg rst_ff;
	reg isUp_ff;
	reg isDown_ff;
	reg isLeft_ff;
	reg isRight_ff;
	
	
 
    
    always @(posedge clk or posedge btnU)
    begin
        if (btnU) begin
			{isUp,isUp_ff} <= 2'b11;
		end
        else
        begin
            {isUp,isUp_ff} <= {isUp_ff,1'b0};
        end
    end
    
    always @(posedge clk or posedge btnD)
    begin
        if (btnD) begin
			{isDown,isDown_ff} <= 2'b11;
		end
        else
        begin
            {isDown,isDown_ff} <= {isDown_ff,1'b0};
        end
    end
    
    always @(posedge clk or posedge btnR)
    begin
        if (btnR) begin
			{isRight,isRight_ff} <= 2'b11;
		end
        else
        begin
            {isRight,isRight_ff} <= {isRight_ff,1'b0};
        end
    end
    
    always @(posedge clk or posedge btnL)
    begin
        if (btnL) begin
			{isLeft,isLeft_ff} <= 2'b11;
		end
        else
        begin
            {isLeft,isLeft_ff} <= {isLeft_ff,1'b0};
        end
    end
    
    always @(posedge clk or posedge clr)
    begin
        if (clr) begin
			{rst,rst_ff} <= 2'b11;
		end
        else
        begin
            {rst,rst_ff} <= {rst_ff,1'b0};
        end
    end


// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.rst(rst),
	.pix_en(pix_en),
    .game_en(game_en)
	);

// VGA controller
vga640x480 U3(
	.pix_en(pix_en),
	.clk(clk),
	.rst(rst),
    .PSX(PSX),
    .PSY(PSY),
    .len_Snake(len_Snake),
    .PFX(PFX),
    .PFY(PFY),
    .num_Foods(num_Foods),
	 .PPU(PPU),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue)
	);

//game controller
gameConsole  U4(
	 .clk(clk),
    .game_en(game_en),
	 .pause(pause),
    .rst(rst),
	 .isUp(isUp),
	 .isDown(isDown),
	 .isLeft(isLeft),
	 .isRight(isRight),
    .PSX(PSX),
    .PSY(PSY),
    .len_Snake(len_Snake),
    .PFX(PFX),
    .PFY(PFY),
    .num_Foods(num_Foods),
	 .PPU(PPU)





    );
endmodule
