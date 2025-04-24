`timescale 1ns / 1ps
module exe(
    input         EXE_valid,
    input [151:0] ID_EXE_bus_r,
    input         flush_pipeline,
    output reg [1:0] exe_exception_type,
    output reg       exe_exception_flag
);

wire [1:0]  exception_type_from_id;
wire        exception_flag_from_id;
wire [12:0] alu_control;
wire [31:0] alu_operand1;
wire [31:0] alu_operand2;
wire [3:0]  mem_control;
wire [31:0] store_data;
wire        rf_wen;
wire [4:0]  rf_wdest;
wire [31:0] pc;

assign {
    exception_type_from_id,  // [151:150]
    exception_flag_from_id,  // [149]
    alu_control,             // [148:136]
    alu_operand1,            // [135:104]
    alu_operand2,            // [103:72]
    mem_control,             // [71:68]
    store_data,              // [67:36]
    rf_wen,                  // [35]
    rf_wdest,                // [34:30]
    pc                       // [29:0]
} = ID_EXE_bus_r;

wire [31:0] alu_result;
wire        alu_overflow;

alu alu_module(
    .alu_control  (alu_control),
    .alu_src1     (alu_operand1),
    .alu_src2     (alu_operand2),
    .alu_result   (alu_result),
    .overflow     (alu_overflow)
);

always @(*) begin
    exe_exception_flag = 1'b0;
    exe_exception_type = 2'b00;
    if (EXE_valid && !flush_pipeline) begin
        if (alu_control[12] && (alu_operand2 == 0)) begin
            exe_exception_flag = 1'b1;
            exe_exception_type = 2'b10;
        end
        else if (alu_overflow) begin
            exe_exception_flag = 1'b1;
            exe_exception_type = 2'b11;
        end
        else if (exception_flag_from_id) begin
            exe_exception_flag = 1'b1;
            exe_exception_type = exception_type_from_id;
        end
    end
end

endmodule