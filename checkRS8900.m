%% check RS device Data
%% load data
clear;
clc;
close all;

%allFolds = genpath( pwd );
addpath('./RX_MATLAB');
addpath('./OFDM--STO-CFO');
t=now;
datestr(t,0)

global Debug_view Debug_view_Freq Debug_view3D Debug_view_constellation Debug_slotSTO_CFO Debug_slotSTO_CFO_More Debug_slotSTO_CFO_symblo_diff
global Debug_SlotSep

len_IQ=1;
len_slot=14;
len_scp=288;
len_lcp=352;
len_fft=4096;
prb_len=3276;
len_sym=len_scp+len_fft;
len_shift_cp=len_lcp-len_scp;

SearchLen=2*len_lcp;

OFDMParam.len_IQ=len_IQ;
OFDMParam.len_slot=len_slot;
OFDMParam.len_scp=len_scp;
OFDMParam.len_lcp=len_lcp;
OFDMParam.len_fft=len_fft;
OFDMParam.prb_len=prb_len;
OFDMParam.SearchLen=SearchLen;
%% load RS8900 input data
%load caps.mat
%load matlab1029.mat
%load './cap_data/matlab4.mat'
view_freq=0;
view_time=1;
view_time_detail=0;
view_timesignal_upslot_freq=1;
view_caps=0;
view_last=0;
Debug_SlotSep=1;

%tF='/mnt/oran/L1/chendalong/0927_1114/t0_ddr_data.txt'; % in shelf box
%tF='~/Downloads/t5_ddr_data.txt'; % in shelf box,10m,bin format,1 stream
fF='~/Downloads/f0_ddr_data.txt'; % in shelf box,10m,bin format
tF='./File.iq/File_2021-10-08090021.complex.1ch.float32';
tF='/Volumes/ORAN/L1/chendalong/1011_1848/t1_ddr_data.txt'; % in shelf box,0.1m,2 stream

EU_or_RS8960=1;
Debug_view=0;
Debug_slotSTO_CFO=1;
Debug_slotSTO_CFO_More=0;
Debug_slotSTO_CFO_symblo_diff=1;
Debug_view_Freq=1;
Debug_view3D=1;
Debug_view_constellation=1;

%% read Data from RS
if EU_or_RS8960 ==1
    tAntData=readDDRBinData(tF,1);
    cpx=tAntData(:,1);
else
    [cpx]=ReadRSDataFloat32(tF);
end
[b_pos_edge,slot_sep_length,slot_blank_length]=Process1msSep(cpx);
Ant_view=cpx(b_pos_edge(1):end);

%% start process sto
[slot_sto_diff]=Process1msSignalSto(Ant_view);
