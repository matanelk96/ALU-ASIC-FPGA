`timescale 1ns / 1ps

module ALU_TTO_tb;

    // 1. הגדרת סיגנלים
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] SEL;
    reg clk;          // הגדרת השעון
    wire [7:0] Y;

    // --- הוספת לוגיקת שעון ---
    // אתחול השעון ל-0
    initial begin
        clk = 0;
    end
    
    // יצירת שעון עם מחזור של 10ns (כלומר 100MHz)
    // השעון יתהפך כל 5ns
    always #5 clk = ~clk;
    // -----------------------

    // 2. יצירת מופע של ה-ALU
    ALU_TTO uut (
        .clk(clk),
        .A(A), 
        .B(B), 
        .SEL(SEL), 
        .Y(Y)
    );

    // 3. תהליך הבדיקה
    initial begin
        // אתחול כניסות כדי למנוע ערכי X בהתחלה
        A = 0; B = 0; SEL = 0;

        // הדפסת כותרת לטרמינל
        $display("Starting Testbench for ALU_TTO...");
        $monitor("Time=%0t | SEL=%b | A=%d | B=%d | Y=%d", $time, SEL, A, B, Y);

        // ממתינים מעט להתייצבות
        #10;

        // --- בדיקת כל הפעולות לפי הסדר ---
        A = 8'd10; B = 8'd5; 
        
        #10 SEL = 4'b0000; // AND
        #10 SEL = 4'b0001; // OR
        #10 SEL = 4'b0010; // ADD
        #10 SEL = 4'b0011; // SUB
        
        #10 A = 8'b11001100; B = 8'b10101010;
        #10 SEL = 4'b0101; // NAND
        #10 SEL = 4'b0110; // XOR
        
        #10 A = 8'd16;
        #10 SEL = 4'b0111; // Shift Left
        #10 SEL = 4'b1000; // Shift Right

        #10 SEL = 4'b1111; // Default
        
        #50; // זמן נוסף לצפייה בתוצאות ב-Waveform
        $display("Testbench Completed.");
        $finish;
    end

endmodule