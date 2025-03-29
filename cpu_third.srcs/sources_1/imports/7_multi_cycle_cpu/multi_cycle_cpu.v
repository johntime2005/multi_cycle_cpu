`timescale 1ns / 1ps
//*************************************************************************
//   > 文件名: multi_cycle_cpu.v
//   > 描述  : 多周期CPU模块，支持异常处理
//   > 作者  : LOONGSON
//   > 日期  : 2016-04-14
//*************************************************************************
module multi_cycle_cpu(  // 多周期CPU
    input clk,           // 时钟
    input resetn,        // 复位信号，低电平有效
    input [5:0] irq,     // 新增：中断请求信号

    // 显示数据
    input  [ 4:0] rf_addr,   // 待显示的寄存器地址
    input  [31:0] mem_addr,  // 待显示的内存地址
    output [31:0] rf_data,   // 待显示的寄存器数据
    output [31:0] mem_data,  // 待显示的内存数据
    output [31:0] IF_pc,     // IF阶段PC
    output [31:0] IF_inst,   // IF阶段指令
    output [31:0] ID_pc,     // ID阶段PC
    output [31:0] EXE_pc,    // EXE阶段PC
    output [31:0] MEM_pc,    // MEM阶段PC
    output [31:0] WB_pc,     // WB阶段PC
    output [31:0] display_state // 显示当前状态机状态
    );
    //----------------------- 异常/中断/CP0 信号声明 -----------------------//
    wire [1:0]  id_exception_type;  // ID阶段异常类型
    wire        id_exception_flag;  // ID阶段异常标志
    wire [1:0]  exe_exception_type; // EXE阶段异常类型
    wire        exe_exception_flag; // EXE阶段异常标志
    wire [1:0]  mem_exception_type; // MEM阶段异常类型
    wire        mem_exception_flag; // MEM阶段异常标志

    wire        exception_triggered;// 最终异常/中断触发信号 (来自 exception_controller)
    wire [4:0]  final_exception_type; // 最终确定的异常类型 (ExcCode, 来自 exception_controller)
    wire [31:0] epc_to_cp0;         // 计算出的EPC (来自 exception_controller)
    wire [31:0] exception_vector_pc;// 异常处理入口地址 (来自 exception_controller)
    wire        cp0_wen;            // CP0写使能信号 (来自 exception_controller)

    // 来自 CP0 的信号
    wire [31:0] cp0_epc_out;        // 从 CP0 读出的 EPC
    wire [31:0] cp0_cause_out;      // 从 CP0 读出的 Cause
    wire [31:0] cp0_status_out;     // 新增: 从 CP0 读出的 Status
    wire        cp0_status_exl;     // Status.EXL 位
    wire        cp0_status_ie;      // Status.IE 位

    assign cp0_status_exl = cp0_status_out[1]; // 假设 EXL 在 bit 1
    assign cp0_status_ie  = cp0_status_out[0]; // 假设 IE 在 bit 0

    // 中断信号
    wire        id_interrupt_flag;  // ID阶段中断标志
    wire [1:0]  id_interrupt_type;  // ID阶段中断类型

    // ERET 信号
    wire        eret_executed;      // ERET 指令执行信号 (来自 decode)
//----------------------{控制多周期的状态机}begin------------------------//
    reg [2:0] state;       // 当前状态
    reg [2:0] next_state;  // 下一状态

    // 显示当前处理器正在执行哪个模块
    assign display_state = {29'd0, state};
    // 状态机状态定义
    parameter IDLE   = 3'd0;  // 初始状态
    parameter FETCH  = 3'd1;  // 取指状态
    parameter DECODE = 3'd2;  // 译码状态
    parameter EXE    = 3'd3;  // 执行状态
    parameter MEM    = 3'd4;  // 访存状态
    parameter WB     = 3'd5;  // 写回状态

    always @ (posedge clk)        // 当前状态寄存器
    begin
        if (!resetn) begin        // 如果复位信号有效
            state <= IDLE;       // 当前状态为 初始
        end
        else begin                // 否则
            state <= next_state;  // 更新为下一状态
        end
    end

    wire IF_over;     // IF模块已执行完标志
    wire ID_over;     // ID模块已执行完标志
    wire EXE_over;    // EXE模块已执行完标志 (注意：exe.v 中未定义此输出，需要添加或假设其行为)
    wire MEM_over;    // MEM模块已执行完标志
    wire WB_over;     // WB模块已执行完标志
    wire jbr_not_link;// 分支指令(非link类)，只涉及IF和ID阶段
    always @ (*)                             // 下一状态逻辑
    begin
        if (exception_triggered) begin // 如果异常触发
             next_state = FETCH; // 强制跳回 FETCH 状态以执行异常处理程序
        end else begin // 正常状态转移
            case (state)
                IDLE :
                begin
                    next_state = FETCH;    // 初始->取指
                end
                FETCH:
                begin
                    if (IF_over) begin
                        next_state = DECODE;   // 取指->译码
                    end else begin
                        next_state = FETCH;    // 取指->取指 (如果取指未完成)
                    end
                end
                DECODE:
                begin
                    if (ID_over) begin
                        // 如果是 ERET 指令，下一状态是 FETCH (ERET 跳转在 fetch 模块处理)
                        if (eret_executed) begin
                            next_state = FETCH;
                        // 如果是非链接跳转/分支，下一状态是 FETCH
                        end else if (jbr_not_link) begin
                            next_state = FETCH;
                        // 否则，下一状态是 EXE
                        end else begin
                            next_state = EXE;
                        end
                    end else begin
                        next_state = DECODE;   // 译码->译码 (如果译码未完成)
                    end
                end
                EXE:
                begin
                    // 假设 EXE 阶段总是在一个周期内完成 (EXE_over = EXE_valid)
                    // 如果需要多周期执行单元，需要修改 EXE_over 逻辑
                    if (EXE_valid) begin // 简化：假设 EXE_over = EXE_valid
                        next_state = MEM;      // 执行->存储
                    end else begin
                        next_state = EXE;      // 执行->执行 (如果执行未完成)
                    end
                end
                MEM:
                begin
                    if (MEM_over) begin
                        next_state = WB;       // 存储->写回
                    end else begin
                        next_state = MEM;      // 存储->存储 (如果访存未完成)
                    end
                end
                WB:
                begin
                    if (WB_over) begin
                        next_state = FETCH;    // 写回->取指
                    end else begin
                        next_state = WB;       // 写回->写回 (如果写回未完成)
                    end
                end
                default : next_state = IDLE; // 默认回到初始状态
            endcase
        end
    end
    // 5个模块的有效信号 (valid)
    wire IF_valid;
    wire ID_valid;
    wire EXE_valid;
    wire MEM_valid;
    wire WB_valid;
    assign  IF_valid = (state == FETCH );  // 当前状态为取指时，IF段有效
    assign  ID_valid = (state == DECODE);  // 当前状态为译码时，ID段有效
    assign EXE_valid = (state == EXE   );  // 当前状态为执行时，EXE段有效
    assign MEM_valid = (state == MEM   );  // 当前状态为存储时，MEM段有效
    assign  WB_valid = (state == WB    );  // 当前状态为写回时，WB段有效
//-----------------------{控制多周期的状态机}end-------------------------//

//--------------------------{5段间的流水线}begin---------------------------//
    wire [ 63:0] IF_ID_bus;   // IF->ID流水线总线 {指令, pc}
    wire [156:0] ID_EXE_bus;  // ID->EXE流水线总线 (更新位宽)
    wire [108:0] EXE_MEM_bus; // EXE->MEM流水线总线 (更新位宽)
    wire [ 72:0] MEM_WB_bus;  // MEM->WB流水线总线 (更新位宽)

    // 寄存上述流水线信号的寄存器
    reg [ 63:0] IF_ID_bus_r;
    reg [156:0] ID_EXE_bus_r; // (更新位宽)
    reg [108:0] EXE_MEM_bus_r;// (更新位宽)
    reg [ 72:0] MEM_WB_bus_r; // (更新位宽)

    // IF到ID的流水线寄存器
    always @(posedge clk) begin
        if (!resetn) begin
            IF_ID_bus_r <= 64'b0;
        // 异常/ERET 发生时，下一拍进入 FETCH，需要清空 ID 阶段，防止旧指令干扰
        end else if (exception_triggered || eret_executed) begin
            IF_ID_bus_r <= 64'b0; // 清零或设为 NOP
        end else if (IF_over) begin
            IF_ID_bus_r <= IF_ID_bus;
        end
    end
    // ID到EXE的流水线寄存器
    always @(posedge clk) begin
         if (!resetn) begin
            ID_EXE_bus_r <= 157'b0;
        // 异常/ERET 发生时，清空 EXE 阶段
        end else if (exception_triggered || eret_executed) begin
            ID_EXE_bus_r <= 157'b0; // 清零
        end else if (ID_over) begin
            ID_EXE_bus_r <= ID_EXE_bus;
        end
    end
    // EXE到MEM的流水线寄存器
    always @(posedge clk) begin
         if (!resetn) begin
            EXE_MEM_bus_r <= 109'b0;
        // 异常/ERET 发生时，清空 MEM 阶段
        end else if (exception_triggered || eret_executed) begin
            EXE_MEM_bus_r <= 109'b0; // 清零
        end else if (EXE_valid) begin // 假设 EXE_over = EXE_valid
            EXE_MEM_bus_r <= EXE_MEM_bus;
        end
    end
    // MEM到WB的流水线寄存器
    always @(posedge clk) begin
         if (!resetn) begin
            MEM_WB_bus_r <= 73'b0;
        // 异常/ERET 发生时，清空 WB 阶段
        end else if (exception_triggered || eret_executed) begin
            MEM_WB_bus_r <= 73'b0; // 清零 (确保异常指令不写回)
        end else if (MEM_over) begin
            MEM_WB_bus_r <= MEM_WB_bus;
        end
    end
//---------------------------{5段间的流水线}end----------------------------//

//--------------------------{其他交互信号}begin--------------------------//
    // 跳转/分支流水线信号
    wire [ 32:0] jbr_bus;    // {跳转有效, 跳转目标地址}

    // IF与指令存储器(inst_rom)交互
    wire [31:0] inst_addr; // 指令地址
    wire [31:0] inst;      // 读取到的指令

    // MEM与数据存储器(data_ram)交互
    wire [ 3:0] dm_wen;    // 数据存储器写使能 (按字节)
    wire [31:0] dm_addr;   // 数据存储器地址
    wire [31:0] dm_wdata;  // 写入数据存储器的数据
    wire [31:0] dm_rdata;  // 从数据存储器读取的数据

    // ID与寄存器堆(regfile)交互
    wire [ 4:0] rs;        // 源寄存器1地址
    wire [ 4:0] rt;        // 源寄存器2地址
    wire [31:0] rs_value;  // 源寄存器1的值
    wire [31:0] rt_value;  // 源寄存器2的值

    // WB与寄存器堆(regfile)交互
    wire        rf_wen;    // 寄存器堆写使能
    wire [ 4:0] rf_wdest;  // 目标寄存器地址
    wire [31:0] rf_wdata;  // 写入寄存器堆的数据
//---------------------------{其他交互信号}end---------------------------//

//-------------------------{各模块实例化}begin---------------------------//
    wire next_fetch;
    // 修改 next_fetch 逻辑：异常或 ERET 发生时，下一状态是 FETCH，不需要 next_fetch
    assign next_fetch = !exception_triggered && !eret_executed &&
                      ((state==DECODE & ID_over & jbr_not_link) | (state==WB & WB_over));

    fetch IF_module(
        .clk       (clk       ),
        .resetn    (resetn    ),
        .IF_valid  (IF_valid  ),
        .next_fetch(next_fetch),
        .inst      (inst      ),
        .jbr_bus   (jbr_bus   ),
        .exception_triggered(exception_triggered), // 连接到控制器输出
        .exception_vector_pc(exception_vector_pc), // 连接到控制器输出
        .eret_executed      (eret_executed),       // 连接 ERET 信号
        .cp0_epc_out        (cp0_epc_out),         // 连接 CP0 EPC 输出
        .inst_addr (inst_addr ),
        .IF_over   (IF_over   ),
        .IF_ID_bus (IF_ID_bus ),
        .IF_pc     (IF_pc     ),
        .IF_inst   (IF_inst   )
    );

    decode ID_module(
        .ID_valid    (ID_valid    ),
        .IF_ID_bus_r (IF_ID_bus_r ),
        .rs_value    (rs_value    ),
        .rt_value    (rt_value    ),
        .irq         (irq         ), // 连接中断输入
        .rs          (rs          ),
        .rt          (rt          ),
        .jbr_bus     (jbr_bus     ),
        .jbr_not_link(jbr_not_link),
        .ID_over     (ID_over     ),
        .ID_EXE_bus  (ID_EXE_bus  ), // 位宽 157
        .eret_executed(eret_executed), // 输出 ERET 信号
        .id_exception_type(id_exception_type),
        .id_exception_flag(id_exception_flag),
        .id_interrupt_type(id_interrupt_type),
        .id_interrupt_flag(id_interrupt_flag),
        .ID_pc      (ID_pc      )
    );

    exe EXE_module(
        .EXE_valid   (EXE_valid   ),
        .ID_EXE_bus_r(ID_EXE_bus_r), // 位宽 157
        // .flush_pipeline(flush_pipeline), // 移除
        .exe_exception_type(exe_exception_type),
        .exe_exception_flag(exe_exception_flag),
        .EXE_MEM_bus (EXE_MEM_bus ), // 位宽 109
        .EXE_pc      (EXE_pc      )
        // .EXE_over implicitly defined if not connected // 如果未连接，EXE_over 隐式定义 (需要确认 exe.v 是否有此输出)
    );

    mem MEM_module(
        .clk          (clk          ),
        .MEM_valid    (MEM_valid    ),
        .EXE_MEM_bus_r(EXE_MEM_bus_r), // 位宽 109
        .dm_rdata     (dm_rdata     ),
        .dm_addr      (dm_addr      ),
        .dm_wen       (dm_wen       ),
        .dm_wdata     (dm_wdata     ),
        .MEM_over     (MEM_over     ),
        .MEM_WB_bus   (MEM_WB_bus   ), // 位宽 73
        .mem_exception_type(mem_exception_type),
        .mem_exception_flag(mem_exception_flag),
        .MEM_pc       (MEM_pc       )
    );

    wb WB_module(
        .WB_valid    (WB_valid    ),
        .MEM_WB_bus_r(MEM_WB_bus_r), // 位宽 73
        .rf_wen      (rf_wen      ),
        .rf_wdest    (rf_wdest    ),
        .rf_wdata    (rf_wdata    ),
        .WB_over     (WB_over     ),
        .WB_pc       (WB_pc       )
    );


    exception_controller exception_controller_module(
        .clk               (clk               ),
        .resetn            (resetn            ),
        .id_exception_type (id_exception_type ),
        .id_exception_flag (id_exception_flag ),
        .id_pc             (ID_pc             ),
        .id_interrupt_type (id_interrupt_type ),
        .id_interrupt_flag (id_interrupt_flag ),
        .exe_exception_type(exe_exception_type),
        .exe_exception_flag(exe_exception_flag),
        .exe_pc            (EXE_pc            ),
        .mem_exception_type(mem_exception_type),
        .mem_exception_flag(mem_exception_flag),
        .mem_pc            (MEM_pc            ),
        .cp0_status_exl    (cp0_status_exl    ), // 连接 Status.EXL
        .cp0_status_ie     (cp0_status_ie     ), // 连接 Status.IE

        .exception_triggered(exception_triggered), // O
        .final_exception_type(final_exception_type), // O, [4:0] ExcCode
        .epc_out           (epc_to_cp0        ), // O, [31:0] EPC 值
        .cp0_pc            (exception_vector_pc),// O, [31:0] 异常向量
        .cp0_write_enable  (cp0_wen           )  // O, CP0 写使能
    );

    // 实例化 CP0 模块
    cp0 cp0_module ( // 将 cp0_reg 更改为 cp0
        .clk(clk),
        .resetn(resetn),
        .wen(cp0_wen),                 // 来自 exception_controller
        .eret_executed(eret_executed), // 连接 ERET 信号
        .epc_in(epc_to_cp0),           // 来自 exception_controller
        .cause_exccode_in(final_exception_type), // 来自 exception_controller
        .epc_out(cp0_epc_out),         // 输出 EPC
        .cause_out(cp0_cause_out),     // 输出 Cause
        .status_out(cp0_status_out)    // 输出 Status
    );

    inst_rom inst_rom_module(
        .clka       (clk           ),
        .addra      (inst_addr[9:2]), // 假设 256 条指令, 8 位地址
        .douta      (inst          )
    );

    regfile rf_module(
        .clk    (clk      ),
        .resetn (resetn   ), // 添加复位连接
        .wen    (rf_wen   ),
        .raddr1 (rs       ),
        .raddr2 (rt       ),
        .waddr  (rf_wdest ),
        .wdata  (rf_wdata ),
        .rdata1 (rs_value ),
        .rdata2 (rt_value ),
        .test_addr(rf_addr),
        .test_data(rf_data)
    );

    data_ram data_ram_module(
        .clka   (clk         ),
        .wea    (dm_wen      ),
        .addra  (dm_addr[9:2]), // 假设 256 个字, 8 位地址
        .dina   (dm_wdata    ),
        .douta  (dm_rdata    ),
        .clkb   (clk          ), // 调试端口时钟
        .web    (4'd0         ), // 调试端口写使能 (固定为0)
        .addrb  (mem_addr[9:2]), // 调试端口地址
        .doutb  (mem_data     ), // 调试端口读数据
        .dinb   (32'd0        )  // 调试端口写数据 (未使用)
    );
//--------------------------{各模块实例化}end----------------------------//
endmodule
