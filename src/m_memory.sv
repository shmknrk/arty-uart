`timescale 1ns/1ps

module m_memory (
    input  logic       CLK,   // clock (100 MHz)
    input  logic       RST,   // reset
    input  logic [9:0] RADDR, // read address
    output logic [7:0] RDATA, // read data
    input  logic       WE,    // write enable
    input  logic [9:0] WADDR, // write address
    input  logic [7:0] WDATA  // write data
);
    logic [7:0] ram [1023:0]; // random access memory

    initial begin
        for (int i = 0; i < 1024; i = i + 1) begin
            ram[i] = 0;
        end
        ram[0]  = 8'h48; // H
        ram[1]  = 8'h65; // e
        ram[2]  = 8'h6c; // l
        ram[3]  = 8'h6c; // l
        ram[4]  = 8'h6f; // o
        ram[5]  = 8'h2c; // ,
        ram[6]  = 8'h20; // space
        ram[7]  = 8'h55; // U
        ram[8]  = 8'h41; // A
        ram[9]  = 8'h52; // R
        ram[10] = 8'h54; // T
        ram[11] = 8'h0d; // CR, \r
        ram[12] = 8'h0a; // LF, \n
    end

    assign RDATA = ram[RADDR];

    always_ff @(posedge CLK or posedge RST) begin
        if (RST) begin
            for (int i = 0; i < 1024; i = i + 1) begin
                ram[i] <= 0;
            end
        end else begin
            if (WE) begin
                ram[WADDR] <= WDATA;
            end
        end
    end
endmodule
