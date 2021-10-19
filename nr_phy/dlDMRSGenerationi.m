function [dlDMRSSignal, index_dlDMRS] = dlDMRSGenerationi(nrSRSParameters)
% % 38.211-7.4.1.1
% % Higher Layer Parameter
% % Value
% % Comment
% % 
% % DL-DMRS-Scrambling-ID
% % {0,1}
% % Sequence Generation
% % 
% % DL-DMRS-Scrambling-ID
% % {0,1,..,65535}
% % Sequence Generation
% % Configuration Type
% % DL-DMRS-config-type 
% % dmrs-Type
% % type1, type2
% % RE Mapping
% % 
% % DL-DMRS-typeA-pos
% % dmrs-TypeA-Position
% % pos2, pos3
% % RE Mapping
% %  
% % DL-DMRS-add-pos
% % dmrs-AdditionalPosition
% % pos0, pos1, pos2, pos3
% % RE Mapping
% %  
% % DL-DMRS-max-len
% %  
% % RE Mapping
% % single or double symbol
 
indexSlotInFrame = 0; 
RBMax = 273;
%belong{0,1} nSCID
nSCID = 0; 
%N_nSCID_ID belong to {0,65535} get from uplayer ncellid = 42;
N_nSCID_ID = 42;
DMRSSymbolPos = 3;
base_seq = DMRS_base_seq_generation(indexSlotInFrame, ...
    DMRSSymbolPos, nSCID, N_nSCID_ID, RBMax);
even_index = 2:2:length(base_seq);
odd_index = 1:2:length(base_seq);
portnumber = nrSRSParameters.sysConst.NSRS_ap;
dlDMRSSignal = zeros(length(base_seq), portnumber);
index_dlDMRS = zeros(length(base_seq), portnumber);
for portnumber_i=1:portnumber
     dlDMRSSignal(even_index,portnumber_i) = nrSRSParameters.port1000_table.w_k_1(portnumber_i)*base_seq(even_index);
     dlDMRSSignal(odd_index,portnumber_i) = nrSRSParameters.port1000_table.w_k_0(portnumber_i)*base_seq(odd_index);
end
for portnumber_i=1:portnumber
    if nrSRSParameters.port1000_table.delta(portnumber_i) == 0
        index_dlDMRS(:,portnumber_i) = 1:2:2*length(base_seq);
    else
        index_dlDMRS(:,portnumber_i) = 2:2:2*length(base_seq);
    end
end
end

