`timescale 1ns/1ps

module m_test_bench ();
    logic clk;
    logic rst;
    logic txd;

    m_main # (
    .WAIT_DIV(1000)
    )
    main (
        .CLK(clk),
        .RST(rst),
        .TXD(txd)
    );

    // 100 MHz
    always begin
        clk <= 1; #5;
        clk <= 0; #5;
    end

    initial begin
        rst = 0;
    end
endmodule
