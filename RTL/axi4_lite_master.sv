module axi4_lite_master #(
    parameter ADDRESS = 32,
    parameter DATA_WIDTH = 32
)
(
    // Global Signals
    input                           ACLK,
    input                           ARESETN,

    input                           START_READ,
    input                           START_WRITE,

    input  [ADDRESS-1:0]            address,
    input  [DATA_WIDTH-1:0]         W_data,

    input                           M_ARREADY,

 
    input  [DATA_WIDTH-1:0]         M_RDATA,
    input  [1:0]                    M_RRESP,
    input                           M_RVALID,

    // Write Address Channel INPUTS
    input                           M_AWREADY,

    // Write Data Channel INPUTS
    input                           M_WREADY,

    // Write Response Channel INPUTS
    input  [1:0]                    M_BRESP,
    input                           M_BVALID,

    // Read Address Channel OUTPUTS
    output logic [ADDRESS-1:0]      M_ARADDR,
    output logic                    M_ARVALID,

    // Read Data Channel OUTPUTS
    output logic                    M_RREADY,

    // Write Address Channel OUTPUTS
    output logic [ADDRESS-1:0]      M_AWADDR,
    output logic                    M_AWVALID,

    // Write Data Channel OUTPUTS
    output logic [DATA_WIDTH-1:0]   M_WDATA,
    output logic [3:0]              M_WSTRB,
    output logic                    M_WVALID,

    // Write Response Channel OUTPUTS
    output logic                    M_BREADY
);

    logic read_start;
    logic write_addr;
    logic write_data;
    logic write_start;

    typedef enum logic [2:0] {
        IDLE,
        WRITE_CHANNEL,
        WRESP__CHANNEL,
        RADDR_CHANNEL,
        RDATA__CHANNEL
    } state_type;

    state_type state, next_state;
    assign M_ARADDR  = (state == RADDR_CHANNEL) ? address : 32'h0;
    assign M_ARVALID = (state == RADDR_CHANNEL) ? 1'b1 : 1'b0;

    assign M_RREADY =
        (state == RDATA__CHANNEL || state == RADDR_CHANNEL)
        ? 1'b1 : 1'b0;

    assign M_AWVALID = (state == WRITE_CHANNEL) ? 1'b1 : 1'b0;

    assign M_AWADDR =
        (state == WRITE_CHANNEL) ? address : 32'h0;

    assign write_addr = M_AWVALID && M_AWREADY;

    assign M_WVALID = (state == WRITE_CHANNEL) ? 1'b1 : 1'b0;

    assign M_WDATA =
        (state == WRITE_CHANNEL) ? W_data : 32'h0;

    assign M_WSTRB =
        (state == WRITE_CHANNEL) ? 4'b1111 : 4'b0000;

    assign write_data = M_WVALID && M_WREADY;

    assign M_BREADY =
        ((state == WRITE_CHANNEL) ||
         (state == WRESP__CHANNEL))
        ? 1'b1 : 1'b0;
    always_ff @(posedge ACLK) begin
        if (~ARESETN) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_ff @(posedge ACLK) begin
        if (~ARESETN) begin
            read_start  <= 1'b0;
            write_start <= 1'b0;
        end
        else begin
            read_start  <= START_READ;
            write_start <= START_WRITE;
        end
    end

    always_comb begin

        next_state = state;

        case (state)

            IDLE: begin

                if (write_start)
                    next_state = WRITE_CHANNEL;

                else if (read_start)
                    next_state = RADDR_CHANNEL;

            end


            WRITE_CHANNEL: begin

                if (write_addr && write_data)
                    next_state = WRESP__CHANNEL;

            end


            WRESP__CHANNEL: begin

                if (M_BVALID && M_BREADY)
                    next_state = IDLE;

            end


            RADDR_CHANNEL: begin

                if (M_ARVALID && M_ARREADY)
                    next_state = RDATA__CHANNEL;

            end


            RDATA__CHANNEL: begin

                if (M_RVALID && M_RREADY)
                    next_state = IDLE;

            end


            default: begin
                next_state = IDLE;
            end

        endcase

    end

endmodule
