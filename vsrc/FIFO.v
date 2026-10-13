module FIFO_Ctrl (
  input clk,
  input rst_n,
  input [7:0] din,
  input wr_en,
  input rd_en,

  output full,
  output empty,
  output reg overflow,
  output [7:0] dout
);

//FIFO arg def
  reg [7:0] mem [0:3];
  reg [1:0] wr_ptr;
  reg [1:0] rd_ptr;
  reg [2:0] cnt;

// Full and Empty eval
  assign full = (cnt == 3'd4);
  assign empty = (cnt == 3'd0);

//rd dout
  assign dout = empty? 8'd0 : mem[rd_ptr];

// wr impl
  always @(posedge clk or negedge rst_n) begin
    //br1: rst
      if(!rst_n) begin
        wr_ptr <= 2'd0;
      end

    //br2: move wr ptr
      else if(wr_en && !full) begin
        mem[wr_ptr] <= din;
        wr_ptr <= wr_ptr + 1'b1;
      end
  end

// rd impl
  always @(posedge clk or negedge rst_n) begin
    //br1: rst
      if(!rst_n) begin
        rd_ptr <= 2'd0;
      end

    //br2: move rd_ptr
      else if(rd_en && !empty) begin
        rd_ptr <= rd_ptr + 1'b1;
      end
  end

// keep cnt
  always @(posedge clk or negedge rst_n) begin
    //br1: rst
      if(!rst_n) begin
        cnt <= 3'd0;
      end

    //br2: when wr or rd happen
      else begin
        //{wr,rd}
          case({wr_en && !full, rd_en && !empty})
            2'b10: begin
              cnt <= cnt + 1'b1;
            end
            2'b01: begin
              cnt <= cnt - 1'b1;
            end
            default: begin
              cnt <= cnt;
            end
          endcase
      end
  end

// overflow impl
  always @(posedge clk or negedge rst_n) begin
    //br1: rst
      if(!rst_n) begin
        overflow <= 1'b0;
      end

    //br2: when FIFOmem is full and have wr en
      else begin
        overflow <= 1'b0;
        if(wr_en && full) begin
          overflow <= 1'b1;
        end
      end
  end

endmodule
