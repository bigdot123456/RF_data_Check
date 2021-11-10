function [pxx,f]=RunOTACheckerAll(tF,viewNum,viewstart)
%% function RunOTAChecker(tF,viewNum,viewstart)
% tF: Filename 数据文件名，缺省是当前目录下ddr_data.txt
% viewNum：看20个slot数据，如需看30，将第二参数填30，缺省看20个。
% viewstart： 从那个slot看DMRS和时域信号，缺省从slot1开始
if nargin<1
    tF="./ddr_data.txt";
end
% 看20个slot数据，如需看30，将第二参数填30
if nargin<2
    viewNum=20;
end
if nargin<3
    viewstart=1;
end
if viewstart<1
    viewstart=1;
end
%% 读取数据
tAntData=readDDRBinDataMAC(tF,1);
%% start spectrum analyze
% 看20个slot数据，如需看30，将第二参数填30
[pxx,f]=plotNRPSDMAC(tAntData,viewNum,viewstart);
end

%% read data
% DDR data reader
function AntData=readDDRBinDataMAC(filename,tFlag,swapAnt23)
%% read data from csv files
if nargin==0
    filename = '~/Downloads/t0_ddr_data.txt';
    tFlag=1;
    swapAnt23=1;
elseif nargin==1
    tFlag=1;
    swapAnt23=1;
elseif nargin==2
    swapAnt23=1;
end

bitWidth=16;
%% set parameter
if tFlag==1
    SYMB0_LEN=4448;
    SYMBX_LEN=4384;
    SYMBDDR_LEN =4464;
    SLOT_LEN =61440;

else
    SYMB0_LEN=3276;
    SYMBX_LEN=3276;
    SYMBDDR_LEN =4464;
    SLOT_LEN =61440;
end
SLOT_SYMB_NUM=14;
ANT_NUM =4;


%% read file
% a=readtable(filename,'Delimiter',' ','ReadVariableNames',false);
%conver 32bit data to IQ data
[fID,errMsg] = fopen(filename,'r');
if fID<0
    disp(errMsg);
    error("Can't Open File!")
end
IQ=fread(fID,'int16');
len=floor(length(IQ)/2);
I0=IQ(1:2:len*2);
Q0=IQ(2:2:len*2);


IQ = I0 + 1i*Q0;
%% reshape data
SLOT_NUM0=floor(length(IQ)/(SLOT_LEN*ANT_NUM));
SLOT_NUM=floor(SLOT_NUM0/20)*20;
%SLOT_NUM = catch_symb_num/SLOT_SYMB_NUM;
SlotSymNum = (SYMB0_LEN+SYMBX_LEN*13);

AntData = zeros(SlotSymNum*SLOT_NUM,ANT_NUM);
for i=1:SLOT_NUM
    for j=1:SLOT_SYMB_NUM
        for k=1:ANT_NUM
            start_pos = SlotSymNum*(i-1)+ SYMBX_LEN*(j-1) + (j>1)*(SYMB0_LEN-SYMBX_LEN);
            if j == 1
                len = SYMB0_LEN;
            else
                len = SYMBX_LEN;
            end
            AntData(start_pos+(1:len),k) = IQ((i-1)*ANT_NUM*SYMBDDR_LEN*SLOT_SYMB_NUM + (j-1)*ANT_NUM*SYMBDDR_LEN + (k-1)*SYMBDDR_LEN + (1:len));
        end
    end
end

%% swap ant data
if(swapAnt23==1)
    t2=AntData(:,2);
    t3=AntData(:,3);
    AntData(:,2)=t3;
    AntData(:,3)=t2;
end

end

%% plot PSD
function [pxx,f]=plotNRPSDMAC(Ant_view,viewNum,viewstart)
if nargin<2
    viewNum=20;
end
if nargin<3
    viewstart=1;
end
if viewstart<1
    viewstart=1;
end
%% plot 1ms signal with psd view
[len,dim]=size(Ant_view);
fs=122.88e6;
len_slot=61440;

len_fft=4096;
len_scp=288;
posDmrs=2;
mslot=floor(len/len_slot);
nslot=min(viewNum+viewstart-1,mslot);
dmrsViewlen=512;
View0=floor((len_fft-dmrsViewlen)/2);
viewSN=1:2:dmrsViewlen;
viewSN1=View0+viewSN;
viewSN2=View0+viewSN+1;

%% signal direct view
str=sprintf('查看整个时域信号，采用镜像模式，正数为Ant0，负数为Ant1');
figure('NumberTitle', 'on', 'Name', str);
viewDataAbs=abs(Ant_view);
% RU0
titlestr=sprintf("RRU0两根天线时域信号");
title(titlestr);
plot(viewDataAbs(:,1),'b');
hold;grid on;
plot(-viewDataAbs(:,2),'r');
title('ru0 Ant0b ru0 Ant1-r');
% RU1
titlestr=sprintf("RRU1两根天线时域信号");
figure('NumberTitle', 'on', 'Name', str);
title(titlestr);
plot(viewDataAbs(:,3),'b');
hold;grid on;
plot(-viewDataAbs(:,4),'r');
title('ru1 Ant0b ru0 Ant1-r');
%% spectrum
str=sprintf('Plot Freqency spectrum (center shift) with %d point',len);
figure('NumberTitle', 'on', 'Name', str);

[pxx,f] = pwelch(Ant_view,len_fft,0,len_fft,fs,'centered','power');

plot(f,10*log10(pxx))
grid on;
xlabel('Frequency (Hz)')
ylabel('PSD (dB/Hz)')
titlestr=sprintf('全频谱MAX hold无叠加模式总带宽122.88MHz');
title(titlestr);
%% another method
str=sprintf('Full Plot Freqency spectrum (origin view) with %d point&122.88MHz',len);
figure('NumberTitle', 'on', 'Name', str);
pwelch(Ant_view);
titlestr=sprintf('全频谱重复谱估计总带宽122.88MHz，没有进行正负带宽搬移');
title(titlestr);
%% plot every slot
for i=viewstart:nslot
    str=sprintf('slot%d Freqency spectrum  with 61440 总带宽: 122.88MHz',i-1);
    fprintf(str);
    figure('NumberTitle', 'on', 'Name', str);
    pos=(i-1)*len_slot+(1:len_slot);
    for j=1:dim
        subplot(2,dim/2,j)
        pwelch(Ant_view(pos,j),len_fft,288,len_fft,fs,'centered','power');
        titlestr=sprintf('slot%d RRU%d天线%d频谱',i-1,floor(j/2),mod(j,2));
        title(titlestr);
    end
    posView=(i-1)*len_slot+(len_fft+len_scp)*posDmrs+len_scp/2+(1:4096);
    viewDataDmrs=Ant_view(posView,:);
    viewDataDmrsFre=fftshift(fft(viewDataDmrs),1);


    str=sprintf('slot%d DMRS 星座图（需要解旋转与均衡）',i);
    figure('NumberTitle', 'on', 'Name', str);
    %scatter(Id,Qd);
    for j=1:dim
        subplot(2,dim/2,j)

        Id=real(viewDataDmrsFre(:,j));
        Qd=imag(viewDataDmrsFre(:,j));

        plot(Id(viewSN1),Qd(viewSN1),'.');
        hold;
        plot(Id(viewSN2),Qd(viewSN2),'.m');

        titlestr=sprintf('slot%d RRU%d天线%d 星座图',i-1,floor(j/2),mod(j,2));
        title(titlestr);
        grid on;
    end
end
end