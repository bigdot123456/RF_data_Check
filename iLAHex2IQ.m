function [I,Q]=iLAHex2IQ(cellin,bitWidth)
if nargin==1
   bitWidth=16;
end
%% conver 32bit data to IQ data
hexin=cell2mat(cellin);
byteNum=length(hexin)/2;
hexI=hexin(1:byteNum);
hexQ=hexin(byteNum+1:end);
I0=hex2dec(hexI);
Q0=hex2dec(hexQ);
if(I0>=2^(bitWidth-1))
    I=I0-2^(bitWidth);
else
    I=I0;
end
if(Q0>=2^(bitWidth-1))
    Q=Q0-2^(bitWidth);
else
    Q=Q0;
end
end