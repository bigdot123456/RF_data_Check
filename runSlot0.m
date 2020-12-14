%% clear environment
close all;
clear;
clc;

%% full load data
dpath0='/Users/liqinghua/RF_data/';

dfile_ant0='Recording_0000.csv';

%FILENAME=DFILE;
filename_ant0=dfile_ant0;
%filename_ant1=dfile_ant1;
dirpath=dpath0;

%Ant0=sprintf('%s%s',path,'FileUlLog_Instance0_Ant0.bin');
Ant0=[dirpath,filename_ant0];
%Ant1=[dirpath,filename_ant1];
IQ_float=csvread(Ant0);

%% input parameter
num_slot=20;
mark_slotoffset=0;
mark_symoffset=8;
mark_tsoffset=3785; % less then 4096

%% const parameter
len_IQ=1;
len_slot=14;
len_scp=288;
len_lcp=352;
len_sym=(4096+len_scp);%% normal cp, should 288, long cp should be 352
len_ts_per_slot=(len_slot*len_sym+len_lcp-len_scp)*len_IQ;
len=len_ts_per_slot*num_slot;

%% mark line parameter

mark_offset=mark_slotoffset*len_ts_per_slot+mark_symoffset*len_sym+mark_tsoffset;

view_IQ0=IQ_float(:,1)+1i*IQ_float(:,2);
view_IQ=view_IQ0(mark_offset:end);

%% view RF spectrum
plotRFSpectrum(view_IQ,num_slot);
%% view spectrum & IQ constellation
plotRFConstellation(view_IQ,num_slot);
