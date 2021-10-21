function [DMRSDataFrq,DMRSDataTime,DMRSDataSN]=GenAllSlotDMRS(CellID,nLayer)
%% generate Slot DMRS signal and save it to mat
% function [DMRSDataFrq,DMRSDataTime,DMRSDataSN]=GenAllSlotDMRS(CellID,nLayer)
% DMRSData is 3276*14*20 Complex Data
if nargin==0
    CellID=174;
    nLayer=2;
elseif nargin==1
    nLayer=2;
end

nFFT=4096;
nPRB=273;
nSC=12;
nSymb=14;
nSlot=20;

N_nSCID_ID = CellID;
%N_nSCID_ID belong to {0,65535} get from uplayer ncellid = 42;
nSCID=0;
%belong{0,1} nSCID
RBMax = nPRB;

% only 1632=3276/2 sc
DMRSLen=nPRB*nSC/2;
DMRSDataSN=zeros(DMRSLen,nSymb,nSlot);
DMRSDataFrq=zeros(DMRSLen,nSymb,nSlot);
DMRSDataTime=zeros(nFFT,nSymb,nSlot,nLayer);

%fact = SimParam.MaxSCS/SimParam.SCS;
%RB_shift = SimParam.SCS_k0-SimParam.MAXRBNUM*6 + FFTLen/2;
RB_shift = -RBMax*6 + nFFT/2;
DMRSPos = RB_shift +1: 2 :RB_shift + DMRSLen *2;
%pos=1:nPRB*nSC/2;
%% only valid for port 1000, 1002

for indexSlotInFrame=1:nSlot
    for DMRSSymbolPos = 1:nSymb
        % DMRS_base_seq_generation use base-1
        [base_seq,base_sn] = DMRS_base_seq_generation(indexSlotInFrame, ...
            DMRSSymbolPos, nSCID, N_nSCID_ID, RBMax);
        DMRSDataFrq(:,DMRSSymbolPos,indexSlotInFrame)=base_seq;
        DMRSDataSN(:,DMRSSymbolPos,indexSlotInFrame)=base_sn;
        DMRSDataTimeFFTIn=zeros(nFFT,nLayer);
        
        for Layer=1:nLayer
            posLayer=(Layer-1)+DMRSPos;
            DMRSDataTimeFFTIn(posLayer,Layer)=base_seq;
            DMRSDataTime0= ifft(fftshift(DMRSDataTimeFFTIn(:,Layer)));
            DMRSDataTime(:,DMRSSymbolPos,indexSlotInFrame,Layer)=DMRSDataTime0;
        end
    end
end

% r_dmrs = nr_38_211_sch_dmrs_gen_symbol(n_PRB_start, n_PRB_sched, N_layer, antenna_ports, tpmi, slot_num, l, higher_layer_params.UL_DMRS_config_type, higher_layer_params.PUSCH_tp, higher_layer_params.UL_DMRS_Scrambling_ID(2), higher_layer_params.UL_DMRS_Scrambling_ID(1));
% for ap = 1 : N_ap
%     k_dmrs = nr_38_211_sch_dmrs_re_mapping(n_PRB_start, n_PRB_sched, higher_layer_params.UL_DMRS_config_type, antenna_ports(ap));
%     a(k_dmrs+1,l+1,ap) = r_dmrs(:,ap);
% end

end