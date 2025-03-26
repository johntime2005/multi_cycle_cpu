// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Sat Mar 22 15:07:21 2025
// Host        : wangzhangzhuo running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top data_ram -prefix
//               data_ram_ data_ram_sim_netlist.v
// Design      : data_ram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k70tfbv676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "data_ram,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module data_ram
   (clka,
    wea,
    addra,
    dina,
    douta,
    clkb,
    web,
    addrb,
    dinb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [3:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_mode = "slave BRAM_PORTB" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [3:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [7:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [31:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [31:0]doutb;

  wire [7:0]addra;
  wire [7:0]addrb;
  wire clka;
  wire clkb;
  wire [31:0]dina;
  wire [31:0]dinb;
  wire [31:0]douta;
  wire [31:0]doutb;
  wire [3:0]wea;
  wire [3:0]web;
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
  (* C_BYTE_SIZE = "8" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     5.9299 mW" *) 
  (* C_FAMILY = "kintex7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "0" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "1" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "1" *) 
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
  (* C_INIT_FILE = "data_ram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
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
  (* C_USE_BYTE_WEA = "1" *) 
  (* C_USE_BYTE_WEB = "1" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "4" *) 
  (* C_WEB_WIDTH = "4" *) 
  (* C_WRITE_DEPTH_A = "256" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  data_ram_blk_mem_gen_v8_4_9 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
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
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 27984)
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
