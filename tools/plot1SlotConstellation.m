function Ant_freq=plot1SlotConstellation(Ant_view,v_slot,len)
%% plot slot frequency & constellation result
if nargin==1
    v_slot=0;
    len=512;
elseif nargin==2
    len=512;
end

Ant_freq=PlotSpectrum(Ant_view);
%% frequency figure demo
str=sprintf('Plot slot %d freq with %d point',v_slot,len);
figure('NumberTitle', 'on', 'Name', str);
%figure('NumberTitle', 'off', 'Name', str);
for i=1:14
    subplot(5,4,i);
    plot(Ant_freq(:,i+v_slot*14),'.');
    str=sprintf('OFDM symbol:%d',i);
    title(str);
    grid on;
end
subplot(5,4,15);
plot(Ant_freq(1:2:end,3+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant0 symbol 3');
title(str);

subplot(5,4,16);
plot(Ant_freq(2:2:end,3+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant1 symbol 3');
title(str);

subplot(5,4,17);
plot(Ant_freq(1:2:end,12+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant0 symbol 12');
title(str);

subplot(5,4,18);
plot(Ant_freq(2:2:end,12+v_slot*14),'.');
title(str);
grid on;
str=sprintf('pilot ant1 symbol12');
title(str);


%% scatter 画星座图
str=sprintf('Plot slot %d Constellation',v_slot);
figure('NumberTitle', 'on', 'Name', str);
for i=1:14
    subplot(5,4,i);
    hold on;
    %scatterplot(Ant_freq(:,i+v_slot*14));
    %scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
    cpx=Ant_view(:,i+v_slot*14);
    Id=real(cpx);
    Qd=imag(cpx);
    
    %scatter(Id,Qd);
    plot(Id(1:len),Qd(1:len),'.');
    str=sprintf('OFDM symbol:%d',i);
    title(str);
    %rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
    grid on;
    if i==3
       subplot(5,4,15);
       plot(Id(1:2:len),Qd(1:2:len),'.');
       title(str);
       subplot(5,4,16);
       plot(Id(2:2:len),Qd(2:2:len),'.');
       title(str);
       %phase=derotate(cpx);display(phase);
       %
    end
    if i==12
       subplot(5,4,17);
       plot(Id(1:2:len),Qd(1:2:len),'.');
       title(str);
       subplot(5,4,18);
       plot(Id(2:2:len),Qd(2:2:len),'.');
       title(str);
       %phase=derotate(cpx);
       %display(phase);
    end
end

