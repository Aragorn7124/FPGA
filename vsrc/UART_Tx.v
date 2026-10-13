module UART_Tx (
  input clk,
  input rst_n,
  input [7:0] tx_data,
  input tx_start,

  output reg tx_busy,
  output txd
);

// Baud rate arg def
  localparam CLK_FREQ = 50_000_000;
  localparam BAUD_RATE = 115200;
  localparam BAUD_CNT_MAX = CLK_FREQ / BAUD_RATE;

// BAUD_CNT impl
  reg [8:0] baud_cnt;
  always @(posedge clk or negedge rst_n) begin

    //br1: rst
      if(!rst_n) begin
        baud_cnt <= 9'd0;
      end

    //br2: when no busy rst
      else if(!tx_busy) begin
        baud_cnt <= 9'd0;
      end

    //br3: when become cnt MAX
      else if(baud_cnt == BAUD_CNT_MAX-1) begin
        baud_cnt <= 9'd0;
      end

    //br4: update
      else begin
        baud_cnt <= baud_cnt + 1;
      end

  end

// bit cnt impl
  reg [3:0] bit_cnt;
  always @(posedge clk or negedge rst_n) begin

    //br1: rst
      if(!rst_n) begin
        bit_cnt <= 4'd0;
      end

    //br2: when no busy rst
      else if(!tx_busy) begin
        bit_cnt <= 4'd0;
      end

    //br3: update
      else if(baud_cnt == BAUD_CNT_MAX-1 && bit_cnt < 4'd9) begin
        bit_cnt <= bit_cnt + 1'b1;
      end
  end

// tx_busy impl
  always @(posedge clk or negedge rst_n) begin
    //br1: rst
      if(!rst_n) begin
        tx_busy <= 1'b0;
      end

    //br2: when tx_start on and tx_busy = 0
      else if(tx_start && !tx_busy) begin
        tx_busy <= 1'b1;
      end

    //br3: when last bit and tx_busy = 1
      else if(tx_busy && bit_cnt == 4'd9 && baud_cnt == BAUD_CNT_MAX-1) begin
        tx_busy <= 1'b0;
      end
  end

//  tx_data latch
  reg [7:0] tx_data_latch;
  always @(posedge clk or negedge rst_n) begin

    //br1: rst
      if(!rst_n) begin
        tx_data_latch <= 8'd0;
      end

    //br2: when !tx_busy and tx_strat
      else if(!tx_busy && tx_start) begin
        tx_data_latch <= tx_data;
      end

  end

//txd output impl
  assign txd = (!tx_busy)? 1'b1 :
               (bit_cnt == 4'd0)? 1'b0 :
               (bit_cnt == 4'd9)? 1'b1 :
               tx_data_latch[bit_cnt-1];
endmodule
