function [DMRSData]=GenAllSlotDMRS(CellID,nLayer)
%% generate Slot DMRS signal and save it to mat
% function [DMRSData]=GenAllSlotDMRS(CellID,nLayer
% DMRSData is 3276*14*20 Complex Data
if nargin==0
    CellID=174;
    nLayer=2;
elseif nargin==1
    nLayer=2;
end

nPRB=273;
nSC=12;
nSymb=14;
nSlot=20;

N_nSCID_ID = CellID;
%N_nSCID_ID belong to {0,65535} get from uplayer ncellid = 42;
nSCID=0;
%belong{0,1} nSCID
RBMax = nPRB;

DMRSData=zeros(nPRB*nSC,nSymb,nSlot);
portnumber = nLayer;%nrSRSParameters.sysConst.NSRS_ap;

for indexSlotInFrame=0:nSlot-1
    for DMRSSymbolPos = 1:nSymb
        base_seq = DMRS_base_seq_generation(indexSlotInFrame, ...
            DMRSSymbolPos, nSCID, N_nSCID_ID, RBMax);
    end
    
    dlDMRSSignal = zeros(length(base_seq), portnumber);
    index_dlDMRS = zeros(length(base_seq), portnumber);
    even_index = 2:2:length(base_seq);
    odd_index = 1:2:length(base_seq);
        
    for portnumber_i=1:portnumber
        dlDMRSSignal(even_index,portnumber_i) = nrSRSParameters.port1000_table.w_k_1(portnumber_i)*base_seq(even_index);
        dlDMRSSignal(odd_index,portnumber_i) = nrSRSParameters.port1000_table.w_k_0(portnumber_i)*base_seq(odd_index);
    end
    
end

if ismember(l, l_dmrs)
    r_dmrs = nr_38_211_sch_dmrs_gen_symbol(n_PRB_start, n_PRB_sched, N_layer, antenna_ports, tpmi, slot_num, l, higher_layer_params.UL_DMRS_config_type, higher_layer_params.PUSCH_tp, higher_layer_params.UL_DMRS_Scrambling_ID(2), higher_layer_params.UL_DMRS_Scrambling_ID(1));
    for ap = 1 : N_ap
        k_dmrs = nr_38_211_sch_dmrs_re_mapping(n_PRB_start, n_PRB_sched, higher_layer_params.UL_DMRS_config_type, antenna_ports(ap));
        a(k_dmrs+1,l+1,ap) = r_dmrs(:,ap);
    end
else
    for ap = 1 : N_ap
        a(k,l+1,ap) = z(z_idx:z_idx+n_PRB_sched*frame_cfg.N_sc_RB-1,ap);
    end
    z_idx = z_idx + n_PRB_sched*frame_cfg.N_sc_RB;
end

end