%% test DMRS signal
close all;
clear;
%clc;

%allFolds = genpath( pwd );
addpath('./RX_MATLAB');
addpath('./OFDM_STOCFO','./tools','nr_codec','nr_phy');
t=now;
datestr(t,0)

%% const
global Debug_view Debug_view_Freq Debug_view3D Debug_view_constellation Debug_slotSTO_CFO Debug_slotSTO_CFO_More Debug_slotSTO_CFO_symblo_diff
global  Debug_InitSync
Debug_InitSync=1;
Debug_view=0;
Debug_slotSTO_CFO=0;
Debug_slotSTO_CFO_More=0;
Debug_slotSTO_CFO_symblo_diff=0;
Debug_view_Freq=1;
Debug_view3D=0;
Debug_view_constellation=1;

len_IQ=1;
len_slot=14;
len_scp=288;
len_lcp=352;
len_fft=4096;
prb_len=3276;
len_sym=len_scp+len_fft;
len_shift_cp=len_lcp-len_scp;
len_ts_per_slot=61440;

SearchLen=2*len_lcp;

OFDMParam.len_IQ=len_IQ;
OFDMParam.len_slot=len_slot;
OFDMParam.len_scp=len_scp;
OFDMParam.len_lcp=len_lcp;
OFDMParam.len_fft=len_fft;
OFDMParam.prb_len=prb_len;
OFDMParam.SearchLen=SearchLen;
%% load data
%load('pusch_270RB_cid174.mat');
%tAntData=pusch_270RB_cid174.waveform;

load('pusch175.mat');
tAntData=pusch1L_Cell175_Ideal.waveform;
tAntData=pusch2L_Cell175_Ideal.waveform;
tAntData=pusch2L_Cell175_SNR20.waveform;

tF='/Volumes/ORAN/L1/chendalong/1019_0952/t2_ddr_data.txt'; % in shelf box,0.1m,4 ant 1 stream
tF='/Volumes/ORAN/L1/chendalong/1030_1606/t0_ddr_data.txt'; % in shelf box,0.1m,2 ant 1 stream

view_time=1;
view_freq=0;

%RS8900=1; % 1: use R&S instrument,0: EU get data
Bin_or_TXT=1; % 1: binary,0:txt
if view_freq==1
    if Bin_or_TXT==1
        fAntData=readDDRBinData(fF,0);
    else
        fAntData=readDDRData(fF,0);
    end
end

if view_time==1
    if Bin_or_TXT==1
        tAntData=readDDRBinData(tF,1);
    else
        tAntData=readDDRData(tF,1);
    end
end


%% test CellID
upSlot=8;
nLayer=2;
for i=175%0:1023
    CellID=i;
    fprintf('Be careful: CellID %d must be correct with dmrs!\n',CellID);

    [SyncSlotPos,SyncSlotInnerPos,posDMRSOffset,FreqOffset]=checkUpSlot(tAntData(:,:),upSlot,CellID,nLayer);
    [SyncSlotPos,SyncSlotInnerPos,posDMRSOffset,FreqOffset]=checkUpSlot2Ant(tAntData,upSlot,CellID);
end
% %% get pusch signal for test
% upSlot=8;
% posDMRS=3;
% PosLen= (1:61440 + 2048);
% PosSlotOffset=upSlot*len_ts_per_slot;
% PosView=PosLen+PosSlotOffset;
% %PosView = (1:61440 + 2048) + ((61440 + 2048)*3+8192)*5 + ((61440 + 2048)*3)*3; % 20M
% % PosView = (1:61440 + 2048) + ((61440 + 2048 + 8192)*3)*7 + ((61440 + 2048)*3)*3; % 100M
% % should be format to (1:4096,1)
% ViewData  = data_timeTem(PosView).';
%
%
% %% get DMRS standard signal
% CellID=174;
% nLayer=1;
% [DMRSDataFrq,DMRSDataTime,DMRSDataSN]=GenAllSlotDMRS(CellID,nLayer);
%
% %% get syn position
%
% [SyncSlotPos,SyncSlotInnerPos,FreqOffset]=InitSync(ViewData,DMRSDataTime,nLayer);
% posDMRSBest=PosSlotOffset+SyncSlotInnerPos;
% posDMRSBestTheory=PosSlotOffset+(posDMRS-1)*(len_fft+len_scp)+len_lcp+1;
% posDMRSOffset=posDMRSBest-posDMRSBestTheory;
% fprintf('DMRS ideal pos:%d,alg search result %d,offset:%d\n',posDMRSBestTheory,posDMRSBest,posDMRSOffset);


