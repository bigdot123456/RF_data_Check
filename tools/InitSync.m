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
global  Debug_InitSync

DMRSpos=3;
nSlot=20;

MatchLen=length(DMRSDataTime(:,1,1,1));
SearchLen=length(ViewData)-MatchLen;

c_max=zeros(nSlot,nLayer);
c_pos=zeros(nSlot,nLayer);
c_view=zeros(SearchLen,nSlot,nLayer);

d_max=zeros(1,nLayer);
d_pos=zeros(1,nLayer);

if Debug_InitSync==1
    str=sprintf('Plot DMRS init Sync view');
    figure('NumberTitle', 'on', 'Name', str);
    titlestr=sprintf("Timing Pan View of Ant data with %d point",SearchLen);
    title(titlestr);
end

%method selector
method=0;
for Layer=1:nLayer
    for SlotIdx = 1:nSlot
        DMRSSync=DMRSDataTime(:,DMRSpos,SlotIdx,Layer);
        x=ViewData(:,Layer);
        if method==1
            a=xcorr(x,DMRSSync);
            c_view(:,SlotIdx,Layer)=a(end-SearchLen+1:end);
        else
            for pos=1:SearchLen
                matchPos=pos+(1:MatchLen)-1;
                matchData=x(matchPos);
                y=DMRSSync.*matchData;
                z=sum(y);
                c_view(pos,SlotIdx,Layer)=z;
            end
        end
        c_abs=abs(c_view(:,SlotIdx,Layer));
        
        [c_max(SlotIdx,Layer),c_pos(SlotIdx,Layer)]=max(c_abs);
        str=sprintf('L%d s%d max:%d pos:%d\n',Layer,SlotIdx-1,c_max(SlotIdx,Layer),c_pos(SlotIdx,Layer));
        fprintf(str);
        
        if Debug_InitSync==1
            subplot(4,5,SlotIdx);
            plot(c_abs,'b');
            grid on;
            %str=sprintf('slot%d max:%d pos:%d',SlotIdx-1,c_max(SlotIdx,Layer),c_pos(SlotIdx,Layer));
            title(str);
        end
    end
    [d_max(Layer),d_pos(Layer)]=max(c_max(:,Layer));
end
SyncPos=mean(d_pos);
FreqOffset=0;
end