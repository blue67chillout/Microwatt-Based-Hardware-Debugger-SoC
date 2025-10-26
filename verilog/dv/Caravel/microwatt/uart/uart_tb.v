`default_nettype none
/*
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *  Copyright (C) 2018  Tim Edwards <tim@efabless.com>
 *  Copyright (C) 2020  Anton Blanchard <anton@linux.ibm.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1 ns / 1 ps

module tbuart_expect_seven # (
	parameter baud_rate = 115200
) (
	input ser_rx
);
	reg [3:0] recv_state;
	reg [2:0] recv_divcnt;
	reg [7:0] recv_pattern;

	reg clk;

	initial begin
		clk <= 1'b0;
		recv_state <= 0;
		recv_divcnt <= 0;
		recv_pattern <= 0;
	end

	// Our simulation is in nanosecond steps and we want 5 clocks per bit,
	// ie 10 clock transitions
	always #(1000000000/baud_rate/10) clk <= (clk === 1'b0);

	always @(posedge clk) begin
		recv_divcnt <= recv_divcnt + 1;
		case (recv_state)
			0: begin
				if (!ser_rx)
					recv_state <= 1;
				recv_divcnt <= 0;
			end
			1: begin
				if (2*recv_divcnt > 3'd3) begin
					recv_state <= 2;
					recv_divcnt <= 0;
				end
			end
			10: begin
				if (recv_divcnt > 3'd3) begin
					recv_state <= 0;
					$display("Got %c from Microwatt", recv_pattern);
					// Expecting 7 back
					if (recv_pattern == 55) begin
						$finish;
					end else begin
						$fatal;
					end
				end
			end
			default: begin
				if (recv_divcnt > 3'd3) begin
					recv_pattern <= {ser_rx, recv_pattern[7:1]};
					recv_state <= recv_state + 1;
					recv_divcnt <= 0;
				end
			end
		endcase
	end
endmodule

module uart_tb;
	reg clock;
	reg RSTB;
	reg microwatt_reset;
	reg power1, power2;
	reg power3, power4;
	reg uart_rx;

	//wire gpio;
	//wire [37:0] mprj_io;

	wire [43:0] gpio_in;
	wire [43:0] gpio_out;
	wire [43:0] gpio_oeb;


	wire [15:0] checkbits;
	wire user_flash_csb;
	wire user_flash_clk;
	inout user_flash_io0;
	inout user_flash_io1;
	wire uart_tx;

	initial begin
		$display("Sim started");
	end

	// assign mprj_io[7] = microwatt_reset;
 //
	// assign mprj_io[35] = 1'b1; // Boot from flash
 //
	// assign user_flash_csb = mprj_io[8];
	// assign user_flash_clk = mprj_io[9];
	// assign user_flash_io0 = mprj_io[10];
	// assign mprj_io[11] = user_flash_io1;
 //
	// assign checkbits = mprj_io[31:16];
 //
	// assign uart_tx = mprj_io[6];
	// assign mprj_io[5] = uart_rx;
 //
	// assign mprj_io[3] = 1'b1;  // Force CSB high.

	assign gpio_in[0] = clock;
	assign gpio_in[1] = microwatt_reset;

	assign gpio_in[2] = uart_rx;
	assign uart_tx = gpio_out[13];

	assign checkbits = gpio_out[30:15];

	assign user_flash_csb = gpio_out[11];
	assign user_flash_clk = gpio_out[12];

	assign user_flash_io0 = gpio_in[8]; //input
	assign gpio_in[7] = user_flash_io1; //output


	// 100 MHz clock
	always #5 clock <= (clock === 1'b0);

	initial begin
		clock = 0;
	end

	initial begin
		$dumpfile("uart_tb.vcd");
		$dumpvars(0, uart_tb);

		$display("Microwatt UART rx -> tx test");

		repeat (1500000) @(posedge clock);
		$finish;
	end

	initial begin
		RSTB <= 1'b0;
		microwatt_reset <= 1'b1;
		#1000;
		microwatt_reset <= 1'b0;
		// Note: keep management engine in reset
		//RSTB <= 1'b1;
	end

	initial begin		// Power-up sequence
		power1 <= 1'b0;
		power2 <= 1'b0;
		power3 <= 1'b0;
		power4 <= 1'b0;
		#100;
		power1 <= 1'b1;
		#100;
		power2 <= 1'b1;
		#100;
		power3 <= 1'b1;
		#100;
		power4 <= 1'b1;
	end

	initial begin
		uart_rx <= 1'b1;

		wait(checkbits == 16'h0ffe)
		$display("Microwatt alive!");

		// 115200 = 8680 ns per bit
		$display("Writing 7 to Microwatt uart");
		uart_rx <= 1'b0;
		#8680
		uart_rx <= 1'b1;
		#8680
		uart_rx <= 1'b1;
		#8680
		uart_rx <= 1'b1;
		#8680
		uart_rx <= 1'b0;
		#8680
		uart_rx <= 1'b1;
		#8680
		uart_rx <= 1'b1;
		#8680
		uart_rx <= 1'b0;
		#8680
		uart_rx <= 1'b0;
		#8680
		$display("Done. Waiting for Microwatt to send 7 back");
		uart_rx <= 1'b1;
	end

	wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;

	wire unused = 1'b0;

	// wire dummy = (gpio_inp_dis & 1'b0) |
	// 				(gpio_ib_mode_sel & 1'b0) |
	// 				(gpio_vtrip_sel & 1'b0) |
	// 				(gpio_slow_sel & 1'b0) |
	// 				(gpio_holdover & 1'b0) |
	// 				(gpio_analog_en & 1'b0) |
	// 				(gpio_analog_sel & 1'b0) |
	// 				()


	// caravel uut (
	// 	.vddio	  (VDD3V3),
	// 	.vssio	  (VSS),
	// 	.vdda	  (VDD3V3),
	// 	.vssa	  (VSS),
	// 	.vccd	  (VDD1V8),
	// 	.vssd	  (VSS),
	// 	.vdda1    (USER_VDD3V3),
	// 	.vdda2    (USER_VDD3V3),
	// 	.vssa1	  (VSS),
	// 	.vssa2	  (VSS),
	// 	.vccd1	  (USER_VDD1V8),
	// 	.vccd2	  (USER_VDD1V8),
	// 	.vssd1	  (VSS),
	// 	.vssd2	  (VSS),
	// 	.clock	  (clock),
	// 	.gpio     (gpio),
	// 	.mprj_io  (mprj_io),
	// 	.resetb	  (RSTB)
	// );

	openframe_project_wrapper uut (
		.vdda 				(VDD3V3),
		.vdda1 				(USER_VDD3V3),
		.vdda2 				(USER_VDD3V3),
		.vssa 				(VSS),
		.vssa1 				(VSS),
		.vssa2 				(VSS),
		.vccd 				(VDD1V8),
		.vccd1 				(USER_VDD1V8),
		.vccd2 				(USER_VDD1V8),
		.vssd 				(VSS),
		.vssd1 				(VSS),
		.vssd2 				(VSS),
		.vddio 				(VDD3V3),
		.vssio 				(VSS),
		.porb_h 			(unused),
		.porb_l 			(unused),
		.por_l 				(unused),
		.resetb_h 			(unused),
		.resetb_l 			(unused),
		.mask_rev 			(unused),
		.gpio_in 			(gpio_in),
		.gpio_in_h 			(unused),
		.gpio_out 			(gpio_out),
		.gpio_oeb 			(gpio_oeb),
		.gpio_inp_dis 		(unused),
		.gpio_ib_mode_sel 	(unused),
		.gpio_vtrip_sel 	(unused),
		.gpio_slow_sel 		(unused),
		.gpio_holdover 		(unused),
		.gpio_analog_en 	(unused),
		.gpio_analog_sel 	(unused),
		.gpio_analog_pol 	(unused),
		.gpio_dm2 			(unused),
		.gpio_dm1 			(unused),
		.gpio_dm0 			(unused),
		.analog_io 			(unused),
		.analog_noesd_io 	(unused),
		.gpio_loopback_one 	(unused),
		.gpio_loopback_zero (unused)

	);

	spiflash_microwatt #(
		.FILENAME("microwatt.hex")
	) spiflash_microwatt (
		.csb(user_flash_csb),
		.clk(user_flash_clk),
		.io0(user_flash_io0),
		.io1(user_flash_io1)
	);

	tbuart_expect_seven #(
		.baud_rate(115200)
	) tbuart (
		.ser_rx(uart_tx)
	);

endmodule
`default_nettype wire
