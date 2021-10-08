clear;
close all
clc;

filename='./File.iq/File_2021-10-08090021.complex.1ch.float32';
fID = fopen(filename,'r');
IQ=fread(fID,'float');
I=IQ(1:2:end);
Q=IQ(2:2:end);
cpx=I+Q*1i;

cpx1=[cpx;0];

% Process1msSignalSto(cpx1);

threshold=0.001;
cpx_abs=abs(cpx1);

cpx_abs_pos=cpx_abs<threshold;
cpx_abs1=cpx_abs;
cpx_abs1(cpx_abs_pos)=0;
plot(abs(cpx_abs1));

b=cpx_abs>threshold;
ind1=find(diff([0;b])==1); %大于绝对值大于threshold的数的开始位置
ind2=find(diff([b;0])==-1); %大于绝对值大于threshold的数的结束位置
mask=(ind2-ind1+1>=60); %长度大于等于60个的连续
ind1=ind1(mask); %连续60个绝对值大于threshold的数的开始位置
ind2=ind2(mask); %连续60个绝对值大于threshold的数的结束位置





