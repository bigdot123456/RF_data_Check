function SymbolOut=FC1Slot2Symbol(SlotIn)
%% split 1Slot 2 28 Symbol,1228800
len_IQ=1;
len_slot=14;
len_scp=288;
len_lcp=352;
len_fft=4096;
prb_len=3276;
len_sym=len_scp+len_fft;
len_shift_cp=len_lcp-len_scp;
%% get data
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