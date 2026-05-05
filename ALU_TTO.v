`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/30/2025 11:18:53 PM
// Design Name: 
// Module Name: ALU_CASE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ALU_TTO(
    input clk,               // Clock input
    input [7:0] A,           // 8-bit Input A
    input [7:0] B,           // 8-bit Input B
    input [3:0] SEL,         // 4-bit Operation Select
    output reg [7:0] Y       // 8-bit Registered Output
    );

    // Sequential logic triggered on the rising edge of the clock
    always @(posedge clk) begin
        case (SEL)
            4'b0000: Y <= A & B;      // Bitwise AND
            4'b0001: Y <= A | B;      // Bitwise OR
            4'b0010: Y <= A + B;      // Addition
            4'b0011: Y <= A - B;      // Subtraction
            4'b0101: Y <= ~(A & B);   // Bitwise NAND
            4'b0110: Y <= A ^ B;      // Bitwise XOR
            4'b0111: Y <= A << 1;     // Logical Shift Left
            4'b1000: Y <= A >> 1;     // Logical Shift Right
            
            default: Y <= 8'b0;       // Default case to prevent latches
        endcase
    end

endmodule
