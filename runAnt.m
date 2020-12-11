%% clear environment
close all;
clear;
clc;

%% full load data
dpath0='/Users/liqinghua/RF_data/D256QAM/';
upath0='/Users/liqinghua/RF_data/U64QAM/';
upath1='/Users/liqinghua/RF_data/UQPSK/';

ufile_ant0='FileUlLog_Instance0_Ant0.bin';
ufile_ant1='FileUlLog_Instance0_Ant1.bin';
dfile_ant0='FileDlLog_Instance0_Ant0.bin';
dfile_ant1='FileDlLog_Instance0_Ant1.bin';

%FILENAME=DFILE;
filename_ant0=ufile_ant0;
filename_ant1=ufile_ant1;
dirpath=upath0;

%Ant0=sprintf('%s%s',path,'FileUlLog_Instance0_Ant0.bin');
Ant0=[dirpath,filename_ant0];
Ant1=[dirpath,filename_ant1];

v_slot=2;
ant=0;
Ant0_IQ=readAnt(Ant0);
Ant1_IQ=readAnt(Ant1);

Ant_view=Ant0_IQ;

%% plot all data
for i=0:10
    plotConstellation(Ant_view,i);
end