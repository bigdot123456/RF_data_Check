function [symbol,symbol_abs]=plot1SlotFreqencySignalConstellation(Ant_view,slot_num,ant_num)
if nargin==1
    slot_num=0;
    ant_num=0;
elseif nargin==2
    ant_num=0;
end
%% plot slot frequency & constellation result
symbol=reshape(Ant_view,[],14);
slotSymbNum=14;
%% check zero power
zerobit=0;
if(slot_num==19)
   pos=find(symbol==0); 
   if isempty(pos)
       zerobit=0;
   else
       fprintf("zerobit index is %d\n",pos);
       zerobit=1;
   end
end
%% start compare frequency domain analsys
MIN=-120;
symbol_abs=20*log10(abs(symbol));
symbol_abs(symbol_abs==-inf)=MIN;

t0=reshape(symbol_abs,[],1);
t1=ones(length(t0),1);

t_max=max(t0);
t_min=min(t0);
if t_max==-inf
    t_max=0;
end
if t_min==-inf
    t_min=t_max-60;
end
t1=t_min.*t1;

for i=1:slotSymbNum
    t1(i*4096)=t_max+10;
end
%% plot works
str=sprintf('Ant%d slot %d continuous frequency signal with %d point and zeronum %d',ant_num,slot_num,length(Ant_view),zerobit);
figure('NumberTitle', 'on', 'Name', str);
mesh(abs(symbol),'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample subcarrier Direction: 1 -> 3276');       
x3=zlabel('Sample value scale in original scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
%plot(abs(Ant_view));
title(str);
grid on;

str=sprintf('Ant%d slot %d symbol IQ abs log power frequency series with %d point',ant_num,slot_num,length(symbol_abs(:,1)));
figure('NumberTitle', 'on', 'Name', str);
% plot(t0,'.r');hold on;
% plot(t1,'b');
mesh(symbol_abs,'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample subcarrier Direction: 1 -> 3276');       
x3=zlabel('Sample value scale in db scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
title(str);
grid on;

%% plot every symbol spectrum
str=sprintf('Ant%d Plot slot %d Freqency spectrum',ant_num,slot_num);
figure('NumberTitle', 'on', 'Name', str);
subplot(3,5,15);
plot(symbol_abs,'.');
str=sprintf('slot:%d all symbol',slot_num);
title(str);
grid on;

for i=1:slotSymbNum
    subplot(3,5,i);
    plot(symbol_abs(:,i));
    symbol_max=max(symbol_abs(:,i));
    symbol_ave=mean(symbol_abs(:,i));
    str=sprintf('slot:%d symbol:%d,max:%d,ave:%d db\t',slot_num,i-1,ceil(symbol_max),ceil(symbol_ave));
    fprintf(str);
    title(str);
    %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
    grid on;
end

%% set basic data
Ant_freq=symbol;
%% start plot constellation
plot1SlotConstellation_Inner(Ant_freq(:,1:slotSymbNum),slot_num,512);
