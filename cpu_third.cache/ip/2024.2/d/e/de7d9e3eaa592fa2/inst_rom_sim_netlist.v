// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
// Date        : Sat Mar 22 15:06:26 2025
// Host        : wangzhangzhuo running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ inst_rom_sim_netlist.v
// Design      : inst_rom
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k70tfbv676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "inst_rom,blk_mem_gen_v8_4_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_9,Vivado 2024.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_9 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 18928)
`pragma protect data_block
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
Awy5aQ==
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
