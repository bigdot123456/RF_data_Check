function [slot_sto_diff_min]=Process1msSignalSto(Ant_view,ant_num)
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
y=[Ant_view;Ant_view(1:2*len_fft,1);zeros(len_lcp,1)];
len=length(Ant_view);
searchLen=len;

sto_diffsum=zeros(1,searchLen);
for k =1:searchLen
    pos1=(k:k+len_scp-1);
    pos2=pos1+len_fft;
    temp = abs(y(pos1)) - abs(y(pos2));
    SquareSum=sum(temp.^2);
    sto_diffsum(k) = SquareSum;
end

[sto_diff_min,STO_est]=min(sto_diffsum);
slotNum=floor(len/len_slot_ts);
slot_sto_diff_min=reshape(sto_diff_min(1:slotNum*len_slot_ts),len_slot_ts,slotNum);

%% plot all debug figure
if Debug_slotSTO_CFO
    % full view
    str=sprintf('sto with %d point',len);
    figure('NumberTitle', 'on', 'Name', str);
    plot(sto_diff_min,'.m');
    title(str);
    grid on;
    % slot view
    for i=1:slotNum
        str=sprintf('slot %d sto with value %d pos:%d',i,min(slot_sto_diff_min(:,i)));
        figure('NumberTitle', 'on', 'Name', str);
        plot(slot_sto_diff_min(:,i),'.m');
        title(str);
        grid on;
        
    end
    
    % 3D view
    str=sprintf('Ant%d sto signal with %d point and zeronum %d',ant_num,len);
    figure('NumberTitle', 'on', 'Name', str);
    mesh(slot_sto_diff_min,'FaceAlpha','0.5');
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
