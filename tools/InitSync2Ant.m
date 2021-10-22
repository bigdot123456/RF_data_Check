function [SyncSlotPos,SyncSlotInnerPos,FreqOffset]=InitSync2Ant(ViewData,DMRSDataSN)
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
nLayer=2;
nFFT=4096;
nSC=12;
nPRB=273;
RBMax = nPRB;

DMRSLen=nPRB*nSC/2;
%DMRSDataSN=zeros(DMRSLen,nSymb,nSlot);
RB_shift = -RBMax*6 + nFFT/2;
DMRSPos = RB_shift +1: 2 :RB_shift + DMRSLen *2;
DMRSPosP0=DMRSPos;
DMRSPosP2=DMRSPos+1;

MatchLen=length(DMRSDataSN(:,1,1));
xCorLen=63;
xCorTimes=MatchLen/xCorLen;

SearchLen=length(ViewData);
step=16;
stepShift=13;
SearchRange=1:step:SearchLen;
c_max=zeros(nSlot,nLayer);
posSymb=zeros(nSlot,nLayer);
c_view=zeros(length(SearchRange),xCorTimes,nSlot,nLayer);
c_abs=zeros(length(SearchRange),1);

d_max=zeros(1,nLayer);
d_pos=zeros(1,nLayer);

%method selector
for Layer=1:nLayer
    if Debug_InitSync==1
        str=sprintf('Plot DMRS init Sync view');
        figure('NumberTitle', 'on', 'Name', str);
        titlestr=sprintf("Timing Pan View of Ant data with %d point",SearchLen);
        title(titlestr);
    end
    
    for SlotIdx = 9%1:nSlot
        DMRSSync=DMRSDataSN(:,DMRSpos,SlotIdx);
        x=[ViewData(:,Layer);zeros(nFFT+stepShift,1)];
        inx=1;
        for pos=SearchRange
            matchPos=pos+(1:nFFT)-1+stepShift;
            matchData=x(matchPos);
            % key code for match filter with conj
            matchDataFre=fftshift(fft(matchData));
            matchDataFreDMRS=matchDataFre(DMRSPosP0);
            y=DMRSSync.*conj(matchDataFreDMRS);
            for ixCor=1:xCorTimes
                posXcor=(ixCor-1)*xCorLen+(1:xCorLen);
                z=sum(y(posXcor));
                c_view(inx,ixCor,SlotIdx,Layer)=z;
            end
            c1=abs(c_view(inx,:,SlotIdx,Layer));
            c2=sum(c1);
            c_abs(inx)=c2;
            inx=inx+1;
        end
        
        [c_max(SlotIdx,Layer),posSymb(SlotIdx,Layer)]=max(c_abs);
        str=sprintf('L%d s%d max:%d pos:%d\n',Layer,SlotIdx-1,c_max(SlotIdx,Layer),posSymb(SlotIdx,Layer));
        fprintf(str);
        
        if Debug_InitSync==1
            %subplot(4,5,SlotIdx);
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
%% fine Sync Search


if Debug_InitSync==1
    str=sprintf('Fine Sync search view');
    figure('NumberTitle', 'on', 'Name', str);
    titlestr=sprintf("Correlated result with %d & abspos:%d",pos,1);%ßSyncSlotInnerPos);
    title(titlestr);
    
    str=sprintf("Fine sync with [-64,64], slot is %d with pos %d\n",d_pos-1,pos);
    
    plot(Rcorr_fftTem,'b');
    grid on;
    title(str);
    
end

end