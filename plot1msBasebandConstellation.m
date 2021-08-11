function Ant_freq=plot1msBasebandConstellation(Ant_view,slot_num)
if nargin==1
    slot_num=0;
end
%% plot slot frequency & constellation result
symbol28=split1ms2Symbol28(Ant_view);
symbol28_freq_org=zeros(size(symbol28));
symbol28_freq=symbol28_freq_org;
%% ifft to get frequency data
for i=1:28
   symbol28_freq_org(:,i)=ifft(symbol28(:,i)); 
   symbol28_freq(:,i)=fftshift(symbol28_freq_org(:,i));
end
%% start compare time domain & frequency domain analsys
MIN=-120;
symbol28_abs=20*log10(abs(symbol28));
symbol28_abs(symbol28_abs==-inf)=MIN;
symbol28_freq_abs=20*log10(abs(symbol28_freq));
symbol28_freq_abs(symbol28_freq_abs==-inf)=MIN;

t0=reshape(symbol28_abs,[],1);
f0=reshape(symbol28_freq_abs,[],1);
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
for i=1:28
    f1(i*4096)=f_max+10;
    t1(i*4096)=t_max+10;
end
%% plot works
str=sprintf('slot %d:%d continuous timing signal with %d point ',2*slot_num,2*slot_num+1,length(Ant_view));
figure('NumberTitle', 'on', 'Name', str);
plot(abs(Ant_view));
title(str);
grid on;

str=sprintf('slot %d:%d symbol IQ abs log power timing series with %d point',2*slot_num,2*slot_num+1,4096);
figure('NumberTitle', 'on', 'Name', str);
plot(t0,'.r');hold on;
plot(t1,'b');
title(str);
grid on;
str=sprintf('slot %d:%d symbol fft frequency spectrum with %d point & ',2*slot_num,2*slot_num+1,4096);
figure('NumberTitle', 'on', 'Name', str);
plot(f0,'r');hold on;
plot(f1,'b');
title(str);
grid on;

%% plot every symbol spectrum
str=sprintf('Plot slot %d Freqency spectrum',2*slot_num);
figure('NumberTitle', 'on', 'Name', str);
for i=1:14
    subplot(3,5,i);
    plot(symbol28_freq_abs(:,i));
    str=sprintf('slot:%d symbol:%d',2*slot_num,i);
    title(str);
    %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
    grid on;
end
str=sprintf('Plot slot %d Freqency spectrum',2*slot_num+1);
figure('NumberTitle', 'on', 'Name', str);
for i=1:14
    subplot(3,5,i);
    plot(symbol28_freq_abs(:,i+14));
    str=sprintf('slot:%d symbol:%d',2*slot_num+1,i);
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
Ant_freq=symbol28_freq(f_left:f_right,:);
%% start plot constellation
plot1SlotConstellation_Inner(Ant_freq(:,1:14),2*slot_num,512);
plot1SlotConstellation_Inner(Ant_freq(:,15:28),2*slot_num+1,512);
% %% scatter 画星座图
% str=sprintf('Plot slot %d Constellation',v_slot);
% figure('NumberTitle', 'on', 'Name', str);
% for i=1:14
%     subplot(5,4,i);
%     hold on;
%     %scatterplot(Ant_freq(:,i+v_slot*14));
%     %scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
%     cpx=Ant_freq(:,i);
%     Id=real(cpx);
%     Qd=imag(cpx);
%     
%     %scatter(Id,Qd);
%     plot(Id(1:len),Qd(1:len),'.');
%     str=sprintf('OFDM symbol:%d',i);
%     title(str);
%     %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
%     grid on;
%     if i==3
%        subplot(5,4,15);
%        plot(Id(1:2:len),Qd(1:2:len),'.');
%        title(str);
%        subplot(5,4,16);
%        plot(Id(2:2:len),Qd(2:2:len),'.');
%        title(str);
%        %phase=derotate(cpx);display(phase);
%        %
%     end
%     if i==12
%        subplot(5,4,17);
%        plot(Id(1:2:len),Qd(1:2:len),'.');
%        title(str);
%        subplot(5,4,18);
%        plot(Id(2:2:len),Qd(2:2:len),'.');
%        title(str);
%        %phase=derotate(cpx);
%        %display(phase);
%     end
% end

