module Hello_Sender (
  input clk,
  input rst_n,
  input tx_busy,

  output reg tx_start,
  output reg [7:0] tx_data
);

// arg def
  localparam CLK_FREQ = 50_000_000;
  localparam CYCLE_1S_CNT_MAX = CLK_FREQ;
  localparam MSG_LEN = 13;

// 1s cnt impl
  reg [25:0] cnt_1s;
  wire tick_1s = (cnt_1s == CYCLE_1S_CNT_MAX - 1);
  always @(posedge clk or negedge rst_n) begin

    //br1: rst
      if(!rst_n) begin
        cnt_1s <= 26'd0;
      end

    //br2: when be come to 1s
      else if(tick_1s) begin
        cnt_1s <= 26'd0;
      end

    //br3: update
      else begin
        cnt_1s <= cnt_1s + 1'b1;
      end
  end

// Byte idx
  reg [3:0] byte_idx;

  //string Excel
    always @(*) begin
      case (byte_idx)
        4'd0 : tx_data = "H";
        4'd1 : tx_data = "e";
        4'd2 : tx_data = "l";
        4'd3 : tx_data = "l";
        4'd4 : tx_data = "o";
        4'd5 : tx_data = " ";
        4'd6 : tx_data = "W";
        4'd7 : tx_data = "o";
        4'd8 : tx_data = "r";
        4'd9 : tx_data = "l";
        4'd10 : tx_data = "d";
        4'd11 : tx_data = 8'h0D;
        4'd12 : tx_data = 8'h0A;
        default : tx_data = 8'h00;
      endcase
    end

//Edge Detection
  reg tx_busy_d;
  wire tx_busy_fall = tx_busy_d && !tx_busy;
  always @(posedge clk or negedge rst_n) begin

    //br1: rst
      if(!rst_n) begin
        tx_busy_d <= 1'b0;
      end

    //br2:
      else begin
        tx_busy_d <= tx_busy;
      end
  end

// main FSM : IDLE = 0 SENDING = 1;
  reg sending;
  always @(posedge clk or negedge rst_n) begin

    //br1: rst
      if(!rst_n) begin
        sending <= 1'b0;
        byte_idx <= 4'd0;
        tx_start <= 1'b0;
      end

    //br2: begin sending
      else begin
        tx_start <= 1'b0;

        if(!sending) begin
          //IDLE
            if(tick_1s && !tx_busy) begin
              sending <= 1'b1;
              byte_idx <= 4'd0;
              tx_start <= 1'b1;
            end
        end
        else begin
          //SENDING
            if(tx_busy_fall) begin
              if(byte_idx == MSG_LEN - 1) begin
                sending <= 1'b0;
              end
              else begin
                byte_idx <= byte_idx + 1'b1;
                tx_start <= 1'b1;
              end
            end
        end
      end
  end
endmodule
