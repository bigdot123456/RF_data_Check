function [SyncSlotPos,SyncSlotInnerPos1,SyncSlotInnerPos2,FreqOffset]=InitSync(ViewData,DMRSDataTime,nLayer,fastView)
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

if nargin<3
    nLayer=1;
end

if nargin<4
    fastView=1;
end

methodCoaresThreshhold=nLayer+1;
DMRSpos=3;
nSlot=20;
%% add again
MatchLen=length(DMRSDataTime(:,1,1,1));
SearchLen=length(ViewData);

c_max=zeros(nSlot,nLayer,nLayer+1);
posSymb=zeros(nSlot,nLayer,nLayer+1);
% use two ant
c_view=zeros(SearchLen,nSlot,nLayer,nLayer+1);
c_abs=zeros(SearchLen,nLayer+1);
d_max=zeros(nLayer,nLayer+1);
d_pos=zeros(nLayer,nLayer+1);

if fastView==1
    slotRange=9;
    fprintf('Caution: Slot Search range:%d\n',slotRange);
else
    slotRange=1:nSlot;
end
%method selector
method=1;
for Layer=1:nLayer
    if Debug_InitSync==1
        str=sprintf('Plot Layer%d DMRS init Sync view',Layer);
        figure('NumberTitle', 'on', 'Name', str);
        titlestr=sprintf("Timing Pan View of Ant data with %d point",SearchLen);
        title(titlestr);
    end
    
    for SlotIdx = slotRange
        DMRSSync=DMRSDataTime(:,DMRSpos,SlotIdx,Layer);
        for iAnt=1:nLayer
            x=[ViewData(:,iAnt);zeros(MatchLen,1)];
            if method==1
                a=xcorr(x,DMRSSync);
                len_a=length(a);
                posValid=len_a-SearchLen-MatchLen+1:len_a-MatchLen;
                c_view(:,SlotIdx,Layer,iAnt)=a(posValid);
            else
                for pos=1:SearchLen
                    matchPos=pos+(1:MatchLen)-1;
                    matchData=x(matchPos);
                    % key code for match filter with conj
                    y=DMRSSync.*conj(matchData);
                    z=sum(y);
                    c_view(pos,SlotIdx,Layer,iAnt)=z;
                end
            end
            
            c_view(:,SlotIdx,Layer,nLayer+1)=c_view(:,SlotIdx,Layer,iAnt)+c_view(:,SlotIdx,Layer,nLayer+1);
            
            c_abs(:,iAnt)=abs(c_view(:,SlotIdx,Layer,iAnt));
            
            [c_max(SlotIdx,Layer,iAnt),posSymb(SlotIdx,Layer,iAnt)]= max(c_abs(:,iAnt));
            str=sprintf('Ant%d L%d s%d max:%d pos:%d\n',iAnt,Layer,SlotIdx-1,c_max(SlotIdx,Layer,iAnt),posSymb(SlotIdx,Layer,iAnt));
            fprintf(str);
        end
        %c_view(:,SlotIdx,Layer,nLayer+1)=sum(c_view(:,SlotIdx,Layer,1:nLayer),2);
        c_abs(:,nLayer+1)=abs(c_view(:,SlotIdx,Layer,nLayer+1));
        
        [c_max(SlotIdx,Layer,nLayer+1),posSymb(SlotIdx,Layer,nLayer+1)]=max(c_abs(:,nLayer+1));
        str=sprintf('Ant%d L%d s%d max:%d pos:%d\n',nLayer+1,Layer,SlotIdx-1,c_max(SlotIdx,Layer,nLayer+1),posSymb(SlotIdx,Layer,nLayer+1));
        fprintf(str);
        
        if Debug_InitSync==1
            if fastView~=1
                subplot(4,5,SlotIdx);
            end
            plot(c_abs);
            grid on;
            %str=sprintf('slot%d max:%d pos:%d',SlotIdx-1,c_max(SlotIdx,Layer),c_pos(SlotIdx,Layer));
            title(str);
        end
        
    end
    for iAnt=1:nLayer+1
        [d_max(Layer,iAnt),d_pos(Layer,iAnt)]=max(c_max(:,Layer,iAnt));
    end
end

