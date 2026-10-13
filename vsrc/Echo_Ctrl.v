module Echo_Ctrl (
  input clk,
  input rst_n,
  input [7:0] rx_data,
  input rx_done,
  input tx_busy,

  output reg [7:0] tx_data,
  output reg tx_start
);

// Forward data
  always @(posedge clk or negedge rst_n) begin
    //br1: rst
      if(!rst_n) begin
        tx_data <= 8'd0;
        tx_start <= 1'b0;
      end

    //br2: forward
      else begin
        tx_start <= 1'b0;
        if(!tx_busy && rx_done) begin
          tx_data <= rx_data;
          tx_start <= 1'b1;
        end
      end
  end

endmodule
