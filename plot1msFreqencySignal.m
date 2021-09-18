function plot1msFreqencySignal(Ant_view,ant_num)
if nargin==1
    ant_num=0;
end
MIN=30;

SymbSCNum=3276;
symbol=reshape(Ant_view,[],SymbSCNum);
%% start compare frequency domain analsys
symbol_abs=20*log10(abs(symbol));
symbol_abs(symbol_abs==-inf)=MIN;
%% plot signal with 3D view
str=sprintf('Ant%d continuous frequency signal with %d point',ant_num,length(Ant_view));
figure('NumberTitle', 'on', 'Name', str);
mesh(symbol_abs,'FaceAlpha','0.5');
x1=xlabel('Symbol Direction: 1 -> 14');       
x2=ylabel('Sample subcarrier Direction: 1 -> 3276');       
x3=zlabel('Sample value scale in original scale');       
set(x1,'Rotation',30);   
set(x2,'Rotation',-30);  
%plot(abs(Ant_view));
title(str);
grid on;
end