[~,bestLayer]=max(d_max(:,methodCoaresThreshhold));
bestSlot=d_pos(bestLayer,methodCoaresThreshhold);
bestSymbPos=posSymb(bestSlot,bestLayer,methodCoaresThreshhold);
fprintf("best sync pos reference result\n");
fprintf("\t%d",posSymb(bestSlot,:,:));
fprintf("\nSync slot is %d with pos %d\n",bestSlot-1,bestSymbPos);
if bestSymbPos==0 || bestSlot==0
    fprintf("Error! Blank data source, Please check input");
    error(-1);
end
SyncSlotPos=d_pos-1;

%c_view=zeros(SearchLen,nSlot,nLayer,nLayer+1);
slot8_xcorr=c_view(bestSymbPos,bestSlot,bestLayer,nLayer+1);

FreqOffset=angle(slot8_xcorr);
fprintf("Freq offset origin data is %f+1i*%f\n",real(slot8_xcorr),imag(slot8_xcorr));

%% fine sync
%PosDMRSRx=posSync-1+(1:4096);
for Layer=1:nLayer
    DMRSDataTimeSlot8(:,Layer)=DMRSDataTime(:,DMRSpos,bestSlot,nLayer);
end
% fine sync
N_table = -64:64;
Rcorr_fftTem = zeros(length(N_table),nLayer);
Rcorr_fftTemPos = zeros(length(N_table),nLayer);
Rcorr_k0=zeros(length(N_table),nLayer);
Rcorr_k1=zeros(length(N_table),nLayer);
Rcorr_fft_fullview= zeros(4096,length(N_table),nLayer);
N=64;
N1=floor(4096/N);
for Layer=1:nLayer
    for k=N_table
        inx=k-N_table(1)+1;
        Pos=bestSymbPos-1+(1:4096)+k;
        DMRSRxData=ViewData(Pos,Layer);
        Rcorr=DMRSRxData.*conj(DMRSDataTimeSlot8(:,Layer));
        for i=1:N1
            posSum=(i-1)*N+1:N;
            Rsum=sum(Rcorr(posSum));
            Rcorr_k1(inx,Layer)=Rcorr_k1(inx,Layer)+abs(Rsum);
        end
        
        Rcorr_k0(inx,Layer)=sum(Rcorr);
        
        % because there exists frequency error, if directly add it, it will
        % cause an error. So use FFT and find max freqency, and the
        % caculate freqency error.
        Rcorr_fft=fftshift(fft(Rcorr));
        Rcorr_fft_fullview(:,inx,Layer)=Rcorr_fft;
        [Rcorr_fftTem(inx,Layer),Rcorr_fftTemPos(inx,Layer)]=max(abs(Rcorr_fft));
        
    end
    if Debug_InitSync==1
        str=sprintf('Ant%d continuous freqency correlation result',Layer);
        figure('NumberTitle', 'on', 'Name', str);
        s=mesh(abs(Rcorr_fft_fullview(:,:,Layer)),'FaceAlpha','0.5');
        x1=xlabel('shift direction with scale 1');
        x2=ylabel('Sample subcarrier Correlation Direction: 1 -> 4096');
        x3=zlabel('Correlation result, max value is best match position');
        set(x1,'Rotation',30);
        set(x2,'Rotation',-30);
        %plot(abs(Ant_view));
        title(str);
        colorbar;
        %s.FaceColor = 'flat';
        grid on;
    end
end

%[~,pos]=max(abs(Rcorr_k0(:,Layer)));
% should use Rcorr_k1 to aviod freqency offset
[~,pos1]=max(abs(Rcorr_k1));
% another method use fft result
[~,pos2]=max(abs(Rcorr_fftTem));
SyncSlotInnerPos1=bestSymbPos+N_table(pos1);
SyncSlotInnerPos2=bestSymbPos+N_table(pos2);

if Debug_InitSync==1
    titlestr=sprintf("Correlated result with FC, pos: %d %d& %d %d",pos1,SyncSlotInnerPos1);
    figure('NumberTitle', 'on', 'Name', titlestr);
    
    str=sprintf("Fine sync:%d %d fft with [-64,64], slot%d with pos %d %d\n",SyncSlotInnerPos2,bestSlot,pos2);
    plot(Rcorr_fftTem);
    hold on;
    % need a FFT point coefficent, 4096 point fft is sqrt(4096)=64 times
    % enlarge.
    plot(Rcorr_k1*64,'--');
    grid on;
    title(str);
    fprintf(titlestr,str);
end


end