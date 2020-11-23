function [xTime,yPercentage]=cdf(initValue,step,endValue,sample)
xTime=[];
yPercentage=[];
totalNum=length(sample);
for i=initValue:step:endValue
    temp=length(find(sample<=i))/totalNum;
    xTime=[xTime,i];
    yPercentage=[yPercentage,temp];
end
