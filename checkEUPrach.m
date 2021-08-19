%% load data
clear;
clc;
close all;
%allFolds = genpath( pwd );
addpath('./RX_MATLAB');
t=now;
datestr(t,0)
%% load EU input data
load caps.mat
%load matlab1029.mat
%load './cap_data/matlab4.mat'
%load 'matlab1714.mat'
load 'matlab1655.mat'
coeff = phase_coeff;
%%
% figure;
% plot(20*log10(abs(fd_35)),'.');
% grid on;
% title('FPGA freqency log Data,6-agc does not work');
%% seperate AntData
ant0=t1AntData(:,1);
ant1=t1AntData(:,3);
str=sprintf('Plot Ant0 full view');
figure('NumberTitle', 'on', 'Name', str);grid on;
plot(abs(ant0));title("Timing Pan View of Ant data");grid on; 
Ant_view=ant0;
%% split to symbol
% symAll=splitSlot2Symbol(Ant_view);
slotTsLen=61440;
%% view all slot
totalSlotNum=ceil(length(ant0)/slotTsLen);

for i=21:totalSlotNum
    %freq=plot1msBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
    tRange=(i-1)*slotTsLen+1:i*slotTsLen;
    plot1SlotBasebandConstellation(ant0(tRange),i-1,0);
    plot1SlotBasebandConstellation(ant1(tRange),i-1,1);
end
%% view special slot
% slotN=19;
% i=slotN+1;
% freqN=plot1SlotBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);

%% view EU frequecy domain result
fant0=f1AntData(:,1);
fant1=f1AntData(:,3);

slotFsLen=3276*14;
for i=20:totalSlotNum
    fRange=(i-1)*slotFsLen+1:i*slotFsLen;
    Ant_view0=fant0(fRange);
    Ant_view1=fant1(fRange);
    
    [symbol0,symbol_abs0]=plot1SlotFreqencySignalConstellation(Ant_view0,i-1,0);
    [symbol1,symbol_abs1]=plot1SlotFreqencySignalConstellation(Ant_view1,i-1,1);
end
%% view last slot any symbol
viewSymbNum=1;
len=4096;
cp=288;
offset=(len+cp)*(14-viewSymbNum-1);
symb=Ant_view(end-offset-cp/2+1:end-offset-cp/2+len);
symbPC0=symb.*coeff(2);
%( OrigValue, FixPtDataType, FixPtScaling, RndMeth, DoSatur )
% num2fixpt(19.875, sfix(8), 2^-2, 'Floor', 'on')
% coeff=num2fixpt(coeff0,sfix(16),2^-15, 'Floor', 'on');
symbPC=num2fixpt(symbPC0,sfix(16),2^0, 'Floor', 'on');

symb_freq=fft(symbPC);
symb_freq1=fftshift(symb_freq);
plot1SymbolConstellation(symb_freq1,4096,'MATLAB');

%symb_freqFPGA=fftFPGA(symbPC);
symb_freqFPGA=fft(symbPC);
symb_freqFPGA1=fftshift(symb_freqFPGA);
plot1SymbolConstellation(symb_freqFPGA1,4096,'FPGA FFT');
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
plot(20*log10(abs(symb_freqFPGA1))+96,'.r');
grid on;
title('FPGA 64 & FFT Bit ACC freqency log Data,6-agc does not work');
%% get PRACH data
slotN=19;
i=slotN+1;
%P_SlotData=Ant_view(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
%k1=
%dist=P_index*12;

