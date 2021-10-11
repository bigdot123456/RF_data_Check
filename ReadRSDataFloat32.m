function [cpx]=ReadRSDataFloat32(filename)
%% plot slot frequency & constellation result
% [cpx,b_pos_edge,slot_sep_length]=ReadRSDataFloat32(filename)
% result is as following:
% [b_pos_edge,slot_sep_length]
% 
% ans =
% 
%        28446       61438 <-- 61440 is an integrated slot data
%       153028        4449 <-- one symbol data
%       214469        4447
%       274254      122828
%       398788        4449
%       407619       52610
%       521669        4448
%       642846       61436
% cpx is complex data of filename

if nargin==0
    filename='./File.iq/File_2021-10-08090021.complex.1ch.float32';
end
%% load data
fID = fopen(filename,'r');
IQ=fread(fID,'float');
I=IQ(1:2:end);
Q=IQ(2:2:end);
cpx=I+Q*1i;

end
