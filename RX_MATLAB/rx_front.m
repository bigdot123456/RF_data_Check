% load('C:\liuyang\matlab_test\matlab分析频域数据\t_iq.mat');
load('t_iq.mat');
en_phase_comp = 1;
% centralFreqHz = 3500000000;%中心频点，单位Hz
% centralFreqHz = 2496000000;%%%ARFCN  499200
% centralFreqHz = 2566890000;%%%ARFCN  513378  移动
centralFreqHz = 3549540000;%%%ARFCN  636636  联通
coeff = phase_coeff(centralFreqHz,1);%Rx 1;Tx -1
print_iq(t_iq);

t_withoutCP = removeCP(t_iq); %去CP
 print_recp(t_withoutCP);
if ( en_phase_comp == 1 )
    phase_comp = t_withoutCP.*coeff; %相位补偿
else
    phase_comp = t_withoutCP;
end
 print_data(phase_comp);

re_phase_comp = real(phase_comp);
im_phase_comp = imag(phase_comp);
data_I = floor(re_phase_comp*2^15);
data_Q = floor(im_phase_comp*2^15);
complex_data = data_I/2^15 + sqrt(-1)*data_Q/2^15;

input = [];
output = [];
blkexp = [];
overflow = [];


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

  % Set FFT (1) or IFFT (0)
  direction = 1;
%   fprintf('Running the MEX function...\n')      
%   % Run the MEX function
%   [output, blkexp, overflow] = xfft_v9_1_bitacc_mex(generics, nfft, input, scaling_sch, direction);
   for i = 1:14 
     input(i,:) = complex_data(:,i);
     [output(i,:), blkexp(i),overflow(i)] = xfft_v9_1_bitacc_mex(generics, nfft, input(i,:), scaling_sch, direction);
   end
 print_fft(output);
  fid5=fopen('.\ul_proc\agc.txt','w');
  fprintf(fid5,'%d\n',blkexp);    
  fclose (fid5);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fiq = T2F_FFT(phase_comp); %FFT及PRB compression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t_noCP = removeCP(t_addCP)
  cplength = [352 288 288 288 288 288 288 288 288 288 288 288 288 288];
  startsample_perSymbol = [0	4448	8832	13216	17600	21984	26368	30752	35136	39520	43904	48288	52672	57056	61440];
  nNrofsampleperSlot = 14*4096+sum(cplength);
  
  nColumn = length(t_addCP)/nNrofsampleperSlot * 14;
  cp_pos = [];
  for Idx = 0:nColumn-1 
      symb_Idx = mod(Idx,14)+1;      
      cp_pos_perSymb = [];
      cp_pos_perSymb = startsample_perSymbol(symb_Idx)+[0:cplength(symb_Idx)-1]+1 +floor(Idx/14)*nNrofsampleperSlot;
      cp_pos = [cp_pos cp_pos_perSymb];
  end
  t_CPremoved = t_addCP;
  t_CPremoved(cp_pos) = [];
  t_noCP = reshape(t_CPremoved,4096,[]);
end

% function fiq = T2F_FFT(t_CPremoved)
% 	phy_sc_index=[0:273*12-1]-273*12/2;
% 	phy_sc_index = mod(phy_sc_index,4096)+1;
% 	[frow,fcolumn] = size(t_CPremoved);
%   t_RnFFTCAntSymb = t_CPremoved;
% 
%   f4096 = fft(t_RnFFTCAntSymb,4096);%FFT结果,4096点
%   fiq = f4096(phy_sc_index,:);      %取273 PRB后的结果 3276点
% end

function coeff = phase_coeff(centralFreqHz,trx)
    %仅针对 30KHz ,tx -1;rx 1
  j=sqrt(-1);
  Tc = 1/(480000*4096);
  cplength = [352 288 288 288 288 288 288 288 288 288 288 288 288 288];
  startsample_perSymbol = [0	4448	8832	13216	17600	21984	26368	30752	35136	39520	43904	48288	52672	57056];
  tmp = trx*(startsample_perSymbol+cplength)*16*Tc*2*pi*centralFreqHz;
  coeff = exp(j*tmp); 
end

