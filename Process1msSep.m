function [b_pos_edge,slot_sep_length,slot_blank_length]=Process1msSep(cpx,ThresholdRef)
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
% cpx is complex data
%% search head step 1
% Process1msSignalSto(cpx1);
global Debug_SlotSep

cpx_abs=abs([0;cpx]);

max_cpx_abs=max(abs(cpx_abs));

if nargin==1
    %threshold=0.001;
    threshold=max_cpx_abs/16;
else
    threshold=ThresholdRef;
end

thresholdLow=threshold/3;

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
b_pos_edge0=find(b_mask_diff==1);
b_neg_edge0=find(b_mask_diff==-1);
len_n=length(b_neg_edge0);
len_p=length(b_pos_edge0);
if len_n >len_p
    fprinft("error with data,dispose 1 negdge");
end

viewNum=min(length(b_pos_edge0),length(b_neg_edge0));
b_neg_edge=b_neg_edge0(1:viewNum);
b_pos_edge=b_pos_edge0(1:viewNum);
slot_sep_length=b_neg_edge(1:viewNum)-b_pos_edge(1:viewNum);
slot_blank_length=b_pos_edge(2:viewNum)-b_neg_edge(1:viewNum-1);
slot_blank_length=[slot_blank_length;0];

ts=122.88;
slot_sep_t=slot_sep_length/ts;
slot_blank_t=slot_blank_length/ts;
%% plot all data
% first for orignal contrast
if Debug_SlotSep==1
    
    fprintf("slot info with %d tx-rx switch:\n",length(b_pos_edge));
    fprintf("start pos:%d(r)-%d(f)\t\t%d\t%d\tlast: %4.2f\tblank：%4.2f us\n",[b_pos_edge,b_neg_edge,slot_sep_length,slot_blank_length,slot_sep_t,slot_blank_t]');
    
    str=sprintf('Orginal Data start with %d, first len:%d,total:%d point',b_pos_edge(1),slot_sep_length(1),b_len);
    figure('NumberTitle', 'on', 'Name', str);
    plot(abs(cpx_abs),'-');
    hold on;
    plot(b_mask*max_cpx_abs*1.1,'--r');
    title(str);
    grid on;
    axis([0,b_len+10,0,max_cpx_abs*1.2])
    
    
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
