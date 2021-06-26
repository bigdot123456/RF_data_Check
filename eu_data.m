%% get EU data
clear;
close all;
clc;

dirpath='/Users/liqinghua/RF_data/';
filename_ant0='eu_lte_data2_8192_no_T.csv';
iq_name='u_eu_cpri10_top_u_eu_10g_dm_dl_intf_lte_dl_dat0_31_0_';
LTE_eu=[dirpath,filename_ant0];
fprintf('eu ant file: %s\n',LTE_eu);
opts = detectImportOptions(LTE_eu);
preview(LTE_eu,opts)
% getvaropts(opts,{'TaxiIn','TaxiOut'})
% opts = setvartype(opts,{'TaxiIn','TaxiOut'},'double');
getvaropts(opts,{iq_name})
opts = setvartype(opts,{iq_name},'string');
%% here is eu orignal data
a=readtable(LTE_eu,opts);
b=eval(['a.',iq_name]);
%b=a.u_eu_cpri10_top_u_eu_10g_dm_dl_intf_lte_dl_dat0_31_0_;
% convert to data
b_len=length(b);
IQ=zeros(b_len,2);
for i=1:b_len
    [IQ(i,1),IQ(i,2)]=iLAHex2IQ(b(i));
end


%% start point
sp=2778;
%% convert to valid IQ data;
IQ0=IQ(sp:end,1)+1i*IQ(sp:end,2);
IQ1=IQ0(1:2:end);
% every 8 is ant0, another 8 is ant1
full_ind=0:length(IQ1)-1;
ind0=find(mod(full_ind,16)<8);
ind1=find(mod(full_ind,16)>=8);

ant0=IQ1(ind0);
ant1=IQ1(ind1);
%% plot data
cp_len=160;
plotLTE(ant0(cp_len+1:cp_len+2048));
plotLTE(ant1(cp_len+1:cp_len+2048));
