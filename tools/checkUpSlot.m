function [SyncSlotPos,SyncSlotInnerPos,posDMRSOffset,FreqOffset]=checkUpSlot(data_timeTem,upSlot,CellID,nLayer)
%% get pusch signal for test
% [SyncSlotPos,SyncSlotInnerPos,posDMRSOffset,FreqOffset]=checkUpSlot(data_timeTem,upSlot,CellID,nLayer)
% posDMRSOffset is key parameter
%
if nargin<4
    nLayer=2;
end

if nargin<3
    CellID=174;
end

if nargin<2
    upSlot=8;
end

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
%% caculate ts length for check up slot
posDMRS=3;
PosLen= (1:61440 + 2048);
PosSlotOffset=upSlot*len_ts_per_slot;
PosView=PosLen+PosSlotOffset;
%PosView = (1:61440 + 2048) + ((61440 + 2048)*3+8192)*5 + ((61440 + 2048)*3)*3; % 20M
% PosView = (1:61440 + 2048) + ((61440 + 2048 + 8192)*3)*7 + ((61440 + 2048)*3)*3; % 100M
% should be format to (1:4096,1)

%% get DMRS standard signal
[DMRSDataFrq,DMRSDataTime,DMRSDataSN]=GenAllSlotDMRS(CellID,nLayer);

%% get syn position
% first use tradditonal check, second should swap antenal to check
ViewDataNoraml  = data_timeTem(PosView,:);
[SyncSlotPos,SyncSlotInnerPos,FreqOffset]=InitSync(ViewDataNoraml,DMRSDataTime,nLayer);
posDMRSBest=PosSlotOffset+SyncSlotInnerPos;
posDMRSBestTheory=PosSlotOffset+(posDMRS-1)*(len_fft+len_scp)+len_lcp+1;
posDMRSOffset=posDMRSBest-posDMRSBestTheory;
fprintf('DMRS ideal pos:%d,alg search result %d,offset:%d\n',posDMRSBestTheory,posDMRSBest,posDMRSOffset);
% swap antennal
if nLayer==2
    ViewDataAddtional(:,1)  = data_timeTem(PosView,2);
    ViewDataAddtional(:,2)  = data_timeTem(PosView,1);
    
    [SyncSlotPos,SyncSlotInnerPos,FreqOffset]=InitSync(ViewDataAddtional,DMRSDataTime,nLayer);
    posDMRSBest=PosSlotOffset+SyncSlotInnerPos;
    posDMRSBestTheory=PosSlotOffset+(posDMRS-1)*(len_fft+len_scp)+len_lcp+1;
    posDMRSOffset=posDMRSBest-posDMRSBestTheory;
    fprintf('Additional DMRS ideal pos:%d,alg search result %d,offset:%d\n',posDMRSBestTheory,posDMRSBest,posDMRSOffset);
end