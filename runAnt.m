%% clear environment
close all;
%clear;
%clc;

%% full load data
Ant0='FileUlLog_Instance0_Ant0.bin';
Ant1='FileUlLog_Instance0_Ant1.bin';

Ant0_IQ=readAnt(Ant0);
Ant1_IQ=readAnt(Ant1);

%% result
Ant0_freq=PlotSpectrum(Ant0_IQ);
Ant1_freq=PlotSpectrum(Ant1_IQ);

%% frequency figure demo
plot(Ant0_freq(:,12));
grid on;

%% scatter 画星座图
scatterplot(Ant0_IQ(:,13)); % 选定第13个符号
hold on;
rectangle('Position',[-1, -1, 2, 2],'Curvature',[1, 1]);axis equal; % 画圆