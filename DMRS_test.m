%% test DMRS signal
clc;
close all;

%allFolds = genpath( pwd );
addpath('./RX_MATLAB');
addpath('./OFDM_STOCFO','./tools','nr_codec','nr_phy');
t=now;
datestr(t,0)

%% const
global Debug_view Debug_view_Freq Debug_view3D Debug_view_constellation Debug_slotSTO_CFO Debug_slotSTO_CFO_More Debug_slotSTO_CFO_symblo_diff
global  Debug_InitSync
Debug_InitSync=1;

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
load('pusch_270RB_cid174.mat');
data_timeTem=pusch_270RB_cid174.waveform.';
%% get pusch signal for test
upSlot=8;
PosLen= (1:61440 + 2048);
PosSlotOffset=upSlot*len_ts_per_slot;
PosView=PosLen+PosSlotOffset;
%PosView = (1:61440 + 2048) + ((61440 + 2048)*3+8192)*5 + ((61440 + 2048)*3)*3; % 20M
% PosView = (1:61440 + 2048) + ((61440 + 2048 + 8192)*3)*7 + ((61440 + 2048)*3)*3; % 100M
% should be format to (1:4096,1)
ViewData  = data_timeTem(PosView).';


%% get DMRS standard signal
CellID=174;
nLayer=1;
[DMRSDataFrq,DMRSDataTime,DMRSDataSN]=GenAllSlotDMRS(CellID,nLayer);

%% get syn position
[SyncPos,FreqOffset]=InitSync(ViewData,DMRSDataTime,nLayer);