function print_iq(t_iq)
 re_iq = real(t_iq);
  im_iq = imag(t_iq);
  data_I = floor(re_iq*2^15);
  data_Q = floor(im_iq*2^15);
  data_I_c = [];
  data_Q_c = [];
  for i = 1:61440
    if (data_I(i)>=0)
        data_I_c(i) = data_I(i);
    else
        data_I_c(i) = data_I(i) + 65536;
    end
    if (data_Q(i)>=0)
        data_Q_c(i) = data_Q(i);
    else
        data_Q_c(i) = data_Q(i) + 65536;
    end
  end
  data_I_H = dec2hex(data_I_c);
  data_Q_H = dec2hex(data_Q_c);
  str_out = [data_Q_H,data_I_H];
  str_out1 = str_out.';
  fid1=fopen('.\ul_proc\data_src_1slot.txt','w');
  fprintf(fid1,'%c%c%c%c%c%c%c%c\n',str_out1);    
  fclose (fid1);
end
function print_recp(t_noCP)
 re_iq = real(t_noCP);
 im_iq = imag(t_noCP);
 data_I = floor(re_iq*2^15);
 data_Q = floor(im_iq*2^15);
 data_I_c = [];
 data_Q_c = [];
 for i = 1:14
     for j = 1:4096
       if (data_I(j,i)>=0)
         data_I_c((i-1)*4096+j) = data_I(j,i);
       else
         data_I_c((i-1)*4096+j) = data_I(j,i) + 65536;
       end
       if (data_Q(j,i)>=0)
         data_Q_c((i-1)*4096+j) = data_Q(j,i);
       else
         data_Q_c((i-1)*4096+j) = data_Q(j,i) + 65536;
       end
     end
 end
 data_I_H = dec2hex(data_I_c);
 data_Q_H = dec2hex(data_Q_c);
 data_out = [data_Q_H,data_I_H];
 data_out1 = data_out.';
 fid2=fopen('.\ul_proc\re_cp_data_src.txt','w');
 fprintf(fid2,'%c%c%c%c%c%c%c%c\n',data_out1);    
 fclose (fid2);
end

function print_data(t_noCP)
 re_iq = real(t_noCP);
 im_iq = imag(t_noCP);
 data_I = floor(re_iq*2^15);
 data_Q = floor(im_iq*2^15);
 data_I_c = [];
 data_Q_c = [];
 for i = 1:14
     for j = 1:4096
       if (data_I(j,i)>=0)
         data_I_c((i-1)*4096+j) = data_I(j,i);
       else
         data_I_c((i-1)*4096+j) = data_I(j,i) + 65536;
       end
       if (data_Q(j,i)>=0)
         data_Q_c((i-1)*4096+j) = data_Q(j,i);
       else
         data_Q_c((i-1)*4096+j) = data_Q(j,i) + 65536;
       end
     end
 end
 data_I_H = dec2hex(data_I_c);
 data_Q_H = dec2hex(data_Q_c);
 data_out = [data_Q_H,data_I_H];
 data_out1 = data_out.';
 fid3=fopen('.\ul_proc\phase_comp_u.txt','w');
 fprintf(fid3,'%c%c%c%c%c%c%c%c\n',data_out1);    
 fclose (fid3);
end
function print_fft(output)
re_iq = real(output);
 im_iq = imag(output);
 data_o_I = floor(re_iq*2^15);
 data_o_Q = floor(im_iq*2^15);
 data_I_c = [];
 data_Q_c = [];
 for i = 1:14
     for j = 1:4096
       if (data_o_I(i,j)>=0)
         data_I_c((i-1)*4096+j) = data_o_I(i,j);
       else
         data_I_c((i-1)*4096+j) = data_o_I(i,j) + 65536;
       end
       if (data_o_Q(i,j)>=0)
         data_Q_c((i-1)*4096+j) = data_o_Q(i,j);
       else
         data_Q_c((i-1)*4096+j) = data_o_Q(i,j) + 65536;
       end
     end
 end
 data_I_H = dec2hex(data_I_c);
 data_Q_H = dec2hex(data_Q_c);
 data_out = [data_Q_H,data_I_H];
 data_out1 = data_out.';
 fid4=fopen('.\ul_proc\fft2_data.txt','w');
 fprintf(fid4,'%c%c%c%c%c%c%c%c\n',data_out1);    
 fclose (fid4);

end

