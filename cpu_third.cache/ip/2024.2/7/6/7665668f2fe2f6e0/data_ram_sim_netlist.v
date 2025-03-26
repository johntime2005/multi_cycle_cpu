// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Sat Mar 22 15:07:21 2025
// Host        : wangzhangzhuo running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ data_ram_sim_netlist.v
// Design      : data_ram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k70tfbv676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "data_ram,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_9 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 28352)
`pragma protect data_block
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
67QbQlfaBx/Nm+yRzV3t3Zf5rxk+3Lk=
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
