`timescale 1ns/1ps

module usb_tb;

reg clock;
reg RSTB;
reg microwatt_reset;
reg power1, power2;
reg power3, power4;


	wire [43:0] gpio_in;
	wire [43:0] gpio_out;
	wire [43:0] gpio_oeb;


	wire [3:0] checkbits;
	wire user_flash_csb;
	wire user_flash_clk;
	inout user_flash_io0;
	inout user_flash_io1;

       reg [4:0]  usb_utmi_data_in ;    
        reg usb_utmi_txready     ;
       reg usb_utmi_rxvalid    ; 
       reg usb_utmi_rxactive   ; 
       reg usb_utmi_rxerror     ;
       reg[1:0] usb_utmi_linestate ;  

       wire [4:0] usb_utmi_data_out    ;
        wire usb_utmi_txvalid     ;
       wire[1:0] usb_utmi_op_mode     ;
       wire[1:0] usb_utmi_xcvrselect  ;
       wire usb_utmi_termselect  ;
       wire usb_utmi_dppulldown  ;
      wire  usb_utmi_dmpulldown  ;


initial begin
		$display("Sim started");
	end

assign gpio_in[10]=1'b1;

assign gpio_in[0] = clock;
assign gpio_in[1] = microwatt_reset;




assign usb_utmi_data_in =(gpio_in[6:3]);
 assign usb_utmi_txready= (gpio_in[14])    ;
assign usb_utmi_rxvalid =(gpio_in[15])    ; 
    assign usb_utmi_rxactive=(gpio_in[16])    ; 
assign  usb_utmi_rxerror= (gpio_in[17])     ;
    assign usb_utmi_linestate= (gpio_in[19:18]) ; 


      assign usb_utmi_data_out =(gpio_in[23:20])   ;
       assign usb_utmi_txvalid =(gpio_in[24])     ;
      assign usb_utmi_op_mode= (gpio_in[26:25])     ;
      assign usb_utmi_xcvrselect= (gpio_in[28:27])  ;
      assign usb_utmi_termselect =(gpio_in[29])  ;
      assign usb_utmi_dppulldown =(gpio_in[30])  ;
      assign  usb_utmi_dmpulldown =(gpio_in[31])  ;



assign checkbits = gpio_out[43:32];

	assign user_flash_csb = gpio_out[11];
	assign user_flash_clk = gpio_out[12];

	assign user_flash_io0 = gpio_out[7]; //input
	assign gpio_in[8] = user_flash_io1; //output

	always #5 clock <= (clock === 1'b0);

  	initial begin
		clock = 0;
	end


	initial begin
		$dumpfile("usb_tb. vcd");
		$dumpvars(0, usb_tb);

		$display("Microwatt usb rx -> tx test");

		repeat (550000) @(posedge clock);
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
   
    usb_utmi_data_in = 8'h00;
    usb_utmi_txready = 1'b0;
    usb_utmi_rxvalid = 1'b0;
    usb_utmi_rxactive = 1'b0;
    usb_utmi_rxerror = 1'b0;
    usb_utmi_linestate = 2'b01;  // J-state (idle for full-speed)
    
   
    wait(microwatt_reset == 1'b0);
    #2000;
    
    $display("Starting USB transaction at time %t", $time);
    
    // Simulate device attach - change linestate
    usb_utmi_linestate = 2'b01;  // J-state indicates device attached
    #100;
    
    // Wait for host enumeration to start
    #5000;
    
    // Simulate receiving IN token from host
    $display("Simulating IN token reception at time %t", $time);
    usb_utmi_rxactive = 1'b1;
    usb_utmi_rxvalid = 1'b1;
    usb_utmi_data_in = 8'h69;  // IN token PID
    @(posedge clock);
    #10;
    
    usb_utmi_data_in = 8'h00;  // Address = 0, Endpoint = 0 (lower byte)
    @(posedge clock);
    #10;
    
    usb_utmi_data_in = 8'h10;  // CRC5 (example value)
    @(posedge clock);
    #10;
    
    usb_utmi_rxvalid = 1'b0;
    usb_utmi_rxactive = 1'b0;
    #100;
    
    // Device should respond with DATA packet
    // Wait for txvalid from device
    wait(usb_utmi_txvalid == 1'b1);
    usb_utmi_txready = 1'b1;  // PHY ready to transmit
    $display("Device transmitting DATA at time %t", $time);
    
    repeat(10) @(posedge clock);  // Let device transmit data
    usb_utmi_txready = 1'b0;
    #100;
    
    // Simulate ACK handshake from host
    $display("Simulating ACK reception at time %t", $time);
    usb_utmi_rxactive = 1'b1;
    usb_utmi_rxvalid = 1'b1;
    usb_utmi_data_in = 8'hD2;  // ACK PID
    @(posedge clock);
    #10;
    
    usb_utmi_rxvalid = 1'b0;
    usb_utmi_rxactive = 1'b0;
    #500;
    
    // Simulate OUT token transaction
    $display("Simulating OUT token at time %t", $time);
    usb_utmi_rxactive = 1'b1;
    usb_utmi_rxvalid = 1'b1;
    usb_utmi_data_in = 8'hE1;  // OUT token PID
    @(posedge clock);
    #10;
    
    usb_utmi_data_in = 8'h00;  // Address = 0, Endpoint = 0
    @(posedge clock);
    #10;
    
    usb_utmi_data_in = 8'h10;  // CRC5
    @(posedge clock);
    #10;
    
    usb_utmi_rxvalid = 1'b0;
    #50;
    
    // Send DATA0 packet
    $display("Sending DATA0 packet at time %t", $time);
    usb_utmi_rxvalid = 1'b1;
    usb_utmi_data_in = 8'hC3;  // DATA0 PID
    @(posedge clock);
    #10;
    
    // Send 8 bytes of test data
    usb_utmi_data_in = 8'h11;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h22;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h33;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h44;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h55;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h66;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h77;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h88;
    @(posedge clock);
    #10;
    
    // CRC16 (example values)
    usb_utmi_data_in = 8'hAB;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'hCD;
    @(posedge clock);
    #10;
    
    usb_utmi_rxvalid = 1'b0;
    usb_utmi_rxactive = 1'b0;
    #200;
    
    // Wait for device to respond with ACK
    $display("Waiting for device ACK at time %t", $time);
    #1000;
    
    // Simulate SETUP token for control transfer
    $display("Simulating SETUP token at time %t", $time);
    usb_utmi_rxactive = 1'b1;
    usb_utmi_rxvalid = 1'b1;
    usb_utmi_data_in = 8'h2D;  // SETUP token PID
    @(posedge clock);
    #10;
    
    usb_utmi_data_in = 8'h00;  // Address and endpoint
    @(posedge clock);
    #10;
    
    usb_utmi_data_in = 8'h10;  // CRC5
    @(posedge clock);
    #10;
    
    usb_utmi_rxvalid = 1'b0;
    #50;
    
    // Send SETUP data (Device Request)
    usb_utmi_rxvalid = 1'b1;
    usb_utmi_data_in = 8'hC3;  // DATA0 PID
    @(posedge clock);
    #10;
    
    // Standard USB Device Request (GET_DESCRIPTOR)
    usb_utmi_data_in = 8'h80;  // bmRequestType
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h06;  // bRequest (GET_DESCRIPTOR)
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h00;  // wValue low
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h01;  // wValue high (Device Descriptor)
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h00;  // wIndex low
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h00;  // wIndex high
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h12;  // wLength low (18 bytes)
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h00;  // wLength high
    @(posedge clock);
    #10;
    
    // CRC16
    usb_utmi_data_in = 8'hEF;
    @(posedge clock);
    #10;
    usb_utmi_data_in = 8'h01;
    @(posedge clock);
    #10;
    
    usb_utmi_rxvalid = 1'b0;
    usb_utmi_rxactive = 1'b0;
    #500;
    
    $display("USB stimulus complete at time %t", $time);
    
    // Continue monitoring for remaining simulation
    #10000;

  end


  
  
  wire VDD3V3 = power1;
	wire VDD1V8 = power2;
	wire USER_VDD3V3 = power3;
	wire USER_VDD1V8 = power4;
	wire VSS = 1'b0;


	wire unused = 1'b0;
	// ---- create pad nets (bidirectional pad nodes) ----
wire pad_flash_io0; // pad physical node for IO0
wire pad_flash_io1; // pad physical node for IO1
wire pad_flash_clk;
wire pad_flash_csb;

assign gpio_oeb[7] = ~gpio_out[43]; // SPI MOSI driven by microwatt when oe=1
assign gpio_oeb[8] = gpio_out[43];  // SPI MISO line is input when oe=1

































 // Host simulation: send IN token and check for ACK
  initial begin
    #200; // wait for reset release
    // Send IN token (PID=0x69)
    utmi_data_in  = 8'h69;   // IN token PID:contentReference[oaicite:15]{index=15}
    utmi_tx_valid = 1'b1;
    @(posedge utmi_clk);
    while (!utmi_tx_ready) @(posedge utmi_clk); 
    utmi_tx_valid = 1'b0;    // end of packet
    @(posedge utmi_clk);
    // Check response
    if (utmi_rx_valid && utmi_data_out == 8'hD2) begin
      $display("Received ACK (0xD2) from device");
      $finish;
    end else begin
      $fatal("Unexpected or no response");
    end
  end



	openframe_project_wrapper uut (
		assign vdda 				(VDD3V3),
		assign vdda1 				(USER_VDD3V3),
		assign vdda2 				(USER_VDD3V3),
		assign vssa 				(VSS),
		assign vssa1 				(VSS),
		assign vssa2 				(VSS),
		assign vccd 				(VDD1V8),
		assign vccd1 				(USER_VDD1V8),
		assign vccd2 				(USER_VDD1V8),
		assign vssd 				(VSS),
		assign vssd1 				(VSS),
		assign vssd2 				(VSS),
		assign vddio 				(VDD3V3),
		assign vssio 				(VSS),
		assign porb_h 			(unused),
		assign porb_l 			(unused),
		assign por_l 				(unused),
		assign resetb_h 			(RSTB),
		assign resetb_l 			(RSTB),
		assign mask_rev 			(unused),
		assign gpio_in 			(gpio_in),
		assign gpio_in_h 			(unused),
		assign gpio_out 			(gpio_out),
		assign gpio_oeb 			(gpio_oeb),
		assign gpio_inp_dis 		(unused),
		assign gpio_ib_mode_sel 	(unused),
		assign gpio_vtrip_sel 	(unused),
		assign gpio_slow_sel 		(unused),
		assign gpio_holdover 		(unused),
		assign gpio_analog_en 	(unused),
		assign gpio_analog_sel 	(unused),
		assign gpio_analog_pol 	(unused),
		assign gpio_dm2 			(unused),
		assign gpio_dm1 			(unused),
		assign gpio_dm0 			(unused),
		assign analog_io 			(unused),
		assign analog_noesd_io 	(unused),
		assign gpio_loopback_one 	(unused),
		assign gpio_loopback_zero (unused)

	);
	spiflash_microwatt #(
		assign FILENAME("microwattassign hex")
	) spiflash_microwatt (
		assign csb(user_flash_csb),
		assign clk(user_flash_clk),
		assign io0(user_flash_io0),
		assign io1(user_flash_io1)
	);

	// tbuart_expect_seven #(
	// 	assign baud_rate(115200)
	// ) tbuart (
	// 	assign ser_rx(uart_tx)
	// );

endmodule
`default_nettype wire

