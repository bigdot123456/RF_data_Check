function [SyncSlotPos,SyncSlotInnerPos,FreqOffset]=InitSync(ViewData,DMRSDataTime,nLayer)
%% use it to get initial sync data info
% [SyncSlotPos,SyncSlotInnerPos,FreqOffset]=InitSync(ViewData,DMRSDataTime,nLayer)
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
SearchLen=length(ViewData);

c_max=zeros(nSlot,nLayer);
posSymb=zeros(nSlot,nLayer);
c_view=zeros(SearchLen,nSlot,nLayer);

d_max=zeros(1,nLayer);
d_pos=zeros(1,nLayer);


%method selector
method=1;
for Layer=1:nLayer
    if Debug_InitSync==1
    str=sprintf('Plot Layer%d DMRS init Sync view',Layer);
    figure('NumberTitle', 'on', 'Name', str);
    titlestr=sprintf("Timing Pan View of Ant data with %d point",SearchLen);
    title(titlestr);
    end

    for SlotIdx = 1:nSlot
        DMRSSync=DMRSDataTime(:,DMRSpos,SlotIdx,Layer);
        x=[ViewData(:,Layer);zeros(MatchLen,1)];
        if method==1
            a=xcorr(x,DMRSSync);
            len_a=length(a);
            posValid=len_a-SearchLen-MatchLen+1:len_a-MatchLen;
            c_view(:,SlotIdx,Layer)=a(posValid);
        else
            for pos=1:SearchLen
                matchPos=pos+(1:MatchLen)-1;
                matchData=x(matchPos);
                % key code for match filter with conj
                y=DMRSSync.*conj(matchData);
                z=sum(y);
                c_view(pos,SlotIdx,Layer)=z;
            end
        end
        c_abs=abs(c_view(:,SlotIdx,Layer)); 
        
        [c_max(SlotIdx,Layer),posSymb(SlotIdx,Layer)]=max(c_abs);
        str=sprintf('L%d s%d max:%d pos:%d\n',Layer,SlotIdx-1,c_max(SlotIdx,Layer),posSymb(SlotIdx,Layer));
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
    posSync(Layer)=posSymb(d_pos(Layer),Layer);
end

fprintf("Sync slot is %d with pos %d\n",d_pos-1,posSync);
SyncSlotPos=d_pos-1;

slot8_xcorr=c_view(posSync,d_pos,:);

FreqOffset=angle(slot8_xcorr);
fprintf("Freq offset origin data is %f+1i*%f\n",real(slot8_xcorr),imag(slot8_xcorr));

%PosDMRSRx=posSync-1+(1:4096);
for Layer=1:nLayer
    DMRSDataTimeSlot8(:,nLayer)=DMRSDataTime(:,DMRSpos,d_pos(nLayer),nLayer);
end
% fine sync
N_table = -64:64;
Rcorr_fftTem = zeros(length(N_table),nLayer);
Rcorr_k0=zeros(length(N_table),nLayer);

for Layer=1:nLayer
    for k=N_table
        Pos=posSync(Layer)-1+(1:4096)+k;
        DMRSRxData=ViewData(Pos,Layer);
        Rcorr=DMRSRxData.*conj(DMRSDataTimeSlot8(:,nLayer));
        Rcorr_fft=fftshift(fft(Rcorr));
        inx=k-N_table(1)+1;
        Rcorr_k0(inx,Layer)=sum(Rcorr);
        Rcorr_fftTem(inx,Layer) =max(abs(Rcorr_fft));
    end
end

[~,pos]=max(abs(Rcorr_k0(:,Layer)));
SyncSlotInnerPos=posSync-1+pos+N_table(1);

if Debug_InitSync==1
    str=sprintf('Fine Sync search view');
    figure('NumberTitle', 'on', 'Name', str);
    titlestr=sprintf("Correlated result with %d & abspos:%d",pos,SyncSlotInnerPos);
    title(titlestr);
    
    str=sprintf("Fine sync with [-64,64], slot is %d with pos %d\n",d_pos-1,pos);
    
    plot(Rcorr_fftTem,'b');
    grid on;
    title(str);

end

end