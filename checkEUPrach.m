%% load data
clear;
clc;
close all;

%allFolds = genpath( pwd );
addpath('./RX_MATLAB');
addpath('./OFDM--STO-CFO');
t=now;
datestr(t,0)
%% load EU input data
%load caps.mat
%load matlab1029.mat
%load './cap_data/matlab4.mat'
%load 'matlab1714.mat'
%load 'matlab1655.mat'
%load 'matlab0907.mat'
%load 'matlab1705.mat'
%load 'matlab1429.mat'
%load 'matlab1728.mat'
%load 'matlab1032.mat'
%load 'matlab1802.mat'
%load 'matlab1629.mat'
%load 'matlab1726.mat'
%oad 'matlab1709.mat'
view_freq=0;
view_time=1;
view_caps=0;
view_last=0;

% tAntData=t1AntData;
% tF='tladata.txt';
%tF='/Volumes/ORAN/L1/chendalong/cap_1627/t0_ddr_data.txt';
%tF='t1_ddr_data.txt';
%tF='./0926_1022/t1_ddr_data.txt';
%fF='./0926_1022/f3_ddr_data.txt';
tF='./1136/t0_ddr_data.txt';
%fF='./1136/f1_ddr_data.txt';
%fF='./0926_1022/f3_ddr_data.txt';
%fF='/mnt/oran/L1/chendalong/0926_1826/f1_ddr_data.txt';
%fF='/mnt/oran/L1/chendalong/0927_1114/f3_ddr_data.txt'; % in shelf box
%fF='/mnt/oran/L1/chendalong/0927_1142/f3_ddr_data.txt'; % in near point
fF='/mnt/oran/L1/chendalong/0927_1154/f1_ddr_data.txt'; % in near point，5m
tF='/mnt/oran/L1/chendalong/0928_0959/t0_ddr_data.txt'; % in shelf box,5m
%tF='/mnt/oran/L1/chendalong/0927_1114/t0_ddr_data.txt'; % in shelf box
%tF='~/Downloads/t1_ddr_data.txt'; % in shelf box,10m,bin format，2 stream
%tF='~/Downloads/t5_ddr_data.txt'; % in shelf box,10m,bin format,1 stream
fF='~/Downloads/f0_ddr_data.txt'; % in shelf box,10m,bin format

Bin_or_TXT=0; % 1: binary,0:txt
if view_freq==1
    if Bin_or_TXT==1
        fAntData=readDDRBinData(fF,0);
    else
        fAntData=readDDRData(fF,0);
    end
end
if view_time==1
    if Bin_or_TXT==1
        tAntData=readDDRBinData(tF,1);
    else
        tAntData=readDDRData(tF,1);
    end
end

coeff = phase_coeff;
%%
% figure;
% plot(20*log10(abs(fd_35)),'.');
% grid on;
% title('FPGA freqency log Data,6-agc does not work');
%% seperate AntData
if view_time
    tant0=tAntData(:,1);
    tant1=tAntData(:,3);
    %plot1msSignal(tant0,0);
    %plot1msSignal(tant1,1);
    Process1msSignal(tant0,0);
    Process1msSignal(tant1,1);
    %% detail signal analysis
    SymbNum=floor(length(tant0)/(4096+288));
    str=sprintf('Plot Ant0/1 full view');
    figure('NumberTitle', 'on', 'Name', str);grid on;
    titlestr=sprintf("Timing Pan View of Ant data with %d symol",SymbNum);
    ant_abs=[abs(tant0),abs(tant1)];
    plot(ant_abs,'.');title(titlestr);grid on;
    dim1=[0.85 0.85 0.90 0.90];%rectangle or ellipse(x,y)
    P1=[0.7 0.45]; % 建立从(x(1), y(1))到(x(2), y(2))的线注释对象
    P2=[0.7 0.45];
    annotation('arrow',P2,P1);
    text(61440*9,max(abs(tant0)+1),'\fontsize{15}slot9');
    str=sprintf('Plot Power Ant0/1 full view');
    figure('NumberTitle', 'on', 'Name', str);grid on;
    titlestr=sprintf("Timing Pan View of Ant data Power with %d symol",SymbNum);
    ant_abs_log=[20*log10(abs(tant0)),20*log10(abs(tant1))];
    plot(ant_abs_log,'.');title(titlestr);grid on;
    dim1=[0.85 0.85 0.90 0.90];%rectangle or ellipse(x,y)
    P2=[0.7 0.45];
    P1=[0.7 0.45];
    annotation('arrow',P2,P1);
    text(61440*9,max(ant_abs_log(:,1))+1,'\fontsize{15}slot9');
    Ant_view=tant0;
    %% split to symbol
    % symAll=splitSlot2Symbol(Ant_view);
    slotTsLen=61440;
    %% view all slot
    totalSlotNum=ceil(length(tant0)/slotTsLen);
    sym0=zeros(4096,totalSlotNum*14);
    sym1=zeros(4096,totalSlotNum*14);
    UpNum=0;
    for i=9:10
        %freq=plot1msBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
        tRange=(i-1)*slotTsLen+1:i*slotTsLen;
        [~,~,~,sym0(:,UpNum*14+(1:14))]=plot1SlotBasebandConstellation(tant0(tRange),i-1,0);
        [~,~,~,sym1(:,UpNum*14+(1:14))]=plot1SlotBasebandConstellation(tant1(tRange),i-1,1);
        UpNum=UpNum+1;
    end
    for i=219:totalSlotNum
        %freq=plot1msBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
        tRange=(i-1)*slotTsLen+1:i*slotTsLen;
        %[symbolPC,symbol_abs,symbol_freq,symbol_freq_abs]
        [~,~,~,sym0(:,UpNum*14+(1:14))]=plot1SlotBasebandConstellation(tant0(tRange),i-1,0);
        [~,~,~,sym1(:,UpNum*14+(1:14))]=plot1SlotBasebandConstellation(tant1(tRange),i-1,1);
        UpNum=UpNum+1;
    end
    
    %% view continue slot
    if UpNum>0
        str=sprintf('Ant0 total %d slot IQ abs log power freq series with %d point',UpNum,4096);
        figure('NumberTitle', 'on', 'Name', str);
        % plot(t0,'.r');hold; on;
        % plot(t1,'b');
        mesh(sym0(:,1:UpNum*14),'FaceAlpha','0.5');
        x1=xlabel('Symbol Direction: 1 -> 14');
        x2=ylabel('Sample sc Direction: 1 -> 4096');
        x3=zlabel('Sample value scale in db scale');
        set(x1,'Rotation',30);
        set(x2,'Rotation',-30);
        title(str);
        grid on;
        colorbar;
        
        str=sprintf('Ant1 total %d slot IQ abs log power freq series with %d point',UpNum,4096);
        figure('NumberTitle', 'on', 'Name', str);
        % plot(t0,'.r');hold; on;
        % plot(t1,'b');
        mesh(sym1(:,1:UpNum*14),'FaceAlpha','0.5');
        x1=xlabel('Symbol Direction: 1 -> 14');
        x2=ylabel('Sample sc Direction: 1 -> 4096');
        x3=zlabel('Sample value scale in db scale');
        set(x1,'Rotation',30);
        set(x2,'Rotation',-30);
        title(str);
        grid on;
        colorbar;
    end
    %% view last slot any symbol
    if view_last>0
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
        
    end
