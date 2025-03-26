`timescale 1ns / 1ps
//*************************************************************************
//   > ������: mem.v
//   > �`�q  : ������CPU�I?����?
//   > ���  : LOONGSON
//   > ����  : 2016-04-14
//*************************************************************************

module mem(
    // ��{??�a?��
    input              clk,          // ??�M��
    input              MEM_valid,    // ?��?�L���M��(��?���L��)
    
    // ����?�s?�i�I??
    input      [105:0] EXE_MEM_bus_r, // EXE->MEM??(��܍T���M���a����)
    
    // ������?��ڌ�
    input      [ 31:0] dm_rdata,     // ��������?��?��I����
    output     [ 31:0] dm_addr,      // ������?��??�n��
    output reg [  3:0] dm_wen,       // ������?��ʎg�\(��?�g�\)
    output reg [ 31:0] dm_wdata,     // �ʓ�������?��I����
    
    // ����?�T���M��
    output             MEM_over,     // MEM?�i?�s�����M��
    output    [ 69:0]  MEM_WB_bus,   // MEM->WB??(??���ʉ�?�i�I�M��)
    
    // ???�o
    output     [ 31:0] MEM_pc        // ���O�w��PC?(�p��??)
);

//================================ EXE->MEM??���� ================================
// ??��܈ȉ����i(�����ʓ����?��):
// [105:102] - mem_control : ?���T���M��
// [101:70]  - store_data  : ��?����
// [69:38]   - alu_result  : ALU?�Z?��
// [37]      - rf_wen      : �񑶊핶���ʎg�\
// [36:32]   - rf_wdest    : �񑶊핶���ʓ��n��
// [31:0]    - pc          : ���O�w��PC?

wire [3 :0] mem_control;  // ?���T���M��
wire [31:0] store_data;   // ��?����
wire [31:0] alu_result;   // ALU?�Z?��
wire        rf_wen;       // �񑶊핶���ʎg�\
wire [4:0] rf_wdest;      // �񑶊핶���ʓ��n��
wire [31:0] pc;           // ���O�w��PC?

assign {
    mem_control,
    store_data,
    alu_result,
    rf_wen,
    rf_wdest,
    pc
} = EXE_MEM_bus_r;

//============================= ?���T���M������ =============================
wire inst_load;   // load�w��?�u
wire inst_store;  // store�w��?�u
wire ls_word;     // ???�x(0:��?, 1:��)
wire lb_sign;     // ��?��?����?�W?�u(1:�L����, 0:�ٕ���)

assign {
    inst_load,
    inst_store,
    ls_word,
    lb_sign
} = mem_control;

//============================= ��?��???? ==============================

// ��?��n��(���ڎg�pALU?�Z?��)
assign dm_addr = alu_result;

// ��?��ʎg�\����??(?��??)
always @ (*) begin
    if (MEM_valid && inst_store) begin // �L��?����������store�w��
        if (ls_word) begin
            dm_wen <= 4'b1111; // ����?(4��?�S���g�\)
        end
        else begin // ��?��?(�����n����2��??�g�\��?)
            case (dm_addr[1:0])
                2'b00: dm_wen <= 4'b0001; // ��?0
                2'b01: dm_wen <= 4'b0010; // ��?1
                2'b10: dm_wen <= 4'b0100; // ��?2
                2'b11: dm_wen <= 4'b1000; // ��?3
                default: dm_wen <= 4'b0000;
            endcase
        end
    end
    else begin
        dm_wen <= 4'b0000; // ��store�w��?�֎~�ʓ�
    end
end

// ��?��ʐ�������(?��??)
always @ (*) begin
    if (ls_word) begin
        dm_wdata <= store_data; // ����?���ڎʓ�
    end
    else begin // ��?��?���v������������?�I��?�ʒu
        case (dm_addr[1:0])
            2'b00: dm_wdata <= store_data;
            2'b01: dm_wdata <= {16'd0, store_data[7:0], 8'd0};
            2'b10: dm_wdata <= {8'd0, store_data[7:0], 16'd0};
            2'b11: dm_wdata <= {store_data[7:0], 24'd0};
            default: dm_wdata <= store_data;
        endcase
    end
end

//============================= ��?����?��?? ==============================

// ��?�����I������??
wire load_sign;
assign load_sign = (dm_addr[1:0]==2'd0) ? dm_rdata[7] :
                  (dm_addr[1:0]==2'd1) ? dm_rdata[15] :
                  (dm_addr[1:0]==2'd2) ? dm_rdata[23] : 
                  dm_rdata[31];

// ��?�����I��???
wire [31:0] load_result;
assign load_result[7:0] = (dm_addr[1:0]==2'd0) ? dm_rdata[7:0] :
                         (dm_addr[1:0]==2'd1) ? dm_rdata[15:8] :
                         (dm_addr[1:0]==2'd2) ? dm_rdata[23:16] :
                         dm_rdata[31:24];

// ��?�����I����?��(����?�W����?�W)
assign load_result[31:8] = ls_word ? dm_rdata[31:8] : // ����?���ڎ捂��
                          {24{lb_sign & load_sign}}; // ��?��??����?�W

//============================= ?��?�i�����M�� ==============================

// �R����?��??�\���v���������C��?��load������v���Ґ����ԉ�
// ?���g�pMEM_valid_r��??�O�������?
reg MEM_valid_r;
always @(posedge clk) begin
    MEM_valid_r <= MEM_valid;
end

// load������v?����������(?�o�n���a�ڝ�����)
// ��������(�@store�aALU����)�꘢��������
assign MEM_over = inst_load ? MEM_valid_r : MEM_valid;

//============================= MEM->WB???�� ==============================

// ??�ʉ񐔐�: load�w�ߎg�p��?�퐔���C�����w�ߎg�pALU?��
wire [31:0] mem_result;
assign mem_result = inst_load ? load_result : alu_result;

// MEM->WB??��܈ȉ����i(�����ʓ����):
// [69]      - rf_wen     : �񑶊핶���ʎg�\
// [68:64]   - rf_wdest   : �񑶊핶���ʓ��n��
// [63:32]   - mem_result : �ʉ񐔐�(��?�툽ALU?��)
// [31:0]    - pc         : ���O�w��PC?(�p��??�a?��?��)
assign MEM_WB_bus = {
    rf_wen,
    rf_wdest,
    mem_result,
    pc
};

//============================= ???�o ==============================

// ?�o���OPC?�p��??
assign MEM_pc = pc;

endmodule