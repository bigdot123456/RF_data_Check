function [pxx,f]=RunOTAChecker(tF,viewNum,viewstart)
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
tAntData=readDDRBinData(tF,1);
%% start spectrum analyze
% 看20个slot数据，如需看30，将第二参数填30
[pxx,f]=plotNRPSD(tAntData,viewNum,viewstart);
end