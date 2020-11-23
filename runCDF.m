%% run CDF demo for NR check
clear;
initValue=0;
step=0.1;
sample1=[0.7,1.2,1.5,2.0,1.3,1.7,2.2,2.5,3.6];
sample2=[0.8,1.1,1.4,2.1,1.2,1.8,2.1,2.4,3.7,4.2,5.4];
endValue1=ceil(max(sample1));
endValue2=ceil(max(sample2));

endValue=max(endValue1,endValue2);

[xTime1,yPercentage1]=cdf(initValue,step,endValue,sample1);
[xTime2,yPercentage2]=cdf(initValue,step,endValue,sample2);

%% plot figure
plot(xTime1,yPercentage1,'r');
hold on;
plot(xTime2,yPercentage2,'g');
grid on;

ylabel('F(x)')
xlabel('Example(exp)')
legend('CDF曲线1','CDF曲线2');
title('NR CDF曲线');
