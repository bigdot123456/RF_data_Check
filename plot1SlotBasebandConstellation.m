function [symbolPC,symbol_abs,symbol_freq,symbol_freq_abs]=plot1SlotBasebandConstellation(Ant_view,slot_num,ant_num,en_phase_comp)
% function [symbolPC,symbol_abs,symbol_freq,symbol_freq_abs]=plot1SlotBasebandConstellation(Ant_view,slot_num,ant_num,en_phase_comp)
% here symbolPC: timing domain result for Ant_view with phase correction
% here symbol_abs: 20*log(symbolPC)
% symbol_freq: fft result of symbolPC
% symbol_freq_abs: 20 log result of symbol_freq 
if nargin==1
    slot_num=0;
    ant_num=0;
    en_phase_comp = 0;
elseif nargin==2
    ant_num=0;
    en_phase_comp = 1;
    fprintf("Open phase compensation!\n");
elseif nargin==3
    en_phase_comp = 1;
    fprintf("Open phase compensation!\n");
end
%% get phase compensation coeffcient
% centralFreqHz = 3500000000;%中心频点，单位Hz
% centralFreqHz = 2496000000;%%%ARFCN  499200
centralFreqHz = 2566890000;%%%ARFCN  513378  移动
% centralFreqHz = 3549540000;%%%ARFCN  636636  联通
coeff = phase_coeff(centralFreqHz,1);%Rx 1;Tx -1
%% plot slot frequency & constellation result
symbol=splitSlot2Symbol(Ant_view);
slotSymbNum=14;

if ( en_phase_comp == 1 )
    symbolPC = symbol(:,1:slotSymbNum).*coeff; %相位补偿
else
    symbolPC = symbol;
end
%% check zero power
zerobit=0;
if(slot_num==19)
   pos=find(symbolPC==0); 
   if isempty(pos)
       zerobit=0;
   else
       fprintf("zerobit index is %d\n",pos);
       zerobit=1;
   end
end
%% fft process
% data should be symbol(1:4096,1:14)
% symbol_freq_org=fft(symbolPC); 
% symbol_freq=fftshift(symbol_freq_org);

symbol_freq_org=zeros(size(symbol));
symbol_freq=symbol_freq_org;
%% ifft to get frequency data
for i=1:slotSymbNum
   symbol_freq_org(:,i)=fft(symbolPC(:,i)); 
   symbol_freq(:,i)=fftshift(symbol_freq_org(:,i));
end
%% start compare time domain & frequency domain analsys
MIN=-120;
symbol_abs=20*log10(abs(symbolPC));
symbol_abs(symbol_abs==-inf)=MIN;
symbol_freq_abs=20*log10(abs(symbol_freq));
symbol_freq_abs(symbol_freq_abs==-inf)=MIN;

t0=reshape(symbol_abs,[],1);
f0=reshape(symbol_freq_abs,[],1);
t1=ones(length(t0),1);
f1=ones(length(f0),1);

t_max=max(t0);
t_min=min(t0);
if t_max==-inf
    t_max=0;
end
if t_min==-inf
    t_min=t_max-60;
end
t1=t_min.*t1;

f_max=max(f0);
f_min=min(f0);

% if f_max==-inf
%     f_max=0;
% end
% if f_min==-inf
%     f_min=f_max-100;
% end

% 
% % change inf to valid data; 
% f0(f0==-inf)=f_min+1;
% t0(t0==-inf)=t_min+1;

f1=f_min.*f1;
for i=1:slotSymbNum
    f1(i*4096)=f_max+10;
    t1(i*4096)=t_max+10;
end
%% plot works
str=sprintf('Ant%d slot %d continuous timing signal with %d point and zeronum %d',ant_num,slot_num,length(Ant_view),zerobit);
figure('NumberTitle', 'on', 'Name', str);
mesh(abs(symbolPC),'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample Timing Direction: 1 -> 6144');       
x3=zlabel('Sample value scale in original scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
%plot(abs(Ant_view));
title(str);
grid on;

str=sprintf('Ant%d slot %d symbol IQ abs log power timing series with %d point',ant_num,slot_num,4096);
figure('NumberTitle', 'on', 'Name', str);
% plot(t0,'.r');hold on;
% plot(t1,'b');
mesh(symbol_abs,'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample Timing Direction: 1 -> 6144');       
x3=zlabel('Sample value scale in db scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
title(str);
grid on;

% str=sprintf('slot %d symbol fft frequency spectrum with %d point & ',slot_num,4096);
% figure('NumberTitle', 'on', 'Name', str);
% plot(f0,'r');hold on;
% plot(f1,'b');
% title(str);
% grid on;

%% plot every symbol spectrum
str=sprintf('Ant%d slot %d symbol freq log power with %d subcarrier',ant_num,slot_num,4096);
figure('NumberTitle', 'on', 'Name', str);
s=mesh(symbol_freq_abs,'FaceAlpha','0.5');
%s.FaceColor = 'flat';
str=sprintf('3D-view slot:%d all symbol with Freq psd',slot_num);
title(str);
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('subcarrier Direction: 1 -> 4096, Freq Center is 2048');       
x3=zlabel('sc value with db');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  

str=sprintf('Ant%d Plot slot %d Freqency spectrum',ant_num,slot_num);
figure('NumberTitle', 'on', 'Name', str);
subplot(3,5,15);
plot(symbol_freq_abs,'.');
str=sprintf('slot:%d all symbol',slot_num);
title(str);
grid on;

for i=1:slotSymbNum
    subplot(3,5,i);
    plot(symbol_freq_abs(:,i));
    symbol_freq_max=max(symbol_freq_abs(:,i));
    symbol_ave=mean(symbol_abs(:,i));
    str=sprintf('slot:%d symbol:%d,max:%d,ave:%d db\t',slot_num,i-1,ceil(symbol_freq_max),ceil(symbol_ave));
    fprintf(str);
    title(str);
    %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
    grid on;
end

%% set basic data
f_use=3276;
f_full=4096;
f_nouse=f_full-f_use;
f_left=f_nouse/2;
f_right=f_left+f_use-1;
Ant_freq=symbol_freq(f_left:f_right,:);
%% start plot constellation
plot1SlotConstellation_Inner(Ant_freq(:,1:slotSymbNum),slot_num,512);
