module norm (clk, in, out, div, wr, o_full, reset, o_ready);

parameter bw = 4;
parameter width = 1;
parameter DIV_CYCLES = 3;  // Number of cycles for division operation

input clk;
input wr;
input div;
input reset;
input [bw-1:0] in;
output reg [2*bw-1:0] out;
output o_full;
output o_ready;

wire [bw-1:0] fifo_out;
wire empty;
wire full;
wire [2*bw-1:0] div_out;
reg [2*bw-1:0] sum_q;

// Division state machine registers
reg [1:0] div_state;
reg [DIV_CYCLES-1:0] div_counter;
reg div_in_progress;
reg div_valid;

// Division result calculation
assign div_out = {fifo_out, 8'b00000000} / sum_q;

fifo_top #(.bw(bw), .width(width)) fifo_top_instance (
    .clk(clk),
    .rd(div && !div_in_progress),  // Only read from FIFO when starting a new division
    .wr(wr),
    .in(in),
    .out(fifo_out),
    .reset(reset)
);

always @ (posedge clk) begin
    if (reset) begin
        sum_q <= 0;
        out <= 0;
        div_state <= 0;
        div_counter <= 0;
        div_in_progress <= 0;
        div_valid <= 0;
    end
    else begin
        if (wr)
            sum_q <= sum_q + in;
        
        // Division state machine
        case (div_state)
            0: begin  // Idle state
                if (div && !div_in_progress) begin
                    div_in_progress <= 1;
                    div_counter <= DIV_CYCLES-1;
                    div_state <= 1;
                    div_valid <= 0;
                end
            end
            
            1: begin  // Division in progress
                if (div_counter == 0) begin
                    // Division complete
                    out <= div_out;
                    div_in_progress <= 0;
                    div_valid <= 1;
                    div_state <= 0;
                end
                else begin
                    div_counter <= div_counter - 1;
                end
            end
        endcase
    end
end

// Output ready signal
assign o_ready = !div_in_progress;

endmodule
