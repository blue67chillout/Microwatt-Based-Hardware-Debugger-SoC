// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * openframe_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user openframe project.
 *
 * Written by Tim Edwards
 * March 27, 2023
 * Efabless Corporation
 *
 *-------------------------------------------------------------
 */

module openframe_project_wrapper (
`ifdef USE_POWER_PINS
    inout vdda,		// User area 0 3.3V supply
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa,		// User area 0 analog ground
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd,		// Common 1.8V supply
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd,		// Common digital ground
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
    inout vddio,	// Common 3.3V ESD supply
    inout vssio,	// Common ESD ground
`endif

    /* Signals exported from the frame area to the user project */
    /* The user may elect to use any of these inputs.		*/

    input	 porb_h,	// power-on reset, sense inverted, 3.3V domain
    input	 porb_l,	// power-on reset, sense inverted, 1.8V domain
    input	 por_l,		// power-on reset, noninverted, 1.8V domain
    input	 resetb_h,	// master reset, sense inverted, 3.3V domain
    input	 resetb_l,	// master reset, sense inverted, 1.8V domain
    input [31:0] mask_rev,	// 32-bit user ID, 1.8V domain

    /* GPIOs.  There are 44 GPIOs (19 left, 19 right, 6 bottom). */
    /* These must be configured appropriately by the user project. */

    /* Basic bidirectional I/O.  Input gpio_in_h is in the 3.3V domain;  all
     * others are in the 1.8v domain.  OEB is output enable, sense inverted.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_in_h,
    output [`OPENFRAME_IO_PADS-1:0] gpio_out,
    output [`OPENFRAME_IO_PADS-1:0] gpio_oeb,
    output [`OPENFRAME_IO_PADS-1:0] gpio_inp_dis,	// a.k.a. ieb

    /* Pad configuration.  These signals are usually static values.
     * See the documentation for the sky130_fd_io__gpiov2 cell signals
     * and their use.
     */
    output [`OPENFRAME_IO_PADS-1:0] gpio_ib_mode_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_vtrip_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_slow_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_holdover,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_en,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_sel,
    output [`OPENFRAME_IO_PADS-1:0] gpio_analog_pol,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm2,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm1,
    output [`OPENFRAME_IO_PADS-1:0] gpio_dm0,

    /* These signals correct directly to the pad.  Pads using analog I/O
     * connections should keep the digital input and output buffers turned
     * off.  Both signals connect to the same pad.  The "noesd" signal
     * is a direct connection to the pad;  the other signal connects through
     * a series resistor which gives it minimal ESD protection.  Both signals
     * have basic over- and under-voltage protection at the pad.  These
     * signals may be expected to attenuate heavily above 50MHz.
     */
    inout  [`OPENFRAME_IO_PADS-1:0] analog_io,
    inout  [`OPENFRAME_IO_PADS-1:0] analog_noesd_io,

    /* These signals are constant one and zero in the 1.8V domain, one for
     * each GPIO pad, and can be looped back to the control signals on the
     * same GPIO pad to set a static configuration at power-up.
     */
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_one,
    input  [`OPENFRAME_IO_PADS-1:0] gpio_loopback_zero
);

    wire [31:0] microwatt_gpio_dir;
    wire [31:0] microwatt_gpio_out;
    wire [3:0] spi_flash_sdat_oe;
    wire [3:0] spi_flash_sdat_o;
    wire [3:0] spi_flash_sdat_i;

    assign spi_flash_sdat_i[0] = 0;
    assign spi_flash_sdat_i[2] = 0;
    assign spi_flash_sdat_i[3] = 0;
    assign gpio_out[6] = spi_flash_sdat_o[0];
    assign spi_flash_sdat_i[1] = gpio_in[7];


	microwatt_wrapper mprj (
`ifdef USE_POWER_PINS
    .vccd1(vccd1),
    .vssd1(vssd1),
`endif
 		.ext_clk(gpio_in[38]),
 		.ext_rst(gpio_in[39]),
		.alt_reset(gpio_in[40]),
 		.uart0_rxd(gpio_in[41]),
 		.uart0_txd(gpio_out[42]),
 		.jtag_tck(gpio_in[0]),
 		.jtag_tdi(gpio_in[2]),
 		.jtag_tms(gpio_in[1]),
 		.jtag_trst(gpio_in[43]),
 		.jtag_tdo(gpio_out[3]),
 		.spi_flash_sdat_i(spi_flash_sdat_i),
 		.spi_flash_sdat_o(spi_flash_sdat_o),
 		.spi_flash_sdat_oe(spi_flash_sdat_oe),
 		.spi_flash_cs_n(gpio_out[4]),
 		.spi_flash_clk(gpio_out[5]),
 		.gpio_in({2'b0, gpio_in[37:24],gpio_in[23:14],gpio_in[13:8]}),
 		.gpio_out(microwatt_gpio_out),
 		.gpio_dir(microwatt_gpio_dir)
 	);

 	// Assign microwatt outputs to GPIOs
 	assign {gpio_out[37:24],gpio_out[23:14],gpio_out[13:8]} = microwatt_gpio_out[29:0];

	wire unusedx ;
 	// Upper GPIOs tied off
       assign unusedx = microwatt_gpio_dir[31] & microwatt_gpio_dir[30] & 1'b0 ;     


 	// Set gpio_oeb for GPIOs used by microwatt
 	assign {gpio_oeb[37:24],gpio_oeb[23:14],gpio_oeb[13:8]}  = ~microwatt_gpio_dir[29:0];

 	// Set gpio_oeb for fixed-direction GPIOs
	
 	assign gpio_oeb[38] = 1'b1; // ext_clk input
 	assign gpio_oeb[39] = 1'b1; // ext_rst input
 	assign gpio_oeb[41] = 1'b1; // uart0_rxd input
 	assign gpio_oeb[40] = 1'b1; // alt_reset input
 	assign gpio_oeb[0] = 1'b1; // jtag_tck input
 	assign gpio_oeb[2] = 1'b1; // jtag_tdi input
 	assign gpio_oeb[1] = 1'b1; // jtag_tms input
 	assign gpio_oeb[43] = 1'b1; // jtag_trst input
 	assign gpio_oeb[4] = 1'b0; // spi_flash_cs_n output
 	assign gpio_oeb[5] = 1'b0; // spi_flash_clk output
 	assign gpio_oeb[42] = 1'b0; // uart0_txd output
 	assign gpio_oeb[3] = 1'b0; // jtag_tdo output
        assign gpio_oeb[7:6] = ~spi_flash_sdat_oe[1:0];


        assign gpio_out[7]  = 1'b0 ;
        assign gpio_out[0]  = 1'b0;
        assign gpio_out[1]  = 1'b0;
        assign gpio_out[2]  = 1'b0;
        assign gpio_out[38] = 1'b0;
        assign gpio_out[39] = 1'b0;
        assign gpio_out[40] = 1'b0;
        assign gpio_out[41] = 1'b0;
        assign gpio_out[43] = 1'b0;
        assign gpio_ib_mode_sel = gpio_loopback_zero;
 	assign gpio_vtrip_sel = gpio_loopback_zero;
 	assign gpio_slow_sel = gpio_loopback_zero;
 	assign gpio_dm2 = gpio_loopback_zero;
 	assign gpio_dm1 = gpio_loopback_zero;
 	assign gpio_dm0 = gpio_loopback_zero;
 	assign gpio_inp_dis = gpio_loopback_zero;

	assign gpio_analog_en = gpio_loopback_zero;
	assign gpio_analog_pol = gpio_loopback_zero;
	assign gpio_analog_sel = gpio_loopback_zero;
	assign gpio_holdover = gpio_loopback_zero;

	(* keep *) vccd1_connection vccd1_connection ();
	(* keep *) vssd1_connection vssd1_connection ();

endmodule	// openframe_project_wrapper
