function [sto_pos, pos0,FFTDataIn,SymbolData,sto_diffsum]=SymbolSTOlcp(y,Ng,StartPoint,SearchLen,Nfft)
%% set basic parameter
% STO estimation by maximizing the correlation between CP and rear part of OFDM symbol
% estimates STO by maximizing the correlation between CP (cyclic prefix)  
%     and rear part of OFDM symbol
% Input:  y         = Received OFDM signal including CP
%         Ng        = Number of samples in Guard Interval (CP)
%         com_delay = Common delay
%         lastSymbolCP = last symbol data with length cp
% Output: STO_est   = STO estimate
%         Mag       = Correlation function trajectory varying with time

%MIMO-OFDM Wireless Communications with MATLAB㈢   Yong Soo Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang
%?2010 John Wiley & Sons (Asia) Pte Ltd
if nargin==1
    Nfft=4096;
    Ng=288;
    StartPoint=Nfft/2;
    SearchLen=Nfft;%288;
elseif nargin==2
    Nfft=4096;
    StartPoint=Nfft/2;
    SearchLen=Nfft;%288;
elseif nargin==3
    Nfft=4096;
    SearchLen=Nfft;%288;
elseif nargin==4
    Nfft=4096;
end


N_ofdm=Nfft+Ng;

y_len=length(y);
y_len_expect=N_ofdm+2*SearchLen+StartPoint;
if y_len<y_len_expect
    len_add=y_len_expect-y_len;
    y=[y zeros(1,len_add)];
   fprintf("append more zeros for input y with lenth %d",len_add);
 end

%% start search 
% it's simple use [1:CP] with [FFT:FFT+CP] simility
% now cacaulate the distance for two cp abs

%Now start large range searching, from last symbol CP to this symbol CP
minimum=10000;
sto_diffsum=zeros(1,SearchLen);
% now we should search total 2*Ng sample point
%    temp = abs(y(com_delay + k  : com_delay + k + Ng-1)) - abs(y(com_delay+Nfft+k : com_delay + Ng-1 +Nfft+k));
for k =1:SearchLen
    pos1=StartPoint-1+(k:k+Ng-1);
    pos2=pos1+Nfft;
    temp = abs(y(pos1)) - abs(y(pos2));
    SquareSum=temp*temp';
    sto_diffsum(k) = SquareSum;
    if sto_diffsum(k)<minimum
        minimum =  sto_diffsum(k);
        STO_est = k;
    end
end
pos0=StartPoint-1+(STO_est+Ng/2);
posFFTIn=pos0+(1:Nfft)-1;
FFTDataIn=y(posFFTIn);

pos3=StartPoint-1+STO_est;
posSymbol=pos3+(1:(Nfft+Ng))-1;
SymbolData=y(posSymbol);

sto_pos=N_ofdm - StartPoint - STO_est + 2;
end