function [y_CFO,pos_sn,sto_sn,y_sto_FFTIn,y_CFO_FFTIn]=slotSTO_CFO(y,OFDMParam)
%% first set input parameter
if nargin==1
    len_IQ=1;
    len_slot=14;
    len_scp=288;
    len_lcp=352;
    len_fft=4096;
    prb_len=3276;
    len_sym=len_scp+len_fft;
    len_shift_cp=len_lcp-len_scp;
        
    OFDMParam.len_IQ=len_IQ;
    OFDMParam.len_slot=len_slot;
    OFDMParam.len_scp=len_scp;
    OFDMParam.len_lcp=len_lcp;
    OFDMParam.len_fft=len_fft;
    OFDMParam.prb_len=prb_len;

elseif nargin==2
    len_IQ=OFDMParam.len_IQ;
    len_slot=OFDMParam.len_slot;
    len_scp=OFDMParam.len_scp;
    len_lcp=OFDMParam.len_lcp;
    len_fft=OFDMParam.len_fft;
    prb_len=OFDMParam.prb_len;
    len_sym=len_scp+len_fft;
    len_shift_cp=len_lcp-len_scp;
end

SearchLen=2*len_lcp;
%% malloc memory
sto_sn=zeros(1,len_slot);
pos_sn=zeros(1,len_slot);
CFO_sum=zeros(1,len_slot);
y_sto_FFTIn=zeros(len_fft,len_slot);
y_CFO_FFTIn=zeros(len_fft,len_slot);
sto_CFOIn=zeros(len_fft+len_lcp,len_slot);
sto_diff=zeros(SearchLen,len_slot);
CFO_est=zeros(1,len_slot);


StartPoint=1; % from -SearchLen to SearchLen
[sto_pos,pos0, FFTDataIn,SymbolData,sto_diffsum]=SymbolSTOlcp(y,len_lcp,StartPoint,SearchLen); % bigdot works!
sto_sn(1)=sto_pos;
pos_sn(1)=pos0;
y_sto_FFTIn(1)=FFTDataIn;
sto_CFOIn(1)=SymbolData;
sto_diff(:,1)=sto_diffsum;
nn=1:len_lcp;
CFO_sum(1)=SymbolData(nn+len_fft)*SymbolData(nn)';
CFO_est(i)= angle(CFO_sum(1))/(2*pi);  % Eq.(5.27)

nn=1:len_scp;
for i=2:len_slot
    StartPoint=(i-1)*(len_fft+len_scp)+(len_lcp-len_scp)+1; % from -SearchLen to SearchLen
    [sto_pos, pos0,FFTDataIn,SymbolData,sto_diffsum]=SymbolSTOlcp(y,len_scp,StartPoint,SearchLen); % bigdot works!
    sto_sn(i)=sto_pos;
    pos_sn(i)=pos0;
    y_sto_FFTIn(i)=FFTDataIn;
    sto_CFOIn(i)=SymbolData;
    sto_diff(:,i)=sto_diffsum;
    
    CFO_sum(i)=SymbolData(nn+len_fft)*SymbolData(nn)';
    CFO_est(i)= angle(CFO_sum(i))/(2*pi);  % Eq.(5.27)
end

CFO_slotsum=sum(CFO_sum);
CFO_FC=angle(CFO_slotsum)/(2*pi);

nn=0:length(y)-1;
y_CFO = y.*exp(j*2*pi*CFO_FC*nn/Nfft);

for i=1:len_slot
    pos=pos_sn(i)+(1:len_fft)-1;
    y_CFO_FFTIn(:,i)=y_CFO(pos);
end

end
