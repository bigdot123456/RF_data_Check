function [y_symbFFTIn,slot_sto,slot_fc,y_EQ,symb_sto_sn_abs,symb_sto_sn,StartPoint_sto,y_stoFFTIn_nofc]=slotSTO_CFO(y,OFDMParam)
%% first set input parameter
%  [y_symbFFTIn,slot_sto,slot_fc,y_EQ,symb_sto_sn_abs,symb_sto_sn,StartPoint_sto,y_stoFFTIn_nofc]=slotSTO_CFO(y,OFDMParam)
%  y_symbFFTIn: FFT input for fft dispose
%  slot_sto: symbol best position for FFT
%  slot fc: frequency offset with normalized.  
%   y_EQ: all compensation for y.
%   symb_sto_sn_abs: every symbol sto with abs position
%   symb_sto_sn
%   StartPoint_sto: for sto search start point
%   y_stoFFTIn_nofc: simple use sto compensation, no frequency
%   compensation.
%     len_IQ=1;
%     len_slot=14;
%     len_scp=288;
%     len_lcp=352;
%     len_fft=4096;
%     prb_len=3276;
%     len_sym=len_scp+len_fft;
%     len_shift_cp=len_lcp-len_scp;
%     SearchLen=len_lcp;
%
global Debug_slotSTO_CFO
if nargin==1
    len_IQ=1;
    len_slot=14;
    len_scp=288;
    len_lcp=352;
    len_fft=4096;
    prb_len=3276;
    len_sym=len_scp+len_fft;
    len_shift_cp=len_lcp-len_scp;
    SearchLen=len_lcp;
    
    OFDMParam.len_IQ=len_IQ;
    OFDMParam.len_slot=len_slot;
    OFDMParam.len_scp=len_scp;
    OFDMParam.len_lcp=len_lcp;
    OFDMParam.len_fft=len_fft;
    OFDMParam.prb_len=prb_len;
    OFDMParam.SearchLen=SearchLen;
    
elseif nargin==2
    len_IQ=OFDMParam.len_IQ;
    len_slot=OFDMParam.len_slot;
    len_scp=OFDMParam.len_scp;
    len_lcp=OFDMParam.len_lcp;
    len_fft=OFDMParam.len_fft;
    prb_len=OFDMParam.prb_len;
    SearchLen=OFDMParam.SearchLen;
    
    len_sym=len_scp+len_fft;
    len_shift_cp=len_lcp-len_scp;
end

%% malloc memory
symb_sto_sn=zeros(1,len_slot);
symb_sto_sn_abs=zeros(1,len_slot);
CFO_sum=zeros(1,len_slot);
y_stoFFTIn_nofc=zeros(len_fft,len_slot);
y_symbFFTIn=zeros(len_fft,len_slot);
sto_CFOIn=zeros(len_fft+len_lcp,len_slot);
sto_diff=zeros(SearchLen*3,len_slot);
CFO_est=zeros(1,len_slot);
StartPoint_sto=zeros(1,len_slot);

slot_inx=1:len_slot;
slot_inx_valid=2:(len_slot-1);

% StartPoint=1; % from -SearchLen to SearchLen
% [sto_pos,pos0, FFTDataIn,SymbolData,sto_diffsum]=SymbolSTOlcp(y,len_lcp,StartPoint,SearchLen); % bigdot works!
% sto_sn(1)=sto_pos;
% pos_sn(1)=pos0;
% y_sto_FFTIn(:,1)=FFTDataIn;
% sto_CFOIn(:,1)=SymbolData;
% sto_diff(:,1)=sto_diffsum;
% nn=1:len_lcp;
% CFO_sum(1)=SymbolData(nn+len_fft)*SymbolData(nn)';
% CFO_est(1)= angle(CFO_sum(1))/(2*pi);  % Eq.(5.27)

for i=slot_inx
    if i==1
        StartPoint_sto(i)=1;
    else
        StartPoint_sto(i)=(i-1)*(len_fft+len_scp)+(len_lcp-len_scp)+1; % from -SearchLen to SearchLen
    end
    
    if i==1
        len_cp=len_lcp;
    elseif i==14
        len_cp=len_scp;
    else
        len_cp=len_scp;
    end
    
    [sto_pos, symb_sto_pos_abs0,symbFFTIn,symbFullData,sto_diffsum]=SymbolSTOlcp(y,len_cp,StartPoint_sto(i),SearchLen); % bigdot works!

    symb_sto_sn(i)=sto_pos;
    symb_sto_sn_abs(i)=symb_sto_pos_abs0;
    y_stoFFTIn_nofc(:,i)=symbFFTIn;
    sto_CFOIn(1:(len_fft+len_cp),i)=symbFullData;
    sto_diff(:,i)=sto_diffsum;
    
    nn=1:len_cp;
    CFO_sum(i)=symbFullData(nn+len_fft)*symbFullData(nn)';
    CFO_est(i)= angle(CFO_sum(i))/(2*pi);  % Eq.(5.27)
end

%%  use STO result to Freqeuncy Offset Cancellor
CFO_sum_final=zeros(1,len_slot);
CFO_est_final=zeros(1,len_slot);
pos_symb=zeros(1,len_slot);

slot_sto=floor(mean(symb_sto_sn(slot_inx_valid)));
slot_sto_timing_error=slot_sto-SearchLen-len_scp/2-1;
fprintf("sto:%d||%d ",slot_sto,slot_sto_timing_error);
nn=1:len_scp;
for i=slot_inx
    pos_fc=StartPoint_sto(i)+slot_sto;
    pos_fc_sn=pos_fc+nn-1;
    pos_fc_sn_cp=pos_fc_sn+len_fft;
    CFO_sum_final(i)=y(pos_fc_sn_cp)*y(pos_fc_sn)';
    CFO_est_final(i)= angle(CFO_sum_final(i))/(2*pi);  % Eq.(5.27)
end

CFO_slotsum_final=sum(CFO_sum_final(slot_inx_valid));
slot_fc=angle(CFO_slotsum_final)/(2*pi);

nn=0:length(y)-1;
y_EQ = y.*exp(-j*2*pi*slot_fc*nn/len_fft);

for i=slot_inx
    if i==1
        len_cp=len_lcp;
    else
        len_cp=len_scp;
    end
    pos_symb(i)=StartPoint_sto(i)+slot_sto+len_cp/2;
    pos=pos_symb(i)+(1:len_fft)-1;
    y_symbFFTIn(:,i)=y_EQ(pos);
end

if Debug_slotSTO_CFO==1
    str=sprintf('Plot slot sto with %d point',length(y));
    figure('NumberTitle', 'on', 'Name', str);
    %figure('NumberTitle', 'off', 'Name', str);
    for i=slot_inx
        subplot(5,3,i);
        plot(sto_diff(:,i),'.');
        str=sprintf('s%d sto:%d min:%d',i-1,symb_sto_sn(i),sto_diff(symb_sto_sn(i),i));
        title(str);
        grid on;
    end
    
end

end
