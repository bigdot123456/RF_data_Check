function [nrSRSIndex, nrSRSseq_pi] = nrSRSMapping(SRS_Resource, sysConst)
%nrSRSMapping
%   detailed algorithm and parameters of SRS RE mapping based on 38.211-6.4.1.4.3
%   input are SRS-Resource parameters from BWP-UplinkDedicated
%   nRRC: SRS-Resource.freqDomainPosition 
%   b_hop: SRS-Resource.freqHopping
%   bSRS:   SRS-Resource.freqHopping
%   cSRS:   SRS-Resource.freqHopping
%   nshift: SRS-Resource.freqDomainShift
%   KTC:    SRS-Resource.transmissionComb

nRRC    = SRS_Resource.freqDomainPosition;
b_hop   = SRS_Resource.freqHopping.b_hop;
bSRS    =   SRS_Resource.freqHopping.bSRS;
cSRS    = SRS_Resource.freqHopping.cSRS;
nshift  = SRS_Resource.freqDomainShift;
ncsSRS  =  SRS_Resource.transmissionComb.combOffset;
KTC     =  SRS_Resource.transmissionComb.n2n4;

NSRS_ap = sysConst.NSRS_ap;    %up tp configuration
pi      = sysConst.pi; %1001~1003
NRB_SC  = sysConst.NRB_SC;

%% ---------------------------------------------------------------------------------------------------------------------
%%% ---below paser SRS-Config.SRS-Resource for SRS mapping 
% get hopping table based on SRS Resource hopping parameters
[mSRS_b, Nb] = mSRSb_Nb_table(bSRS, cSRS);

% The length of the sounding reference signal sequence is given by
% M_("sc" ,b)^"SRS" =(m_("SRS" ,b) N_"sc" ^"RB" )?K_"TC"  
MSRS_SC_b = mSRS_b * NRB_SC/KTC;

% If b_hop >= bSRS frequency hopping is disabled and the frequency position index   remains constant (unless re-configured) and is defined by
% else frequency hopping is enabled and the frequency position indices   are defined by
if b_hop < bSRS
    nb = mod(floor(nRRC*4/mSRS_b), Nb);
else
    nb = mod(floor(nRRC*4/mSRS_b), Nb);
end
%----notes: nb is difficut to compute, now ignore  @(F_b (n_"SRS"  )+?(4n_"RRC" )?m_("SRS" ,b) ?)" mod " N_"b" &"otherwise" )
%----ignore b_hop<bSRS but b_hop>b(bSRS)
    
%%The frequency-domain starting position k_0^((p_i)) is defined by 
%%k_0^((p_i))=k ?_0^((p_i))+¡Æ_(b=0)^(B_"SRS" )?¡¼K_"TC"  M_("sc" ,b)^"SRS"  n_b ¡½
% where ncsSRS is contained in the higher layer parameter transmissionComb. 
% The maximum number of cyclic shifts n_"SRS" ^"cs,max"  are given by Table 6.4.1.4.2-1.
% Maximum number of cyclic shiftsas a function of K_"TC"[2,4,8] .
ncsSRS_max_table = [8,12,6];  

% k ?_0^((p_i))=n_"shift"  N_"sc" ^"RB" +(k_"TC" ^((p_i))+k_"offset" ^(l^' ) )" mod " K_"TC" %just support [2.4]
% k_"TC" ^((p_i))= (k ?_"TC" +K_"TC" ?2)" mod " K_"TC" 
%                  k ?_"TC" 
k__TC_table = (0:KTC-1);
if ncsSRS > (ncsSRS_max_table(KTC/2) - 1)  && NSRS_ap == 4 && pi < 1004
    k_pi_TC = mod((k__TC_table(nb+1) + (KTC/2)), KTC);
else
    k_pi_TC = k__TC_table(nb+1) ;
end

% ¡Æ_(b=0)^(B_"SRS" )?¡¼K_"TC"  M_("sc" ,b)^"SRS"  n_b ¡½
Sigma_BSRS = 0;
for b = 0:bSRS
    [MSRS_SC_b0,~] = mSRSb_Nb_table(b, cSRS);
    Sigma_BSRS = Sigma_BSRS + KTC*MSRS_SC_b0*nb;
end

% Table 6.4.1.4.3-2: The offset k_"offset" ^(l^' ) for SRS as a function of K_"TC"  and l'.
N_symb_SRS = 1;
if N_symb_SRS > 1
    if N_symb_SRS == 2	
        k_l_offset_t =...
            [0,1	
             0, 2];
    end
    if N_symb_SRS == 4
        k_l_offset_t =...
            [0, 1, 0, 1
             0, 2, 1, 3];

    end
    k_l_offset = k_l_offset_t(KTC/2, l);
else
    k_l_offset = 0;
end

% k_0^((p_i))=k ?_0^((p_i))+¡Æ_(b=0)^(B_"SRS" )?¡¼K_"TC"  M_("sc" ,b)^"SRS"  n_b ¡½
k__0_pi = nshift*NRB_SC + mod((k_pi_TC+k_l_offset), KTC);
k_0_pi = k__0_pi + Sigma_BSRS;

% generate the mapping index
nrSRSIndex = k_0_pi + (0:KTC:mSRS_b * NRB_SC-1) + 1;

%% ---------------------------------------------------------------------------------------------------------------------
%%% ---------------------------------------------------------------------------------------------------------------------
%%% ---below paser SRS-Config.SRS-Resource for SRS sequence generation 
ncsSRS_pi = mod((ncsSRS+(ncsSRS_max_table(KTC/2)*(pi-1000))/NSRS_ap), ncsSRS_max_table(KTC/2));
alpha = 2*pi.*ncsSRS_pi/ncsSRS_max_table(KTC/2);
u = 0;
v = 0;
nrSRSseq_pi = nrLowPAPRS(u,v,alpha,MSRS_SC_b);

end
