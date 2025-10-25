// OpenRAM SRAM model
// Words: 512
// Word size: 64
// Write size: 8

module sky130_sram_4kbyte_1rw1r_64x512_8(
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
// Write Port
    write_clk,write_csb,write_web,write_wmask,write_addr,write_data,write_dout,
// Read Port
    read_clk,read_csb,read_addr,read_data
  );

  parameter NUM_WMASKS = 8 ;
  parameter DATA_WIDTH = 64 ;
  parameter ADDR_WIDTH = 9 ;
  parameter RAM_DEPTH = 1 << ADDR_WIDTH;
  // FIXME: This delay is arbitrary.
  parameter DELAY = 3 ;
  parameter VERBOSE = 1 ; //Set to 0 to only display warnings
  parameter T_HOLD = 1 ; //Delay to hold dout value after posedge. Value is arbitrary

`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
  input  write_clk; // clock
  input   write_csb; // active low chip select
  input  write_web; // active low write control
  input [NUM_WMASKS-1:0]   write_wmask; // write mask
  input [ADDR_WIDTH-1:0]  write_addr;
  input [DATA_WIDTH-1:0]  write_data;
  output [DATA_WIDTH-1:0] write_dout;
  input  read_clk; // clock
  input   read_csb; // active low chip select
  input [ADDR_WIDTH-1:0]  read_addr;
  output [DATA_WIDTH-1:0] read_data;

  // Instantiate two 32-bit SRAM modules
  sky130_sram_2kbyte_1rw1r_32x512_8 sram0 (
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
    .clk0(write_clk),
    .csb0(write_csb),
    .web0(write_web),
    .wmask0(write_wmask[3:0]),
    .addr0(write_addr),
    .din0(write_data[31:0]),
    .dout0(write_dout[31:0]),
    .clk1(read_clk),
    .csb1(read_csb),
    .addr1(read_addr),
    .dout1(read_data[31:0])
  );

  sky130_sram_2kbyte_1rw1r_32x512_8 sram1 (
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
    .clk0(write_clk),
    .csb0(write_csb),
    .web0(write_web),
    .wmask0(write_wmask[7:4]),
    .addr0(write_addr),
    .din0(write_data[63:32]),
    .dout0(write_dout[63:32]),
    .clk1(read_clk),
    .csb1(read_csb),
    .addr1(read_addr),
    .dout1(read_data[63:32])
  );

endmodule
