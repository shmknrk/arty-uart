`timescale 1ns/1ps

module m_uart_tx #(
    parameter WAIT_DIV = 1000
)(
    input  logic       CLK,  // clock (100 MHz)
    input  logic       RST,  // reset
    input  logic       VALID,
    input  logic [7:0] DIN,  // data in
    output logic       DOUT, // data out
    output logic       BUSY
);
    localparam WAIT_DIV_WIDTH = $clog2(WAIT_DIV + 1);

    typedef enum {
        STATE_IDLE,
        STATE_SND // send
    } statetype;
    statetype state = STATE_IDLE, n_state;

    logic [9:0]                  data     = '1, n_data;
    logic [WAIT_DIV_WIDTH - 1:0] wait_cnt = 0, n_wait_cnt;
    logic [3:0]                  bit_cnt  = 0, n_bit_cnt;

    assign DOUT = data[0];
    assign BUSY = (state != STATE_IDLE);

    always_comb begin
        n_state    = state;
        n_data     = data;
        n_wait_cnt = wait_cnt;
        n_bit_cnt  = bit_cnt;
        if (state == STATE_IDLE) begin
            if (VALID) begin
                n_state    = STATE_SND;
                n_data     = {1'b1, DIN, 1'b0};
                n_wait_cnt = 0;
                n_bit_cnt  = 0;
            end
        end else if (state == STATE_SND) begin
            if (wait_cnt == WAIT_DIV - 1) begin
                n_wait_cnt = 0;
                if (bit_cnt == 9) begin
                    n_state   = STATE_IDLE;
                    n_bit_cnt = 0;
                end else begin
                    n_data    = {1'b1, data[9:1]};
                    n_bit_cnt = bit_cnt + 1;
                end
            end else begin
                n_wait_cnt = wait_cnt + 1;
            end
        end
    end

    always_ff @ (posedge CLK or posedge RST) begin
        if (RST) begin
            state    <= STATE_IDLE;
            data     <= '1;
            wait_cnt <= 0;
            bit_cnt  <= 0;
        end else begin
            state    <= n_state;
            data     <= n_data;
            wait_cnt <= n_wait_cnt;
            bit_cnt  <= n_bit_cnt;
        end
    end
endmodule