end
%% view special slot
% slotN=19;
% i=slotN+1;
% freqN=plot1SlotBasebandConstellation(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
% freqAntData=ff0AntData;

%% view EU frequecy domain result
if view_freq
    
    fant0=fAntData(:,1);
    fant1=fAntData(:,3);
    
    plot1msFreqencySignal(fant0,0);
    plot1msFreqencySignal(fant1,1);
    %% view detail signal
    slotScLen=3276*14;
    totalSlotNum=ceil(length(fant0)/slotScLen);
    
    str=sprintf('Plot Ant0/1 full freq view');
    figure('NumberTitle', 'on', 'Name', str);grid on;
    titlestr=sprintf("Timing Pan View of Ant data with %d symol",totalSlotNum);
    ant_abs=[abs(fant0),abs(fant1)];
    plot(ant_abs,'.');title(titlestr);grid on;
    dim1=[0.85 0.85 0.90 0.90];%rectangle or ellipse(x,y)
    P1=[0.7 0.45]; % 建立从(x(1), y(1))到(x(2), y(2))的线注释对象
    P2=[0.7 0.45];
    annotation('arrow',P2,P1);
    text(61440*9,max(abs(fant0)+1),'\fontsize{15}slot9');
    str=sprintf('Plot Power Ant0/1 full view');
    figure('NumberTitle', 'on', 'Name', str);grid on;
    titlestr=sprintf("Timing Pan View of Ant data Power with %d symol",totalSlotNum);
    ant_abs_log=[20*log10(abs(fant0)),20*log10(abs(fant1))];
    plot(ant_abs_log,'.');title(titlestr);grid on;
    dim1=[0.85 0.85 0.90 0.90];%rectangle or ellipse(x,y)
    P2=[0.7 0.45];
    P1=[0.7 0.45];
    annotation('arrow',P2,P1);
    text(61440*9,max(ant_abs_log(:,1))+1,'\fontsize{15}slot9');
    slotFsLen=3276*14;
    for i=9:10
        fRange=(i-1)*slotFsLen+1:i*slotFsLen;
        Ant_view0=fant0(fRange);
        Ant_view1=fant1(fRange);
        
        [symbol0,symbol_abs0]=plot1SlotFreqencySignalConstellation(Ant_view0,i-1,0);
        [symbol1,symbol_abs1]=plot1SlotFreqencySignalConstellation(Ant_view1,i-1,1);
        
    end
    for i=219:totalSlotNum
        fRange=(i-1)*slotFsLen+1:i*slotFsLen;
        Ant_view0=fant0(fRange);
        Ant_view1=fant1(fRange);
        
        [symbol0,symbol_abs0]=plot1SlotFreqencySignalConstellation(Ant_view0,i-1,0);
        [symbol1,symbol_abs1]=plot1SlotFreqencySignalConstellation(Ant_view1,i-1,1);
    end
    %% view special slot 8/9
    
end
%% compare with FPGA result
if view_caps
    str=sprintf('Plot caps 35 Freqency spectrum');
    figure('NumberTitle', 'on', 'Name', str);
    plot(20*log10(abs(fd_35)),'.');
    grid on;
    title('FPGA 35 freqency log Data,6-agc does not work');
    
    str=sprintf('Plot caps 64 Freqency spectrum');
    figure('NumberTitle', 'on', 'Name', str);
    plot(20*log10(abs(fd_64)),'.');
    hold; on;
    plot(20*log10(abs(symb_freqFPGA1))+96,'.r');
    grid on;
    title('FPGA 64 & FFT Bit ACC freqency log Data,6-agc does not work');
end
%% get PRACH data
slotN=19;
i=slotN+1;
%P_SlotData=Ant_view(Ant_view((i-1)*slotTsLen+1:i*slotTsLen),i-1);
%k1=
%dist=P_index*12;
%%
t=now;
datestr(t,0)

% view([45 25]) %将方位角设置为 45 度，将仰角设置为 25 度。

% view([20 25 5]) %将视线设置为指向与向量 [20 25 5] 相同方向的向量。
