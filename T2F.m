%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rx_data] = T2F(rx_timedata,FFTSize,CPSize,OversamplingTimes,N_FFToffset)

NumReceiveAntennas = size(rx_timedata,2);

rx_timedata = rx_timedata(CPSize * OversamplingTimes - N_FFToffset + 1 : end,:); %remove CP

for iant = 1 : NumReceiveAntennas
    rx_freqdata(:,iant) = (1 / sqrt(FFTSize * OversamplingTimes)) * fft(rx_timedata(:,iant),FFTSize * OversamplingTimes);
end

rx_data = rx_freqdata([1 : FFTSize / 2, FFTSize * (OversamplingTimes - 1 / 2) + 1 : FFTSize * OversamplingTimes],:);

rx_data = fftshift(rx_data,1); % FFTSize-by-NumReceiveAntennas

end
