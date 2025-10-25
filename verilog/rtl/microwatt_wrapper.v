module microwatt_wrapper(
    input ext_clk,
    input ext_rst,
    input uart0_rxd,
    input [3:0] spi_flash_sdat_i,
    input [31:0] gpio_in,
    input jtag_tck,
    input jtag_tdi,
    input jtag_tms,
    input jtag_trst,
    output uart0_txd,
    output spi_flash_cs_n,
    output spi_flash_clk,
    output [3:0] spi_flash_sdat_o,
    output [3:0] spi_flash_sdat_oe,
    output [31:0] gpio_out,
    output [31:0] gpio_dir,
    output jtag_tdo
);

    wire uart1_txd_dummy;
    wire sw_soc_reset_dummy;
    wire run_out_dummy;
    wire run_outs_dummy;
    wire [28:0] wb_dram_in_adr_dummy;
    wire wb_dram_in_cyc_dummy;
    wire [63:0] wb_dram_in_dat_dummy;
    wire [7:0] wb_dram_in_sel_dummy;
    wire wb_dram_in_stb_dummy;
    wire wb_dram_in_we_dummy;
    wire [29:0] wb_ext_io_in_adr_dummy;
    wire wb_ext_io_in_cyc_dummy;
    wire [31:0] wb_ext_io_in_dat_dummy;
    wire [3:0] wb_ext_io_in_sel_dummy;
    wire wb_ext_io_in_stb_dummy;
    wire wb_ext_io_in_we_dummy;
    wire wb_ext_is_dram_csr_dummy;
    wire wb_ext_is_dram_init_dummy;
    wire wb_ext_is_eth_dummy;
    wire wb_ext_is_sdcard_dummy;
    wire wishbone_dma_in_ack_dummy;
    wire [31:0] wishbone_dma_in_dat_dummy;
    wire wishbone_dma_in_stall_dummy;

    soc soc_inst(
        .rst(ext_rst),
        .system_clk(ext_clk),
        .\wb_dram_out.dat (64'b0),
        .\wb_dram_out.ack (1'b0),
        .\wb_dram_out.stall (1'b0),
        .\wb_ext_io_out.dat (32'b0),
        .\wb_ext_io_out.ack (1'b0),
        .\wb_ext_io_out.stall (1'b0),
        .\wishbone_dma_out.adr (30'b0),
        .\wishbone_dma_out.dat (64'b0),
        .\wishbone_dma_out.sel (8'b0),
        .\wishbone_dma_out.cyc (1'b0),
        .\wishbone_dma_out.stb (1'b0),
        .\wishbone_dma_out.we (1'b0),
        .ext_irq_eth(1'b0),
        .ext_irq_sdcard(1'b0),
        .uart0_rxd(uart0_rxd),
        .uart1_rxd(1'b0),
        .jtag_tck(jtag_tck),
        .jtag_tms(jtag_tms),
        .jtag_tdi(jtag_tdi),
        .jtag_trst(jtag_trst),
        .spi_flash_sdat_i(spi_flash_sdat_i),
        .gpio_in(gpio_in),
        .run_out(1'b0),
        .run_outs(1'b0),
        .\wb_dram_in.adr (29'b0),
        .\wb_dram_in.dat (64'b0),
        .\wb_dram_in.sel (8'b0),
        .\wb_dram_in.cyc (1'b0),
        .\wb_dram_in.stb (1'b0),
        .\wb_dram_in.we (1'b0),
        .\wb_ext_io_in.adr (30'b0),
        .\wb_ext_io_in.dat (32'b0),
        .\wb_ext_io_in.sel (4'b0),
        .\wb_ext_io_in.cyc (1'b0),
        .\wb_ext_io_in.stb (1'b0),
        .\wb_ext_io_in.we (1'b0),
        .wb_ext_is_dram_csr(1'b0),
        .wb_ext_is_dram_init(1'b0),
        .wb_ext_is_eth(1'b0),
        .wb_ext_is_sdcard(1'b0),
        .\wishbone_dma_in.dat (64'b0),
        .\wishbone_dma_in.ack (1'b0),
        .\wishbone_dma_in.stall (1'b0),
        .uart0_txd(uart0_txd),
        .uart1_txd(uart1_txd_dummy),
        .jtag_tdo(jtag_tdo),
        .spi_flash_sck(spi_flash_clk),
        .spi_flash_cs_n(spi_flash_cs_n),
        .spi_flash_sdat_o(spi_flash_sdat_o),
        .spi_flash_sdat_oe(spi_flash_sdat_oe),
        .gpio_out(gpio_out),
        .gpio_dir(gpio_dir),
        .sw_soc_reset(sw_soc_reset_dummy),
        .run_out(run_out_dummy),
        .run_outs(run_outs_dummy),
        .\wb_dram_in.adr (wb_dram_in_adr_dummy),
        .\wb_dram_in.cyc (wb_dram_in_cyc_dummy),
        .\wb_dram_in.dat (wb_dram_in_dat_dummy),
        .\wb_dram_in.sel (wb_dram_in_sel_dummy),
        .\wb_dram_in.stb (wb_dram_in_stb_dummy),
        .\wb_dram_in.we (wb_dram_in_we_dummy),
        .\wb_ext_io_in.adr (wb_ext_io_in_adr_dummy),
        .\wb_ext_io_in.cyc (wb_ext_io_in_cyc_dummy),
        .\wb_ext_io_in.dat (wb_ext_io_in_dat_dummy),
        .\wb_ext_io_in.sel (wb_ext_io_in_sel_dummy),
        .\wb_ext_io_in.stb (wb_ext_io_in_stb_dummy),
        .\wb_ext_io_in.we (wb_ext_io_in_we_dummy),
        .wb_ext_is_dram_csr(wb_ext_is_dram_csr_dummy),
        .wb_ext_is_dram_init(wb_ext_is_dram_init_dummy),
        .wb_ext_is_eth(wb_ext_is_eth_dummy),
        .wb_ext_is_sdcard(wb_ext_is_sdcard_dummy),
        .\wishbone_dma_in.ack (wishbone_dma_in_ack_dummy),
        .\wishbone_dma_in.dat (wishbone_dma_in_dat_dummy),
        .\wishbone_dma_in.stall (wishbone_dma_in_stall_dummy)
    );

    wire dummy1 = uart1_txd_dummy & 1'b0;
    wire dummy2 = sw_soc_reset_dummy & 1'b0;
    wire dummy3 = run_out_dummy & 1'b0;
    wire dummy4 = run_outs_dummy & 1'b0;
    wire [28:0] dummy5 = wb_dram_in_adr_dummy & 29'b0;
    wire dummy6 = wb_dram_in_cyc_dummy & 1'b0;
    wire [63:0] dummy7 = wb_dram_in_dat_dummy & 64'b0;
    wire [7:0] dummy8 = wb_dram_in_sel_dummy & 8'b0;
    wire dummy9 = wb_dram_in_stb_dummy & 1'b0;
    wire dummy10 = wb_dram_in_we_dummy & 1'b0;
    wire [29:0] dummy11 = wb_ext_io_in_adr_dummy & 30'b0;
    wire dummy12 = wb_ext_io_in_cyc_dummy & 1'b0;
    wire [31:0] dummy13 = wb_ext_io_in_dat_dummy & 32'b0;
    wire [3:0] dummy14 = wb_ext_io_in_sel_dummy & 4'b0;
    wire dummy15 = wb_ext_io_in_stb_dummy & 1'b0;
    wire dummy16 = wb_ext_io_in_we_dummy & 1'b0;
    wire dummy17 = wb_ext_is_dram_csr_dummy & 1'b0;
    wire dummy18 = wb_ext_is_dram_init_dummy & 1'b0;
    wire dummy19 = wb_ext_is_eth_dummy & 1'b0;
    wire dummy20 = wb_ext_is_sdcard_dummy & 1'b0;
    wire dummy21 = wishbone_dma_in_ack_dummy & 1'b0;
    wire [31:0] dummy22 = wishbone_dma_in_dat_dummy & 32'b0;
    wire dummy23 = wishbone_dma_in_stall_dummy & 1'b0;

endmodule
