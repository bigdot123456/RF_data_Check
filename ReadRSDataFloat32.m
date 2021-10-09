function [cpx,b_pos_edge,slot_sep_length]=ReadRSDataFloat32(filename)
%% plot slot frequency & constellation result
% [cpx,b_pos_edge,slot_sep_length]=ReadRSDataFloat32(filename)
% result is as following:
% [b_pos_edge,slot_sep_length]
% 
% ans =
% 
%        28446       61438 <-- 61440 is an integrated slot data
%       153028        4449 <-- one symbol data
%       214469        4447
%       274254      122828
%       398788        4449
%       407619       52610
%       521669        4448
%       642846       61436
% cpx is complex data of filename

global Debug_ReadAnt
if nargin==0
    filename='./File.iq/File_2021-10-08090021.complex.1ch.float32';
end
%% load data
fID = fopen(filename,'r');
IQ=fread(fID,'float');
I=IQ(1:2:end);
Q=IQ(2:2:end);
cpx=I+Q*1i;
cpx1=[cpx;0];
%% search head step 1
% Process1msSignalSto(cpx1);

threshold=0.001;
thresholdLow=threshold/3;

cpx_abs=abs(cpx1);

cpx_abs_pos=cpx_abs<threshold;
cpx_abs1=cpx_abs;
cpx_abs1(cpx_abs_pos)=0;

cpx_abs_posLow=cpx_abs<thresholdLow;
cpx_absLow=cpx_abs;
cpx_absLow(cpx_abs_posLow)=0;

%% search head step 2
b=cpx_abs>threshold;
b_len=length(b);
b_mask=zeros(size(b));
max_mask_len=256;

i=1;
while(i<(b_len-max_mask_len))
    if b(i)==1
        for k=max_mask_len:-1:1
            if b(i+k)==1
                b_mask(i:i+k)=1;
                i=i+k-1; %should be use b(i:i+k-1), since it will discontinue the search process if b(i+k+1)==0
                break
            end
        end
    end
    i=i+1;
end

b_mask_diff=diff(b_mask);
b_pos_edge=find(b_mask_diff==1);
b_neg_edge=find(b_mask_diff==-1);
slot_sep_length=b_neg_edge-b_pos_edge;

%% plot all data
% first for orignal contrast
if Debug_ReadAnt==1

    scale=max(abs(cpx_abs));
    fprintf("slot info:\n");
    fprintf("start pos:%d\t%d\n",[b_pos_edge,slot_sep_length]');
    
    str=sprintf('Orginal Data start with %d, first len:%d,total:%d point',b_pos_edge(1),slot_sep_length(1),b_len);
    figure('NumberTitle', 'on', 'Name', str);
    plot(abs(cpx_abs),'-');
    hold on;
    plot(b_mask*scale*1.1,'--r');
    title(str);
    grid on;
    axis([0,b_len+10,0,scale*1.2])
    
    
    str=sprintf('signal slot position detect system with %d point',b_len);
    figure('NumberTitle', 'on', 'Name', str);
    plot(abs(cpx_abs1),'--');
    hold on;
    plot(-abs(cpx_absLow),'r');
    title(str);
    grid on;
    axis([0,b_len+10,-threshold*10,threshold*10])
    
    % second for postion seperating
    
    pos1=1:b_len;
    str=sprintf('signal slot position detect system with %d point',b_len);
    figure('NumberTitle', 'on', 'Name', str);
    plot(pos1,1.1*b_mask);
    hold on;
    plot(pos1,b,'r');
    title(str);
    grid on;
    axis([0,b_len+10,0,1.5])
end
