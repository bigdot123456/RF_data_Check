function [SymbolOut,SymbolOutWithEQ]=Slot2SymbolWithEQ(SlotIn,lastSlotIn,nextSlotIn,SearchLen,OFDMParam)
%% split 1Slot 2 28 Symbol,1228800
if nargin<5
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
elseif nargin==5
    len_IQ=OFDMParam.len_IQ;
    len_slot=OFDMParam.len_slot;
    len_scp=OFDMParam.len_scp;
    len_lcp=OFDMParam.len_lcp;
    len_fft=OFDMParam.len_fft;
    prb_len=OFDMParam.prb_len;
    len_sym=len_scp+len_fft;
    len_shift_cp=len_lcp-len_scp;
end

if nargin<4
    SearchLen=len_lcp;
end

if nargin==1
    lastSlotIn=zeros(1,SearchLen);
    nextSlotIn=zeros(1,SearchLen);
elseif nargin==2
    nextSlotIn=zeros(1,SearchLen);
end
%% get data
% % malloc mem
% sto_sn=zeros(1,len_slot);
% CFO_sum=zeros(1,len_slot);
% sto_FFTIn=zeros(len_fft,len_slot);
% sto_CFOIn=zeros(len_fft+len_lcp,len_slot);
% sto_diff=zeros(SearchLen,len_slot);
% CFO_est=zeros(1,len_slot);
% y=[lastSlotIn(end-SearchLen+1:end) SlotIn nextSlotIn(1:SearchLen)];
% 
% StartPoint=1; % from -SearchLen to SearchLen
% [sto_pos, FFTDataIn,SymbolData,sto_diffsum]=SymbolSTOlcp(y,len_lcp,StartPoint,SearchLen); % bigdot works!
% sto_sn(1)=sto_pos;
% sto_FFTIn(1)=FFTDataIn;
% sto_CFOIn(1)=SymbolData;
% sto_diff(:,1)=sto_diffsum;
% nn=1:len_lcp;
% CFO_sum(1)=SymbolData(nn+len_fft)*SymbolData(nn)';
% CFO_est(i)= angle(CFO_sum(1))/(2*pi);  % Eq.(5.27)
% 
% nn=1:len_scp;
% for i=2:len_slot
%     StartPoint=(i-1)*(len_fft+len_scp)+(len_lcp-len_scp)+1; % from -SearchLen to SearchLen
%     [sto_pos, FFTDataIn,SymbolData,sto_diffsum]=SymbolSTOlcp(y,len_scp,StartPoint,SearchLen); % bigdot works!
%     sto_sn(i)=sto_pos;
%     sto_FFTIn(i)=FFTDataIn;
%     sto_CFOIn(i)=SymbolData;
%     sto_diff(:,i)=sto_diffsum;
%     
%     CFO_sum(i)=SymbolData(nn+len_fft)*SymbolData(nn)';
%     CFO_est(i)= angle(CFO_sum(i))/(2*pi);  % Eq.(5.27)
% end
% 
% CFO_slotsum=sum(CFO_sum);
% CFO_FC=angle(CFO_slotsum)/(2*pi);
% 
% nn=0:length(y)-1; 
% y_CFO = y.*exp(j*2*pi*CFO_FC*nn/Nfft);

% [a,b,c]%vertical concat
% [a;b;c]% horizontal concat
% a.' % a transpose not conjucte
y=[lastSlotIn(end-SearchLen+1:end) ,SlotIn.',nextSlotIn(1:SearchLen)];

[y_CFO,pos_sn,sto_sn,y_sto_FFTIn,y_CFO_FFTIn]=slotSTO_CFO(y,OFDMParam);
% check it again after CFO, now again with sto
[y_CFO1,pos_sn1,sto_sn1,y_sto_FFTIn1,y_CFO_FFTIn1]=slotSTO_CFO(y_CFO,OFDMParam);
SymbolOutWithEQ=y_CFO_FFTIn1;
%% normal split symbol
len_sym=(len_fft+len_scp);%% normal cp, should 288, long cp should be 352
len_ts_per_slot=(len_slot*len_sym+len_lcp-len_scp)*len_IQ;

sframe0=SlotIn(1:len_ts_per_slot);
%sframe1=SlotIn(len_ts_per_slot+1:2*len_ts_per_slot);

SymbolOut0=zeros(len_fft,len_slot);
%SymbolOut1=zeros(len_fft,len_slot);

SymbolOut0(:,1)=sframe0(len_lcp/2:len_lcp/2+len_fft-1);
for i=2:len_slot
    p0=len_lcp+len_fft+(i-2)*len_sym+len_scp;
    p1=p0+len_fft-1;
    SymbolOut0(:,i)=sframe0(p0:p1);
end

% SymbolOut1(:,1)=sframe1(len_lcp/2:len_lcp/2+len_fft-1);
% for i=2:len_slot
%     p0=len_lcp+len_fft+(i-2)*len_sym+len_scp;
%     p1=p0+len_fft-1;
%     SymbolOut1(:,i)=sframe1(p0:p1);
% end
%
% SymbolOut=[SymbolOut0,SymbolOut1];
SymbolOut=SymbolOut0;
end