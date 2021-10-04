function [SymbolOut,SymbolOutWithEQ]=Slot2SymbolWithEQ(SlotIn,lastSlotIn,nextSlotIn,OFDMParam)
%% split 1Slot 2 28 Symbol,1228800
%  [SymbolOut,SymbolOutWithEQ]=Slot2SymbolWithEQ(SlotIn,lastSlotIn,nextSlotIn,OFDMParam)
%  should input Slot Data in and LastSlotIn with some data near Slot In
global Debug_slotSTO_CFO
if nargin<4
    len_IQ=1;
    len_slot=14;
    len_scp=288;
    len_lcp=352;
    len_fft=4096;
    prb_len=3276;
    len_sym=len_scp+len_fft;
    len_shift_cp=len_lcp-len_scp;
    
    SearchLen=2*len_lcp;
    
    OFDMParam.len_IQ=len_IQ;
    OFDMParam.len_slot=len_slot;
    OFDMParam.len_scp=len_scp;
    OFDMParam.len_lcp=len_lcp;
    OFDMParam.len_fft=len_fft;
    OFDMParam.prb_len=prb_len;
    OFDMParam.SearchLen=SearchLen;
elseif nargin==4
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

if nargin==1
    lastSlotIn=zeros(SearchLen,1);
    nextSlotIn=zeros(2*SearchLen,1);
elseif nargin==2
    nextSlotIn=zeros(2*SearchLen,1);
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
y=[lastSlotIn(end-SearchLen+1:end);SlotIn;nextSlotIn(1:2*SearchLen)];
pos_std=zeros(1,len_slot);
pos_std(1)=SearchLen+len_lcp/2;
symbol2_pos=pos_std(1)+len_lcp/2+len_fft;
for i=2:len_slot
    pos_std(i)=symbol2_pos+(i-2)*(len_fft+len_scp)+len_scp/2;
end

[y_symbFFTIn,slot_sto,slot_fc,y_EQ,symb_sto_sn_abs,symb_sto_sn,StartPoint_sto,y_stoFFTIn_nofc]=slotSTO_CFO(y.',OFDMParam);
pos_dev=symb_sto_sn_abs-pos_std;
pos_best_cp=StartPoint_sto+symb_sto_sn-1;
pos_dev_sto=pos_best_cp-pos_std;
pos_dev_ref=StartPoint_sto+SearchLen+len_scp/2-pos_std;

% check it again after CFO, now again with sto
[y_symbFFTIn1,slot_sto1,slot_fc1,y_EQ1,symb_sto_sn_abs1,symb_sto_sn1,StartPoint_sto1,y_stoFFTIn_nofc1]=slotSTO_CFO(y_EQ,OFDMParam);
SymbolOutWithEQ=y_symbFFTIn1;

pos_dev1=symb_sto_sn_abs1-pos_std;
pos_ref=StartPoint_sto1-pos_std;
pos_ref1(1)=StartPoint_sto1(1)+len_lcp/2+SearchLen;
pos_ref1(2:14)=StartPoint_sto1(2:14)+len_scp/2+SearchLen;

pos_dev2=symb_sto_sn-symb_sto_sn1;
pos_diff2=slot_sto-slot_sto1;
fc_diff2=slot_fc-slot_fc1;

fprintf("FC1:%f FC2:%f ",slot_fc,slot_fc1);
fprintf("sto symb offset:");
fprintf("%d ",pos_dev_sto');
fprintf("\n");

if Debug_slotSTO_CFO==1
    str=sprintf('%d ',pos_dev_sto);
    figure('NumberTitle', 'on', 'Name', "sto err:"+str);
    
    plot(pos_dev,'.');
    hold on;
    plot(pos_dev1,'r.');
    plot(pos_dev_sto,'g.');
    
    plot(pos_dev2,'m.');
    plot(pos_ref,'c.');
    grid on;
    str=sprintf('STO dev with ave: %d max:%d',sum(abs(pos_dev)),max(abs(pos_dev)));
    title(str)
end

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