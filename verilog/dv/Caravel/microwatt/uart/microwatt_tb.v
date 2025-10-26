`default_nettype none
`timescale 1 ns / 1 ps

module microwatt_tb;
	reg ext_clk;
	reg ext_rst;
	wire uart0_txd;
	reg uart0_rxd;
	wire spi_flash_cs_n;
	wire spi_flash_clk;
	wire spi_flash_sdat_o;
	reg spi_flash_sdat_i;
	wire spi_flash_sdat_oe;
	wire [31:0] gpio_out;
	wire [31:0] gpio_dir;
	reg [31:0] gpio_in;
	wire jtag_tdo;
	reg jtag_tck;
	reg jtag_tdi;
	reg jtag_tms;
	reg jtag_trst;

	// Clock
	always #5 ext_clk = (ext_clk === 1'b0);

	// Reset
	initial begin
		ext_clk = 0;
		ext_rst = 1; // Active high reset
		#10;
		ext_rst = 0;
	end

	// Instantiate microwatt_wrapper
	microwatt_wrapper uut (
		.ext_clk(ext_clk),
		.ext_rst(ext_rst),
		.uart0_rxd(uart0_rxd),
		.uart0_txd(uart0_txd),
		.spi_flash_cs_n(spi_flash_cs_n),
		.spi_flash_clk(spi_flash_clk),
		.spi_flash_sdat_o(spi_flash_sdat_o),
		.spi_flash_sdat_i(spi_flash_sdat_i),
		.spi_flash_sdat_oe(spi_flash_sdat_oe),
		.gpio_in(gpio_in),
		.gpio_out(gpio_out),
		.gpio_dir(gpio_dir),
		.jtag_tck(jtag_tck),
		.jtag_tdi(jtag_tdi),
		.jtag_tms(jtag_tms),
		.jtag_trst(jtag_trst),
		.jtag_tdo(jtag_tdo)
	);

	// Test
	initial begin
		$dumpfile("microwatt_tb.vcd");
		$dumpvars(0, microwatt_tb);

		gpio_in = 32'b0;
		uart0_rxd = 1'b1;
		jtag_tck = 1'b0;
		jtag_tdi = 1'b0;
		jtag_tms = 1'b0;
		jtag_trst = 1'b1;
		spi_flash_sdat_i = 1'b0;

		#100000; // Wait for execution

		$display("gpio_out = %h", gpio_out);
		if (gpio_out == 32'h12345678) begin
			$display("Test PASSED: Microwatt core is working");
		end else begin
			$display("Test FAILED: gpio_out is %h, expected 12345678", gpio_out);
		end

		$finish;
	end

endmodule
`default_nettype wire
