clear;
close all;
clc;
%% run OTA frequency spectrum view
tF='~/log/sy/ddr_data1.txt'; % in CQ data
%tF='/Volumes/ORAN/L1/chendalong/11021638/t0_ddr_data.txt'; % in shelf box,5m
%% 读取数据
tAntData=readDDRBinData(tF,1);
%% start spectrum analyze
% 看20个slot数据，如需看30，将第二参数填30
plotNRPSD(tAntData,20);
