%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [timesignal] = F2T(mappedsymbol, CPSize, oversamplingTimes)
% -------------------------------------------------------------------------
% DESCRIPTION:
%    This function transform the data in frequence domain into time domain.
%
% INPUT:
%    mappedsymbol:          mappedsymbol is the symbols mapping into RE table and and is extended from usedsubcs to FFTSize subcs, thus [FFTSize x nSymbolOFDM x nAntennaTX]
%    CPSize:                sample size of CP
%    oversamplingTimes:     multiplier of oversampling
% OUTPUT:
%    timesignal:           time domain signal [FFTSize +CPsize, number of transmit antenna] per symbol
% -------------------------------------------------------------------------

[FFTSize, nAntennaTX] = size(mappedsymbol);

% DC tone shift and oversampling
timesignal = zeros(FFTSize*oversamplingTimes, nAntennaTX);

timesignal([1 : FFTSize / 2, FFTSize * (oversamplingTimes - 1 / 2) + 1 : FFTSize * oversamplingTimes], :) = ifftshift(mappedsymbol, 1);
% timesignal = mappedsymbol;

% frequency to time in each antenna port
for iant = 1:nAntennaTX
    timesignal(:, iant) = sqrt(FFTSize*oversamplingTimes) * ifft(timesignal(:, iant), FFTSize*oversamplingTimes);
end

% insert cyclic prefix
timesignal = [timesignal(end-CPSize*oversamplingTimes+1:end, :); timesignal(:, :)];
end
