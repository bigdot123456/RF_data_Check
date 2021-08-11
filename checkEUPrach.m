%% load data
clear;
clc;
close all;
load matlab1029.mat
load caps.mat
%%
% figure;
% plot(20*log10(abs(fd_35)),'.');
% grid on;
% title('FPGA freqency log Data,6-agc does not work');
%% seperate AntData
ant0=AntData(:,1);
ant1=AntData(:,3);
figure;plot(abs(ant0));title("Timing Pan View of Ant data");grid on; 
Ant_view=ant0;
%% split to symbol
% symAll=splitSlot2Symbol(Ant_view);
slotTsLen=61440;
%% view all slot
totalSlotNum=ceil(length(Ant_view)/slotTsLen);
for i=20:totalSlotNum
    %freq=plot1msBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
    plot1SlotBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
end
%% view special slot
% slotN=19;
% i=slotN+1;
% freqN=plot1SlotBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);

%% view last slot any symbol
viewSymbNum=1;
len=4096;
cp=288;
offset=(len+cp)*(14-viewSymbNum-1);
symb=Ant_view(end-offset-cp/2+1:end-offset-cp/2+len);
symb_freq=fft(symb);
symb_freq1=fftshift(symb_freq);
plot1SymbolConstellation(symb_freq1,4096);
%% compare with FPGA result
str=sprintf('Plot caps 35 Freqency spectrum');
figure('NumberTitle', 'on', 'Name', str);
plot(20*log10(abs(fd_35)),'.');
grid on;
title('FPGA 35 freqency log Data,6-agc does not work');

str=sprintf('Plot caps 64 Freqency spectrum');
figure('NumberTitle', 'on', 'Name', str);
plot(20*log10(abs(fd_64)),'.');
hold on;
plot(20*log10(abs(fd_35)),'.r');
grid on;
title('FPGA 64 freqency log Data,6-agc does not work');
%% get PRACH data
P_index=254;
P_prbNum=12;
slotN=19;

i=slotN+1;
%P_SlotData=Ant_view(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
%k1=
dist=P_index*12;

