module norm (clk, in, out, div, wr, o_full, reset, o_ready);

parameter bw = 4;
parameter width = 1;

input clk;
input wr;
input div;
input reset;
input [bw-1:0] in;
output reg [2*bw-1:0] out;
output o_full;
output reg o_ready;

wire [bw-1:0] fifo_out;
wire empty;
wire full;
wire [2*bw-1:0] div_out;
reg [2*bw-1:0] sum_q;

// Pipeline registers for division
reg div_in_progress;
reg [2:0] div_counter;  // Configurable delay counter
reg [bw-1:0] fifo_data_reg;  // Register to hold FIFO output

assign div_out = {fifo_data_reg, 8'b00000000} / sum_q;

fifo_top #(.bw(bw), .width(width)) fifo_top_instance (
    .clk(clk),
    .rd(div),  // Original FIFO read control
    .wr(wr),
    .in(in),
    .out(fifo_out),
    .reset(reset)
);

always @ (posedge clk) begin
    if (reset) begin
        sum_q <= 0;
        out <= 0;
        div_in_progress <= 0;
        div_counter <= 0;
        o_ready <= 1;
        fifo_data_reg <= 0;
    end
    else begin
        if (wr)
            sum_q <= sum_q + in;
            
        // Division pipeline control
        if (div && !div_in_progress) begin
            // Capture FIFO output into register
            fifo_data_reg <= fifo_out;
            div_in_progress <= 1;
            div_counter <= 3'd3;  // Set delay cycles (adjust as needed)
            o_ready <= 0;
        end
        else if (div_in_progress) begin
            if (div_counter == 0) begin
                // Division complete after specified delay
                out <= div_out;
                div_in_progress <= 0;
                o_ready <= 1;
            end
            else begin
                div_counter <= div_counter - 1;
            end
        end
    end
end

endmodule
