// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Sat Mar 22 15:06:26 2025
// Host        : wangzhangzhuo running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top inst_rom -prefix
//               inst_rom_ inst_rom_sim_netlist.v
// Design      : inst_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k70tfbv676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "inst_rom,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module inst_rom
   (clka,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [7:0]addra;
  wire clka;
  wire [31:0]douta;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_doutb_UNCONNECTED;
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "8" *) 
  (* C_ADDRB_WIDTH = "8" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.375199 mW" *) 
  (* C_FAMILY = "kintex7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "inst_rom.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "256" *) 
  (* C_READ_DEPTH_B = "256" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "256" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  inst_rom_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[31:0]),
        .eccpipece(1'b0),
        .ena(1'b0),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[7:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[7:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
FPXllyX2NFs/RMngGqZy2bLYbZr92CdofeZrJOHklWXExpaPgHNYp2Lzm4MnflbnrfSkCmLwwKT5
zfRgEip7FKQ5Zhb73p0MAIADixBZ/ZRt4hQkJL0T9brm0waLHfanjnov2aCX6jN3LbQc3ujmDga6
Dd73k78u4xjRTDv1/P4=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kr7VKKvChFoiyRCReag+OvU3jnmG9pN0cv+BxhNmMKLthg/ksgNZyU3L+fQ7cmIQELtlUjwjkBAP
Jjq5RsCnHbJxj+Ys1GNhriiBsxLqxWCP8onhAVvgZN2xZFOih0UWpqlU8NVP8Eww1ohvkDgxTstC
3kDmYehxIUJjqCC/mgRZmuezqugrFdubYmBoz16tUvD17iA5qqCIMS9xSIXYp2LBNekmWEwrVqzu
R4koEo4UlXl/CEw0XY3QvMoHnlXgu6N/6sc+nxZtKSwjiMVvGnZE9UVvJPAC3Hn3zKFGlK53mmGO
Tj0dWzhwX0ahSYzkyJC/HLdbGZmriL2UNvDyFw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
CaLc9FGt3AdRHfNtGAsGFY/QEvHY1Vv4TvvgCDsdDMqiuDeLizFJDJeskBWjeKDoE2cufK8TxiBq
mySRQNJoeOKnxTiDdf+Rx6m0iR6h/YeswegYwgghpM5KVrl6mSwF3+4yEovPM7a+9ArDQ5vl+WT8
SilNGzyW0KnTwe7+szs=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cEnudSW1X71p0Xuq6jrXOxHnBku87IA0RA3zKqmeZHZM0r+9rEm5MSzX8RecnQ994yiqeyxbIH2l
fGEzUzr0ZzryS3fkf2LnJuB39f2YARW9eVCSiaeWaraZuY1l89T+h3vgdlurS/1LIraYLS1MyOXa
6F1LAcQp3W4OO4ctc3q1FRMZGldRS1biMsKwJ8Lxj8NEOm67UfgFrJNQAxbVXEfbWRWhKtwNxcTB
JbgC8j4EHkIA46mzoHloeBAL6KieplQUBjKXSSTb66rxglbFhWLy+mirROHcocu9J4ZbvTRYZEww
4lso1lqAllVLAoKYqa3WImZuSRoTbGDngBt9Lg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rOyI+x4PlmKcVSFoN3oKgSYpVlmYxc194Ej04il/YmBg10xopy4zmtu5sdCP/uGSNYcNGWeAiw01
mNf98KyNgTUFXruHCA38qjhhEIvl4vfWWn3W3mFRxrIuwmnreT6qTvgMaxIkCdVBDP7Iy7O6WmCf
3Va5X5hnCHhtXgX5UYniBHiLjmupv63B8XMAYDH2n6mQ3H0DF7mtb7psBafd0Z6+IWUbmzwMtKrf
ZrRJBGAhNT0i1KrEjEh/rWjN7Z7N32zQ+Pl1kc5gYCQIX5McfdTdqSaRVXZ/HF90ymS7/8d5LDyj
Er+ORdcjnOn6oAyY4PuUUl4OYUHv5k+RglTe5Q==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
bJa7kPSpDipzoJoQu1APEjc8vFLqBfQZK/grZvWijD7/FgMTerFCWLUY6n8DWeGdvjXvTeyrqCHE
2rP/H57wUqPC8tIJlGm6ZYQGjZ3TgYqLrJshDE5zYMTO//q0vuSraWvZP7A7SLuW6y7tFE/nplpx
L8gbYORx6j70okGUwnamCMS9yhFr7Z2QTJne1k4GNFGvy66URk3k5cBPl5j4/1yc4xGV+aWYl6L8
q8RorRU/CltObHKrji/jdiY1WtdGrkpRyCEFc+XNPazL9xSLLu5bz6XlvKwoks+8a5KYT/VFUovM
JbM0bpAXM8Z7rGaPuXjqXtZBg5praTZLu/WNcA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PYKBDinOGc/kIVdFzXrz2wA4/QNFxLDrQfTWfR5TjYE6bm49vrZi0bawcr9HXp4OP1+XxPLB3oCP
oV5e/rYeDln531ebt8yEg27XCoSHEX4FU8oG8aBJ8fqgWayOnAMJt025WodOxuZXbhT1zPo7J3uh
6iO9Mv7RtYE2fZ1W+G8oN//FTOEJYPWlKYnt0cDeZrN3I4rHHptZHuu7l8T+df0PYea3x6U3Mvkl
ojZ+TwQtdu0NuYY5j3QNgx3+W2XYq1M773FAnEz/deW54EjE+jf1jjrBk2pl8SYxeKuutS15oPVF
eHdqXYVcJxoUY5JH8z04lITKEnZ4oq6sYS6dog==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
tl+2vFCWZ583gQGsVC7oopz2NCKBiJ9uOHYBGzJZheOHJMqI/ehNvo25l710eBx00tztXzM30AH6
ZhAJg+kJwE2jO0MV5fmG5dnwXmLqoGEJMBs7xwWxvYK7w/0z9M0AJKD7HnuC+IiLhNU/fIxyuE+I
+vWqp//RcfY0tMMp2I2J1yEW6GUahS1ve/4JchssZ7Xu7VthoSDWXMQWATbvsUsDzeSo2+Ruz8Kq
Dc05HqEU8NgBxDPPEKLCcdKLp4byglwj7iCAtCjsPy8P18qjgb2sycFjNgmaiNMMB51WqeD+hneG
hLOue9bqVdEojkrb3q4WbsGZKz0bAGsryxslOlYHP1b8vey3yI2ixA80wyERe8d3GRIeZiSxGykH
qWxsE6x/iyi8QRb5mXZPMApA+Fln8tYmn7+1rFCm8gF4gJWhr1PsSJqTi658symGrzT0Ghjvf2QL
SvvoaeNdy0pOsWs7jLBFndd4GiFA+9K6Y33sziLToU9EvvFokENIslod

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oYiCujFRj1F3wKsGZlHR9niEtR9MLXEVAVfy+f/3xrmpW6Ye5a+fBCvm4TH+iRQefGHNdMPnzTNW
K/pEPAS9uMJjOdFiu+APT+LYrSRnEg4W0dX5buSDGM6LBWAuMseoTMjbJJoYDGLRckJgW43E30mX
ej4823nkbfwc+Ecbrup825qLyv8RTQLNHafvJA5lSapdqXwnlOIYRmcHn+sfAh5pGv9kW9aokcdh
ObR2XYxX99rYloyvz3x0pmjxD5ILW4SQMB1IUEuuyqX6eb5IQ+kZ41hjvsHIuQH29vzpCfV9Jqha
WC5yxxK1R+cleZSKD1H1gVzbTei8uFs/91Bgeg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
urNc+S8AFPj+GVFdqJE5V7P8O6QI6MA3nkwYb8NKbYbVufnXKg6voJIRYYeYr7EOa8mrqirozWbY
Lln9SLWnkaAy2LvL/N6WahoQdCt++4RH+xe768XvSrVUFPrIwZRixqMLurc/tPov4i5P/ukZKl18
ZPZvXRzUNlvCZnMPcF+5QCQihqPbjcZ0YyGgWgX/ipTGG3sNqmylGN7qLa4Rgqu/mB5a2xVyu5Wc
911+/X3VVFx697WVaP5V0SbOzYN8R8+8B8kdznwixMA+f4lSbBXyRysVOSzYjo8bKEMqyKMVBQn9
xDmEuV0DvVWXdO7VPvWA1LuJFwS07OxeI2GCcQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QcP7fsLZxaDrG29e9HQeXfu2TsKsdyW7Yc1vWct6lbmDEfXkWMU1fFWSPIjPzRc9UOnfEu0bRn+B
D+8MWokqes3WF7txljBmgUPiNGZ8arUU6ENa/IY/Wv7iaB/ZKM5PtdnFAkjDIrYyKFCTz/U6Yzwi
hBGGarK/wYQOLzeeKRewiPTiNUL7tztWuMZ1t1msxD951EeKrwjrjcXIIuf/TzrOGUOlWgjHlnrl
4Q/lfMAnRLBNTSWG+5wWewCE8jK2X/gJ5AV4p3x1WP3+JglbxpP39l3pzedXqciZPbuz2XlFnRPV
KByaUaAShzJ56p8+0HjWebibqQdieGNPiPWW0Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 18560)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
