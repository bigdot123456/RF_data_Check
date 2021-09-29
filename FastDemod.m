function [cpx_pc1,cpx_pc2]=FastDemod(Freq0,Freq1,v_slot)
%% use fast CHE to demodulate ofdm signal
global debug_che;
global debug_SingleDMRS;
if nargin==0
    debug_che=1;
    debug_SingleDMRS=1;
    load('FastDemod.mat')
    v_slot=9;
elseif nargin==1
    Freq1=Freq0;
    v_slot=9;
elseif nargin==2
    v_slot=9;
end

if debug_che
    save FastDemod.mat Freq0 Freq1;
end
%% get data from dmrs slot
slot_pos=(v_slot-1)*14+1:v_slot*14;
Fs0=Freq0(:,slot_pos);
Fs1=Freq1(:,slot_pos);

%% first dmrs
dmrsInx=3;
cpx0=Fs0(:,dmrsInx);
cpx1=Fs1(:,dmrsInx);
[cpx_pc1,fc]=CHEDMRS(cpx0,cpx1);
fprintf("symbol %d Freq offset is %f\n",dmrsInx,fc);
if debug_che
    plot1SymbolConstellation(cpx_pc1(:,1));
    plot1SymbolConstellation(cpx_pc1(:,2));
end

%% second dmrs
dmrsInx=12;

end