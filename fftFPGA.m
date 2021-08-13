%% FPGA fixed point fft
function fftOut=fftFPGA(fftIn)
%%%%%%%fftcmodel%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generics for this smoke test
generics.C_NFFT_MAX = 12;
generics.C_ARCH = 3;
generics.C_HAS_NFFT = 0;%0 no length config  1 length config
generics.C_USE_FLT_PT = 0; %0  fixed  or  1 Single-Precision Floating Point

generics.C_INPUT_WIDTH = 16; % Must be 32 if C_USE_FLT_PT = 1
generics.C_TWIDDLE_WIDTH = 16; % Must be 24 or 25 if C_USE_FLT_PT = 1
generics.C_HAS_SCALING = 1; % Set to 0 if C_USE_FLT_PT = 1
generics.C_HAS_BFP = 1; % Set to 0 if C_USE_FLT_PT = 1  0 = scaled, 1 = block floating point
generics.C_HAS_ROUNDING = 1; % Set to 0 if C_USE_FLT_PT = 1    0 = truncation,   1 = convergent rounding

     
  % Set point size for this transform
  nfft = generics.C_NFFT_MAX;
  
  % Set up scaling schedule: scaling_sch[1] is the scaling for the first stage
  % Scaling schedule to 1/N: 
  %    2 in each stage for Radix-4/Pipelined, Streaming I/O
  %    1 in each stage for Radix-2/Radix-2 Lite
  if generics.C_ARCH == 1 || generics.C_ARCH == 3
    scaling_sch = ones(1,floor(nfft/2)) * 2;
    if mod(nfft,2) == 1
      scaling_sch = [scaling_sch 1];
    end
  else
    scaling_sch = ones(1,nfft);
  end
  direction = 1;
  %% prepare fft input data with fixed-point
  fftfxpt=fftIn/2^15;
  
  [output, blkexp,overflow] = xfft_v9_1_bitacc_mex(generics, nfft, fftfxpt, scaling_sch, direction);
  if overflow
      sprintf("overflow is occured! block exp is %d",blkexp);
  end
  fftOut=output;

end