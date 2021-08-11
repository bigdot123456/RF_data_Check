function Ant_freq=plot1SlotBasebandConstellation(Ant_view,slot_num)
if nargin==1
    slot_num=0;
end
%% plot slot frequency & constellation result
symbol=splitSlot2Symbol(Ant_view);
slotSymbNum=14;

% data should be symbol(1:4096,1:14)
symbol_freq_org=fft(symbol); 
symbol_freq=fftshift(symbol_freq_org);

% symbol_freq_org=zeros(size(symbol));
% symbol_freq=symbol_freq_org;
% %% ifft to get frequency data
% for i=1:slotSymbNum
%    symbol_freq_org(:,i)=fft(symbol(:,i)); 
%    symbol_freq(:,i)=fftshift(symbol_freq_org(:,i));
% end
%% start compare time domain & frequency domain analsys
MIN=-120;
symbol_abs=20*log10(abs(symbol));
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
str=sprintf('slot %d continuous timing signal with %d point ',slot_num,length(Ant_view));
figure('NumberTitle', 'on', 'Name', str);
mesh(abs(symbol),'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample Timing Direction: 1 -> 6144');       
x3=zlabel('Sample value scale in original scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
%plot(abs(Ant_view));
title(str);
grid on;

str=sprintf('slot %d symbol IQ abs log power timing series with %d point',slot_num,4096);
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
str=sprintf('slot %d symbol freq log power with %d subcarrier',slot_num,4096);
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

str=sprintf('Plot slot %d Freqency spectrum',slot_num);
figure('NumberTitle', 'on', 'Name', str);
subplot(3,5,15);
plot(symbol_freq_abs,'.');
str=sprintf('slot:%d all symbol',slot_num);
title(str);
grid on;

for i=1:slotSymbNum
    subplot(3,5,i);
    plot(symbol_freq_abs(:,i));
    str=sprintf('slot:%d symbol:%d',slot_num,i-1);
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
