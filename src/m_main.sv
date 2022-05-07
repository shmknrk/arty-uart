`timescale 1ns/1ps

module m_main # (
    parameter WAIT_DIV = 1000
)(
    input  logic CLK, // clock (100 MHz)
    input  logic RST, // reset
    output logic TXD  // transmit data
);
    logic [31:0] cnt    = 0, n_cnt; // count
    logic [9:0]  offset = 0, n_offset;

    always_comb begin
        n_cnt    = cnt;
        n_offset = offset;
        if (cnt == 0) begin
            if (offset == 12) begin
                n_offset = 0;
            end else begin
                n_offset = offset + 1;
            end
        end
        if (cnt == 99_999_999) begin
            n_cnt = 0;
        end else begin
            n_cnt = cnt + 1;
        end
    end

    always_ff @ (posedge CLK or posedge RST) begin
        if (RST) begin
            cnt    <= 0;
            offset <= 0;
        end else begin
            cnt    <= n_cnt;
            offset <= n_offset;
        end
    end

    logic [9:0] mem_raddr; // memory read address
    logic [7:0] mem_rdata; // memory read data
    logic       mem_we;    // memory write enable
    logic [9:0] mem_waddr; // memory write address
    logic [7:0] mem_wdata; // memory write data

    assign mem_raddr = offset;
    assign mem_we    = 0;
    assign mem_waddr = 0;
    assign mem_wdata = 0;

    m_memory memory (
        .CLK(CLK),
        .RST(RST),
        .RADDR(mem_raddr),
        .RDATA(mem_rdata),
        .WE(mem_we),
        .WADDR(mem_waddr),
        .WDATA(mem_wdata)
    );

    logic [7:0] uart_tx_din;   // uart transmit data in
    logic       uart_tx_valid; // uart transmit valid
    logic       uart_tx_busy;  // uart transmit transmit busy

    assign uart_tx_din   = mem_rdata;
    assign uart_tx_valid = (cnt == 0);

    m_uart_tx # (
    .WAIT_DIV(WAIT_DIV)
    )
    uart_tx (
        .CLK(CLK),
        .RST(RST),
        .VALID(uart_tx_valid),
        .DIN(uart_tx_din),
        .DOUT(TXD),
        .BUSY(uart_tx_busy)
    );
endmodule
