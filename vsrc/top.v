/*module top (
  input clk,
  input rst_n,

  output uart_txd
);

// wire var
  wire tx_busy;
  wire [7:0] tx_data;
  wire tx_start;


//module
  Hello_Sender u_Hello_Sender (
    .clk(clk),
    .rst_n(rst_n),
    .tx_busy(tx_busy),

    .tx_data(tx_data),
    .tx_start(tx_start)
  );

  UART_Tx u_UART_Txd (
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .tx_data(tx_data),

    .tx_busy(tx_busy),
    .txd(uart_txd)
  );

endmodule
*/

module top (
  input clk,
  input rst_n,
  input uart_rxd,

  output uart_txd
);

// wire var
  wire [7:0] rx_data;
  wire rx_done;

  wire [7:0] tx_data;
  wire tx_start;
  wire tx_busy;

//module
  UART_Rx u_UART_Rx (
    .clk(clk),
    .rst_n(rst_n),
    .rxd(uart_rxd),

    .rx_data(rx_data),
    .rx_done(rx_done)
  );

  UART_Tx u_UART_Tx (
    .clk(clk),
    .rst_n(rst_n),
    .tx_data(tx_data),
    .tx_start(tx_start),

    .txd(uart_txd),
    .tx_busy(tx_busy)
  );

  Echo_Ctrl u_Echo_Ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .tx_busy(tx_busy),

    .tx_data(tx_data),
    .tx_start(tx_start)
  );

endmodule
