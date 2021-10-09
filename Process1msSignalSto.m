function [slot_sto_diff]=Process1msSignalSto(Ant_view,ant_num)
%% process 1ms signal with STO & CFO
% [slotCollectFreq,slotUp]=Process1msSignal(Ant_view,ant_num)
% ant_num is used to figure view
global Debug_view Ant_debug Debug_slotSTO_CFO Debug_slotSTO_CFO_More
%global Debug_slotSTO_CFO;
%global Debug_sto;

if nargin==1
    ant_num=0;
elseif nargin==0
    ant_num=0;
    load './Ant_view.mat'
end

if Ant_debug==1
    save 'Ant_view.mat'
end

len_IQ=1;
len_slot=14;
len_scp=288;
len_lcp=352;
len_fft=4096;
prb_len=3276;
len_sym=len_scp+len_fft;
len_shift_cp=len_lcp-len_scp;
len_slot_ts=len_slot*len_sym+len_shift_cp;

SearchLen=2*len_lcp;

OFDMParam.len_IQ=len_IQ;
OFDMParam.len_slot=len_slot;
OFDMParam.len_scp=len_scp;
OFDMParam.len_lcp=len_lcp;
OFDMParam.len_fft=len_fft;
OFDMParam.prb_len=prb_len;
OFDMParam.SearchLen=SearchLen;
%% search lcp
SignalPosOffset=1;%2*len_scp;

y=[Ant_view;Ant_view(1:2*len_fft,1);zeros(len_lcp,1)];
len=length(Ant_view);

%searchLen=len;
searchLen=61440*10;

sto_diffsum=zeros(1,searchLen);
sto_corrsum=zeros(1,searchLen);

for k =1:searchLen
    pos1=(k:k+len_scp-1);
    pos2=pos1+len_fft;
    temp = abs(y(pos1)) - abs(y(pos2));
    SquareSum=sum(temp.^2);
    sto_diffsum(k) = SquareSum;
end

for k =1:searchLen
    pos1=(k:k+len_scp-1);
    pos2=pos1+len_fft;
    temp = y(pos1)'*y(pos2);
    corrSum=abs(temp);
    sto_corrsum(k) = corrSum;
end

slotNum=floor(searchLen/len_slot_ts);

[sto_diff_min,STO_est0]=min(sto_diffsum);
sto_diff_max=max(sto_diffsum);
slot_sto_diff=reshape(sto_diffsum(1:slotNum*len_slot_ts),len_slot_ts,slotNum);

[sto_corr_max,STO_est1]=max(sto_corrsum);
slot_sto_corr=reshape(sto_corrsum(1:slotNum*len_slot_ts),len_slot_ts,slotNum);

slot_sto_std=zeros(1,slotNum*len_slot);
for kk=1:slotNum
    inx=(kk-1)*len_slot;
    base_pos=(kk-1)*len_slot_ts+1+SignalPosOffset;
    
    slot_sto_std(inx+1)=base_pos+len_lcp/2;
    for i=2:len_slot
        slot_sto_std(inx+i)=base_pos+(len_scp+len_fft)*(i-1)+(len_lcp-len_scp)+len_scp/2;
    end
end
slot_sto_std_view=zeros(size(y));
slot_sto_std_view(slot_sto_std)=1;

%% plot all debug figure
sn=zeros(1,4448);
sn(SignalPosOffset)=1;

if Debug_slotSTO_CFO==1
    % full view
    str=sprintf('sto correlate with %d point,max:%d,best:%d',len,sto_corr_max,STO_est1);
    figure('NumberTitle', 'on', 'Name', str);
    plot(sto_corrsum,'m');
    title(str);
    grid on;
    hold on;
    plot(slot_sto_std_view(1:length(sto_corrsum))*1.2*sto_corr_max,'--');
    
    % slot view
    if Debug_slotSTO_CFO_More==1
        for i=1:slotNum
            str=sprintf('slot %d sto correlate with value %d pos:%d',i-1,max(slot_sto_corr(:,i)));
            figure('NumberTitle', 'on', 'Name', str);
            plot(slot_sto_corr(:,i),'-m');
            hold on;
            plot(sn*sto_corr_max*1.2,'r');
            title(str);
            grid on;
            
        end
    end
    
    % 3D view
    str=sprintf('Ant%d sto correlate signal with %d point and zeronum %d',ant_num,len);
    figure('NumberTitle', 'on', 'Name', str);
    mesh(slot_sto_corr,'FaceAlpha','0.5');
    x1=xlabel('Symbol Direction: 1 -> 14');
    x2=ylabel('Sample subcarrier Direction: 1 -> 4096');
    x3=zlabel('Sample value scale in original scale');
    set(x1,'Rotation',30);
    set(x2,'Rotation',-30);
    %plot(abs(Ant_view));
    title(str);
    grid on;
    colorbar;
    
end
%% plot all debug figure
if Debug_slotSTO_CFO==1
    % full view
    str=sprintf('sto with diff %d point,min:%d,best:%d',len,sto_diff_min,STO_est0);
    figure('NumberTitle', 'on', 'Name', str);
    plot(sto_diffsum,'r');
    title(str);
    grid on;
    hold on;
    plot(slot_sto_std_view(1:length(sto_corrsum))*1.2*sto_diff_max,'--');
    % slot view
    if Debug_slotSTO_CFO_More==1
        for i=1:slotNum
            str=sprintf('slot %d sto diff with value %d pos:%d',i-1,min(slot_sto_diff(:,i)));
            figure('NumberTitle', 'on', 'Name', str);
            plot(slot_sto_diff(:,i),'.');
            title(str);
            grid on;
            hold on;
            plot(sn*sto_diff_max*1.2,'r');
         end
    end
    % 3D view
    str=sprintf('Ant%d sto diff signal with %d point %d',ant_num,len);
    figure('NumberTitle', 'on', 'Name', str);
    mesh(slot_sto_diff,'FaceAlpha','0.5');
    x1=xlabel('Symbol Direction: 1 -> 14');
    x2=ylabel('Sample subcarrier Direction: 1 -> 4096');
    x3=zlabel('Sample value scale in original scale');
    set(x1,'Rotation',30);
    set(x2,'Rotation',-30);
    %plot(abs(Ant_view));
    title(str);
    grid on;
    colorbar;
    
end