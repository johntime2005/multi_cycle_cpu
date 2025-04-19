`timescale 1ns / 1ps
//*************************************************************************
// ALU妯″潡 (Arithmetic Logic Unit)
// 浣滆€�         : LOONGSON
// 鍒涘缓鏃ユ湡     : 2016-04-14
// 鍔熻兘         : 瀹炵幇鍔犮€佸噺銆佹湁绗﹀彿/鏃犵鍙锋瘮杈冦€佹寜浣嶈繍绠楀強绉讳綅鎿嶄綔
//*************************************************************************
module alu(
    input  [11:0] alu_control,  // ALU鎺у埗淇″彿锛屽悇浣嶅搴斾笉鍚岀殑杩愮畻锛堝姞銆佸噺銆佹瘮杈冦€侀€昏緫銆佺Щ浣嶇瓑锛�
    input  [31:0] alu_src1,     // 杩愮畻鎿嶄綔鏁�1
    input  [31:0] alu_src2,     // 杩愮畻鎿嶄綔鏁�2
    output [31:0] alu_result    // 杩愮畻缁撴灉
    );

    // 鍒嗚Вalu_control鍚勪釜浣嶇殑鍚箟
    wire alu_add;   // 鍔犳硶浣胯兘
    wire alu_sub;   // 鍑忔硶浣胯兘
    wire alu_slt;   // 鏈夌鍙峰皬浜庢瘮杈冧娇鑳�
    wire alu_sltu;  // 鏃犵鍙峰皬浜庢瘮杈冧娇鑳�
    wire alu_and;   // 鎸変綅涓庝娇鑳�
    wire alu_nor;   // 鎸変綅鎴栭潪浣胯兘
    wire alu_or;    // 鎸変綅鎴栦娇鑳�
    wire alu_xor;   // 鎸変綅寮傛垨浣胯兘
    wire alu_sll;   // 閫昏緫宸︾Щ浣胯兘
    wire alu_srl;   // 閫昏緫鍙崇Щ浣胯兘
    wire alu_sra;   // 绠楁湳鍙崇Щ浣胯兘
    wire alu_lui;   // load upper immediate鎸囦护浣胯兘
    wire alu_div;   // 鍔犲噺浣胯兘

    assign alu_div  = alu_control[12];
    assign alu_add  = alu_control[11];
    assign alu_sub  = alu_control[10];
    assign alu_slt  = alu_control[ 9];
    assign alu_sltu = alu_control[ 8];
    assign alu_and  = alu_control[ 7];
    assign alu_nor  = alu_control[ 6];
    assign alu_or   = alu_control[ 5];
    assign alu_xor  = alu_control[ 4];
    assign alu_sll  = alu_control[ 3];
    assign alu_srl  = alu_control[ 2];
    assign alu_sra  = alu_control[ 1];
    assign alu_lui  = alu_control[ 0];

    // 瀹氫箟鍚勫姛鑳借繍绠楃殑缁撴灉淇″彿
    wire [31:0] add_sub_result;
    wire [31:0] slt_result;
    wire [31:0] sltu_result;
    wire [31:0] and_result;
    wire [31:0] nor_result;
    wire [31:0] or_result;
    wire [31:0] xor_result;
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    wire [31:0] lui_result;
    wire [31:0] div_result;

    // 鎸変綅杩愮畻閫昏緫
    assign and_result = alu_src1 & alu_src2;         // 鎸変綅涓�
    assign or_result  = alu_src1 | alu_src2;          // 鎸変綅鎴�
    assign nor_result = ~or_result;                   // 鎸変綅鎴栭潪锛堝彇鎴栫殑鍙嶏級
    assign xor_result = alu_src1 ^ alu_src2;           // 鎸変綅寮傛垨
    assign lui_result = {alu_src2[15:0], 16'd0};       // 楂樹綅鍔犺浇鎿嶄綔锛屽皢浣�16浣嶆暟鎹斁楂樼
    assign div_result = alu_src2 != 0 ? alu_src1 / alu_src2 : 32'd0; // 简单实现除法

    // --- 鍔犲噺杩愮畻涓庢瘮杈冩搷浣� (slt/sltu) begin -------------------------
    // 浣跨敤鍔犳硶鍣ㄨ绠楀姞娉曟垨鍑忔硶缁撴灉
    wire [31:0] adder_operand1;
    wire [31:0] adder_operand2;
    wire        adder_cin;
    wire [31:0] adder_result;
    wire        adder_cout;
    
    assign adder_operand1 = alu_src1;
    // 鍔犳硶鏃剁洿鎺ョ敤alu_src2锛屽噺娉曟椂鍙栧弽alu_src2锛堢敤浜�2鐨勮ˉ鐮佸噺娉曪級
    assign adder_operand2 = alu_add ? alu_src2 : ~alu_src2;
    // 鍔犳硶鏃惰繘浣嶄负0锛屽噺娉曟椂杩涗綅缃�1
    assign adder_cin      = ~alu_add;
    
    adder adder_module(
        .operand1(adder_operand1),
        .operand2(adder_operand2),
        .cin     (adder_cin),
        .result  (adder_result),
        .cout    (adder_cout)
    );
    
    // 鍔犳硶涓庡噺娉曠粨鏋�
    assign add_sub_result = adder_result;
    
    // 鏈夌鍙峰皬浜庢瘮杈� (slt)
    // 鍙繚鐣欑粨鏋滅殑鏈€浣庝綅锛屽叾浣欎綅琛ラ浂
    assign slt_result[31:1] = 31'd0;
    // 鑻lu_src1涓鸿礋鑰宎lu_src2涓烘锛涙垨鑰呬袱鏁扮鍙风浉鍚屼笖鍑忔硶缁撴灉涓鸿礋锛屽垯璁や负alu_src1灏忎簬alu_src2
    assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31]) | 
                              (~(alu_src1[31] ^ alu_src2[31]) & adder_result[31]);

    // 鏃犵鍙峰皬浜庢瘮杈� (sltu)
    // 鍒╃敤鍔犳硶鍣ㄧ殑杩涗綅淇℃伅锛岃嫢杩涗綅涓�0(鍗硚adder_cout涓�1)鍒欒〃绀篴lu_src1灏忎簬alu_src2
    assign sltu_result = {31'd0, ~adder_cout};
    // --- 鍔犲噺杩愮畻涓庢瘮杈冩搷浣� end ---------------------------------------

    // --- 绉讳綅鎿嶄綔 begin -----------------------------------------------
    // 浠巃lu_src1涓彁鍙栫Щ浣嶆暟锛堝彇浣�5浣嶏級
    wire [4:0] shf;
    assign shf = alu_src1[4:0];
    wire [1:0] shf_1_0 = shf[1:0];
    wire [1:0] shf_3_2 = shf[3:2];

    // 閫昏緫宸︾Щ (SLL)
    wire [31:0] sll_step1;
    wire [31:0] sll_step2;
    // 鏍规嵁浣�2浣嶈繘琛屽垵姝ュ乏绉�
    assign sll_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   | 
                       {32{shf_1_0 == 2'b01}} & {alu_src2[30:0], 1'd0}     | 
                       {32{shf_1_0 == 2'b10}} & {alu_src2[29:0], 2'd0}     | 
                       {32{shf_1_0 == 2'b11}} & {alu_src2[28:0], 3'd0};
    // 鏍规嵁楂�2浣嶈繘涓€姝ュ乏绉�
    assign sll_step2 = {32{shf_3_2 == 2'b00}} & sll_step1                  | 
                       {32{shf_3_2 == 2'b01}} & {sll_step1[27:0], 4'd0}    | 
                       {32{shf_3_2 == 2'b10}} & {sll_step1[23:0], 8'd0}    | 
                       {32{shf_3_2 == 2'b11}} & {sll_step1[19:0], 12'd0};
    // 鑻hf鐨勬渶楂樹綅涓�1锛屽垯鍐嶅乏绉�16浣�
    assign sll_result = shf[4] ? {sll_step2[15:0], 16'd0} : sll_step2;

    // 閫昏緫鍙崇Щ (SRL)
    wire [31:0] srl_step1;
    wire [31:0] srl_step2;
    // 鏍规嵁浣�2浣嶅彸绉伙紝宸︿晶琛�0
    assign srl_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                   | 
                       {32{shf_1_0 == 2'b01}} & {1'd0, alu_src2[31:1]}     | 
                       {32{shf_1_0 == 2'b10}} & {2'd0, alu_src2[31:2]}     | 
                       {32{shf_1_0 == 2'b11}} & {3'd0, alu_src2[31:3]};
    // 鏍规嵁楂�2浣嶈繘涓€姝ュ彸绉�
    assign srl_step2 = {32{shf_3_2 == 2'b00}} & srl_step1                  | 
                       {32{shf_3_2 == 2'b01}} & {4'd0, srl_step1[31:4]}    | 
                       {32{shf_3_2 == 2'b10}} & {8'd0, srl_step1[31:8]}    | 
                       {32{shf_3_2 == 2'b11}} & {12'd0, srl_step1[31:12]};
    assign srl_result = shf[4] ? {16'd0, srl_step2[31:16]} : srl_step2;

    // 绠楁湳鍙崇Щ (SRA)
    wire [31:0] sra_step1;
    wire [31:0] sra_step2;
    // 鍒濇鍙崇Щ鏃朵繚鎸佺鍙蜂綅鎵╁睍
    assign sra_step1 = {32{shf_1_0 == 2'b00}} & alu_src2                                 | 
                       {32{shf_1_0 == 2'b01}} & {alu_src2[31], alu_src2[31:1]}           | 
                       {32{shf_1_0 == 2'b10}} & {{2{alu_src2[31]}}, alu_src2[31:2]}      | 
                       {32{shf_1_0 == 2'b11}} & {{3{alu_src2[31]}}, alu_src2[31:3]};
    // 鏍规嵁楂�2浣嶈繘涓€姝ュ彸绉诲苟淇濇寔绗﹀彿鎵╁睍
    assign sra_step2 = {32{shf_3_2 == 2'b00}} & sra_step1                                | 
                       {32{shf_3_2 == 2'b01}} & {{4{ sra_step1[31]}}, sra_step1[31:4]}    | 
                       {32{shf_3_2 == 2'b10}} & {{8{ sra_step1[31]}}, sra_step1[31:8]}    | 
                       {32{shf_3_2 == 2'b11}} & {{12{sra_step1[31]}}, sra_step1[31:12]};
    assign sra_result = shf[4] ? {{16{sra_step2[31]}}, sra_step2[31:16]} : sra_step2;
    // --- 绉讳綅鎿嶄綔 end -------------------------------------------------

    // 鏍规嵁鎺у埗淇″彿閫夋嫨鏈€缁堢殑杩愮畻缁撴灉
    assign alu_result = (alu_add | alu_sub) ? add_sub_result :
                        alu_slt         ? slt_result :
                        alu_sltu        ? sltu_result :
                        alu_and         ? and_result :
                        alu_nor         ? nor_result :
                        alu_or          ? or_result  :
                        alu_xor         ? xor_result :
                        alu_sll         ? sll_result :
                        alu_srl         ? srl_result :
                        alu_sra         ? sra_result :
                        alu_lui         ? lui_result :
                        alu_div         ? div_result : // 添加除法操作
                        32'd0;
endmodule