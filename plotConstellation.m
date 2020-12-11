function Ant_freq=plotConstellation(Ant_view,v_slot)
%% result
if nargin==1
    v_slot=0;
end

Ant_freq=PlotSpectrum(Ant_view);
%% frequency figure demo
str=sprintf('Plot slot %d freq',v_slot);
figure('NumberTitle', 'on', 'Name', str);
%figure('NumberTitle', 'off', 'Name', str);
for i=1:14
subplot(5,3,i);
plot(Ant_freq(:,i+v_slot*14));
str=sprintf('OFDM symbol:%d',i);
title(str);
hold on;
grid on;
end
%% scatter 画星座图
str=sprintf('Plot slot %d Constellation',v_slot);
figure('NumberTitle', 'on', 'Name', str);
for i=1:14
subplot(5,3,i);
hold on;
%scatterplot(Ant0_freq(:,i+v_slot*14));
%scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
Id=real(Ant_view(:,i+v_slot*14));
Qd=imag(Ant_view(:,i+v_slot*14));
%scatter(Id,Qd);
plot(Id(1:512),Qd(1:512),'.');
str=sprintf('OFDM symbol:%d',i);
title(str);
%rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
grid on;
end

