function [SyncPos,FreqOffset]=InitSync(ViewData,DMRSDataTime,nLayer)
%% use it to get initial sync data info
% [SyncPos,FreqOffset]=InitSync(Ant)
% len=length(viewData);
% len_fft=4096;
%     DataSym2Freq = fftshift(fft(DataSym2Time));
%     for SlotIdx = 1:20
%         Dmrs_Fre2 = squeeze(Dmrs_Fre(:,1,SlotIdx));
%         [Rcorr2(SlotIdx),Pos2(SlotIdx)] =  max(abs(ifft(fftshift(DataSym2Freq.*conj(Dmrs_Fre2)))));
%     end
%     [~,SlotId] = max(Rcorr2);
DMRSpos=3;
nSlot=20;
c_max=zeros(nSlot,nLayer);
c_pos=zeros(nSlot,nLayer);

d_max=zeros(1,nLayer);
d_pos=zeros(1,nLayer);

for Layer=1:nLayer
    for SlotIdx = 1:nSlot
        DMRSSync=DMRSDataTime(:,DMRSpos,SlotIdx,Layer);
        x=ViewData(:,Layer);
        c=xcorr(x,DMRSSync);
        c_abs=abs(c);
        plot(c_abs);
        [c_max(SlotIdx,Layer),c_pos(SlotIdx,Layer)]=max(c_abs);
    end
    [d_max(Layer),d_pos(Layer)]=max(c_max(:,Layer));
end
SyncPos=mean(d_pos);
FreqOffset=0;
end