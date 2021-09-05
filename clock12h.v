module top_module(
    input clk,
    input reset,
    input ena,
    output pm,
    output [7:0] hh,
    output [7:0] mm,
    output [7:0] ss); 

    wire ena_mm, ena_hh, ena_pm;
    bcd_cnt60 ss_inst (clk, reset, ena, ena_mm, ss);
    bcd_cnt60 mm_inst (clk, reset, ena_mm, ena_hh, mm);
    bcd_cnt12 hh_inst (clk, reset, ena_hh, ena_pm, hh);

    reg pm_t;
    always @(posedge clk) begin
        if (reset)
            pm_t <= 0;
        else if (ena_pm)
            pm_t <= ~pm_t;

    end
    assign pm = pm_t;

endmodule


module bcd_cnt60(
    input clk,
    input reset,
    input ena_i,
    output ena_o,
    output reg [7:0] q);

    always @(posedge clk) begin
        if (reset)
            q <= 0;
        else if (ena_i && q==8'h59)  // 59
            q <= 0;
        else if (ena_i && q[7:4]<5 && q[3:0] ==9) begin //09 19 29 ...49
            q[7:4] <= q[7:4] + 1; q[3:0] <= 0;
        end else if (ena_i)
            q <= q + 1;         

    end
    assign ena_o = ena_i && q==8'h59;
endmodule

module bcd_cnt12(
    input clk,
    input reset,
    input ena_i,
    output ena_o,
    output reg [7:0] q);

    always @(posedge clk) begin
        if (reset)
            q <= 8'h12;
        else if (ena_i && q==8'h11)  // 11:59--12:00--1:00
            q <= q + 1;
        else if (ena_i && q==9) begin //09
            q[7:4] <= q[7:4] + 1; q[3:0] <= 0;
        end else if (ena_i && q==8'h12) //12:59
            q <= 1;  
        else if (ena_i)
            q <= q + 1;  
    end         
    assign ena_o = ena_i && q==8'h11;
endmodule