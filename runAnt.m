%% clear environment
close all;
clear;
clc;

%% full load data
Ant0='FileUlLog_Instance0_Ant0.bin';
Ant1='FileUlLog_Instance0_Ant1.bin';
v_slot=10;
ant=0;
Ant0_IQ=readAnt(Ant0);
Ant1_IQ=readAnt(Ant1);

Ant_view=Ant0_IQ;
%% result
Ant_freq=PlotSpectrum(Ant_view);

%% frequency figure demo
for i=1:14
subplot(5,3,i);
plot(Ant_freq(:,i+v_slot*14));
str=sprintf('OFDM symbol:%d',i);
title(str);
hold on;
grid on;
end
%% scatter 画星座图
figure;
for i=1:14
subplot(5,3,i);
hold on;
%scatterplot(Ant0_freq(:,i+v_slot*14));
%scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
Id=real(Ant_view(:,i+v_slot*14));
Qd=imag(Ant_view(:,i+v_slot*14));
scatter(Id,Qd);
str=sprintf('OFDM symbol:%d',i);
title(str);
%rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆
grid on;
end

