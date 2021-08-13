function coeff = phase_coeff(centralFreqHz,trx)
if nargin==0
    centralFreqHz=2566890000;
    trx=1;
elseif nargin==1
    trx=1;
end
%% get phase compensation coefficient
% 仅针对 30KHz ,tx -1;rx 1
% centralFreqHz = 3500000000;%中心频点，单位Hz
% centralFreqHz = 2496000000;%%%ARFCN  499200
% centralFreqHz = 2566890000;%%%ARFCN  513378  移动
% centralFreqHz = 3549540000;%%%ARFCN  636636  联通
j=sqrt(-1);
Tc = 1/(480000*4096);
cplength = [352 288 288 288 288 288 288 288 288 288 288 288 288 288];
startsample_perSymbol = [0	4448	8832	13216	17600	21984	26368	30752	35136	39520	43904	48288	52672	57056];
tmp = trx*(startsample_perSymbol+cplength)*16*Tc*2*pi*centralFreqHz;
coeff0 = exp(j*tmp);
%( OrigValue, FixPtDataType, FixPtScaling, RndMeth, DoSatur )
%num2fixpt(19.875, sfix(8), 2^-2, 'Floor', 'on')
coeff=num2fixpt(coeff0,sfix(16),2^-15, 'Floor', 'on');
end