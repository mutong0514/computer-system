`include "lib/defines.vh"
module IF(
    input wire clk,//时钟信号
    input wire rst,//复位信号
    input wire [`StallBus-1:0] stall,//这个应该是暂停信号

    // input wire flush,
    // input wire [31:0] new_pc,

    input wire [`BR_WD-1:0] br_bus,//跳转指令的内容，ID段传过来的

    output wire [`IF_TO_ID_WD-1:0] if_to_id_bus,//IF段传给ID段的内容

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,//这个就是取到的指令了
    output wire [31:0] inst_sram_wdata
);
    reg [31:0] pc_reg;//这个就是pc
    reg ce_reg;//指令存储器使能信号
    wire [31:0] next_pc;//下一个pc
    wire br_e;//是否跳转
    wire [31:0] br_addr;//跳转后地址

    assign {
        br_e,
        br_addr
    } = br_bus;


    always @ (posedge clk) begin
        if (rst) begin
            pc_reg <= 32'hbfbf_fffc;
        end//复位时pc等于一个不知道是啥意思的什么鬼值(4294967292)
        else if (stall[0]==`NoStop) begin
            pc_reg <= next_pc;
        end//pc等于下一个pc
    end

    always @ (posedge clk) begin
        if (rst) begin
            ce_reg <= 1'b0;
        end//复位时禁用指令存储器
        else if (stall[0]==`NoStop) begin
            ce_reg <= 1'b1;
        end//指令存储器可用
    end

    //是否跳转？下一条pc是跳转后的地址或是现地址+4
    assign next_pc = br_e ? br_addr 
                   : pc_reg + 32'h4;

    
    assign inst_sram_en = ce_reg;//指令存储器使能信号
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pc_reg;//这个就是取到的指令了
    assign inst_sram_wdata = 32'b0;
    assign if_to_id_bus = {
        ce_reg,
        pc_reg
    };

endmodule