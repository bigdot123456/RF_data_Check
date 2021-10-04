function [sto_pos, symb_sto_pos_abs0,symbFFTIn,symbFullData,sto_diffsum]=SymbolSTOlcp(y,Ng,StartPoint,SearchLen,Nfft)
%% set basic parameter
% STO estimation by maximizing the correlation between CP and rear part of OFDM symbol
% estimates STO by maximizing the correlation between CP (cyclic prefix)  
%     and rear part of OFDM symbol
% [sto_pos, symb_sto_pos_abs0,symbFFTIn,symbFullData,sto_diffsum]=SymbolSTOlcp(y,Ng,StartPoint,SearchLen,Nfft)
% Input:  y         = Received OFDM signal including CP
%         Ng        = Number of samples in Guard Interval (CP)
%         StartPoint = search begining index for y. from y(StartPoint) to
%         y(StartPoint+SearchLen*3)-1
%        
%         Nfft = fft length such as 4096
% Output: sto_pos   = STO estimate
%         symb_sto_pos_abs0 = best start postion for symbol
%         symbFFTIn       = output best FFT range
%         sto_diffsum = full search result with CP differential method. 

% according to "MIMO-OFDM Wireless Communications with MATLAB㈢   Yong Soo
% Cho, Jaekwon Kim, Won Young Yang and Chung G. Kang"
% 2010 John Wiley & Sons (Asia) Pte Ltd
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

global Debug_sto

% at least 2 times of SearchLen for view all case
searchRange=3*SearchLen;

N_ofdm=Nfft+Ng;

y_len=length(y);
y_len_expect=N_ofdm+searchRange+StartPoint-1;
if y_len<y_len_expect
    len_add=y_len_expect-y_len;
    y=[y zeros(1,len_add)];
   fprintf("append more zeros for input y with lenth %d\n",len_add);
 end

%% start search 
% it's simple use [1:CP] with [FFT:FFT+CP] simility
% now cacaulate the distance for two cp abs

%Now start large range searching, from last symbol CP to this symbol CP
minimum=10000;
sto_diffsum=zeros(1,searchRange);
% now we should search total 2*Ng sample point
%    temp = abs(y(com_delay + k  : com_delay + k + Ng-1)) - abs(y(com_delay+Nfft+k : com_delay + Ng-1 +Nfft+k));
STO_est=[];
for k =1:searchRange
    pos1=StartPoint-1+(k:k+Ng-1);
    pos2=pos1+Nfft;
    temp = abs(y(pos1)) - abs(y(pos2));
    SquareSum=sum(temp.^2);
    sto_diffsum(k) = SquareSum;
end
[sto_diff_min,STO_est]=min(sto_diffsum);
%% debug 
if Debug_sto==1
    str=sprintf('STO start %d with pos:%d',StartPoint,STO_est);
    figure('NumberTitle', 'on', 'Name', str);
    titlestr=sprintf("Total Search Len:%d min:%d",SearchLen,sto_diff_min);
    plot(sto_diffsum,'.')
    title(titlestr);
    grid on;
end

symb_sto_pos_abs0=StartPoint-1+(STO_est+Ng/2);
posFFTIn=symb_sto_pos_abs0+(1:Nfft)-1;
symbFFTIn=y(posFFTIn);

symb_best_pos_abs=StartPoint-1+STO_est;
symb_sto_range=symb_best_pos_abs+(1:(Nfft+Ng))-1;
symbFullData=y(symb_sto_range);

sto_pos=STO_est;
end