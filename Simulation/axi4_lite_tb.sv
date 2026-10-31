module axi4_lite_top_tb;

    parameter DATA_WIDTH = 32;
    parameter ADDRESS    = 32;

    logic ACLK;
    logic ARESETN;
    logic read_s;
    logic write_s;

    logic [ADDRESS-1:0]    address;
    logic [DATA_WIDTH-1:0] W_data;
    axi4_lite_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDRESS(ADDRESS)
    ) dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .read_s(read_s),
        .write_s(write_s),
        .address(address),
        .W_data(W_data)
    );
    wire                    M_AWVALID;
    wire                    M_AWREADY;
    wire [ADDRESS-1:0]      M_AWADDR;

    wire                    M_WVALID;
    wire                    M_WREADY;
    wire [DATA_WIDTH-1:0]   M_WDATA;

    wire                    M_BVALID;
    wire                    M_BREADY;

    assign M_AWVALID = dut.u_axi4_lite_master0.M_AWVALID;
    assign M_AWREADY = dut.u_axi4_lite_master0.M_AWREADY;
    assign M_AWADDR  = dut.u_axi4_lite_master0.M_AWADDR;

    assign M_WVALID  = dut.u_axi4_lite_master0.M_WVALID;
    assign M_WREADY  = dut.u_axi4_lite_master0.M_WREADY;
    assign M_WDATA   = dut.u_axi4_lite_master0.M_WDATA;

    assign M_BVALID  = dut.u_axi4_lite_master0.M_BVALID;
    assign M_BREADY  = dut.u_axi4_lite_master0.M_BREADY;
    wire                    M_ARVALID;
    wire                    M_ARREADY;
    wire [ADDRESS-1:0]      M_ARADDR;

    wire                    M_RVALID;
    wire                    M_RREADY;
    wire [DATA_WIDTH-1:0]   M_RDATA;

    assign M_ARVALID = dut.u_axi4_lite_master0.M_ARVALID;
    assign M_ARREADY = dut.u_axi4_lite_master0.M_ARREADY;
    assign M_ARADDR  = dut.u_axi4_lite_master0.M_ARADDR;

    assign M_RVALID  = dut.u_axi4_lite_master0.M_RVALID;
    assign M_RREADY  = dut.u_axi4_lite_master0.M_RREADY;
    assign M_RDATA   = dut.u_axi4_lite_master0.M_RDATA;
    initial begin
        ACLK = 1'b0;
        forever #5 ACLK = ~ACLK;
    end
    initial begin

        // Initial values
        ARESETN = 1'b0;
        read_s  = 1'b0;
        write_s = 1'b0;
        address = 32'h00000000;
        W_data  = 32'h00000000;

        // Reset
        #20;
        ARESETN = 1'b1;
        @(posedge ACLK);

        address = 32'd5;
        W_data  = 32'd4;
        write_s = 1'b1;

        @(posedge ACLK);
        write_s = 1'b0;
        wait (M_AWVALID === 1'b1);

        $display("------------------------------------");
        $display("WRITE ADDRESS VALID");
        $display("M_AWADDR  = %0d", M_AWADDR);
        $display("M_AWVALID = %b", M_AWVALID);
        $display("M_AWREADY = %b", M_AWREADY);

        wait (M_AWVALID === 1'b1 && M_AWREADY === 1'b1);

        $display("WRITE ADDRESS HANDSHAKE COMPLETE");

        wait (M_WVALID === 1'b1);

        $display("------------------------------------");
        $display("WRITE DATA VALID");
        $display("M_WDATA  = %0d", M_WDATA);
        $display("M_WVALID = %b", M_WVALID);
        $display("M_WREADY = %b", M_WREADY);

        wait (M_WVALID === 1'b1 && M_WREADY === 1'b1);

        $display("WRITE DATA HANDSHAKE COMPLETE");

        wait (M_BVALID === 1'b1);

        $display("------------------------------------");
        $display("WRITE RESPONSE VALID");
        $display("M_BVALID = %b", M_BVALID);
        $display("M_BREADY = %b", M_BREADY);

        wait (M_BVALID === 1'b1 && M_BREADY === 1'b1);

        $display("WRITE RESPONSE HANDSHAKE COMPLETE");
        #1;

        if (dut.u_axi4_lite_slave0.register[5] === 32'd4) begin
            $display("WRITE TEST PASSED");
            $display("Address = %0d, Data = %0d",
                     5,
                     dut.u_axi4_lite_slave0.register[5]);
        end
        else begin
            $display("WRITE TEST FAILED");
            $display("Expected = 4, Actual = %0d",
                     dut.u_axi4_lite_slave0.register[5]);
        end

@(posedge ACLK);

address = 32'd5;
read_s  = 1'b1;

@(posedge ACLK);

read_s = 1'b0;
wait (dut.u_axi4_lite_slave0.S_RVALID == 1'b1);


if (dut.u_axi4_lite_slave0.S_RDATA == 32'd4) begin

    $display("READ TEST PASSED");
    $display("Address = 5, Data = %0d",
             dut.u_axi4_lite_slave0.S_RDATA);

end
else begin

    $display("READ TEST FAILED");
    $display("Expected = 4, Actual = %0d",
             dut.u_axi4_lite_slave0.S_RDATA);

end
        #20;

        $display("------------------------------------");
        $display("AXI4-LITE TESTBENCH COMPLETED");
        $display("------------------------------------");

        $finish;
    end
    initial begin
        $dumpfile("axi4_lite_top_tb.vcd");
        $dumpvars(0, axi4_lite_top_tb);
    end

endmodule
