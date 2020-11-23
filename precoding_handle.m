
clear all;
clc;

% figure;
% surf(abs(hest(:,:,1)));
% shading('flat');
% xlabel('OFDM Symbols');
% ylabel('Subcarriers');
% zlabel('|H|');
% title('Channel Magnitude Response');
%% ------------------------------------------------------------------------
% parameters
nrSRSParameters = nrSRSParametersInit();
nAntennaTX = nrSRSParameters.sysConst.NSRS_ap;
FFTSize = nrSRSParameters.sysConst.FFTSize;
ki = 2^nrSRSParameters.sysConst.Mu;
sys_start_point = (FFTSize - nrSRSParameters.sysConst.MaxRB*nrSRSParameters.sysConst.NRB_SC)/2;

for loop_indx = 1:10000000
%% --------------------------------------------------------------------------------
        %---------- transmitter UL of SRS----
        % modulation and mapping
        [nrSRSIndex, nrSRSseq_pi] = nrSRSMapping(nrSRSParameters.SRS_Resource, nrSRSParameters.sysConst);
        % ofdm modulation
        Freqsignal = zeros(FFTSize, nrSRSParameters.sysConst.NSRS_ap);
        Freqsignal(nrSRSIndex+sys_start_point,:) = nrSRSseq_pi;
        % generate the frame
        timesignal0 = F2T(Freqsignal, 160*ki, 1);
        timesignalx = F2T(Freqsignal, 144*ki, 1);
        [a,b] = size(timesignalx);
        timesignal1 = zeros(a,b);
        timesignal1(:,1) = timesignalx(:,1);
        timesignal2 = zeros(a,b);
        timesignal2(:,2) = timesignalx(:,2);
        timesignal3 = zeros(a,b);
        timesignal3(:,3) = timesignalx(:,3);
        timesignal4 = zeros(a,b);
        timesignal4(:,4) = timesignalx(:,4);
        
        timewave = [timesignal0
            timesignal1
            timesignal2
            timesignal3
            timesignal4
            timesignalx
            timesignalx
                    timesignal0
            timesignal1
            timesignal2
            timesignal3
            timesignal4
            timesignalx
            timesignalx
            ];
        %% ----------------------------------------------------------------------------------------------
        % channel 
        % number of Tx / Rx Antenna
        velocity = 30.0; 
        fc = 4e9;
        c = physconst('lightspeed');
        fd = (velocity*1000/3600)/c*fc;
        SR = 30.72e6*ki;
        channel = nrTDLChannel;
        channel.SampleRate = SR;
        channel.Seed = 24+loop_indx;
        channel.DelayProfile = 'TDL-C';
        channel.DelaySpread =  300e-9;
        channel.MaximumDopplerShift = fd;
        channel.MIMOCorrelation = 'Low';
        channel.Polarization = 'Cross-Polar';
        channel.NumTransmitAntennas = nrSRSParameters.sysConst.NSRS_ap;
        channel.NumReceiveAntennas = nrSRSParameters.sysConst.NSRS_ap;
        subcSpacing = 30e3;
        
%         % transfer through channel simulation
%         % perfect channel estimation
% %         T = SR*1e-3;
% %         Nt = channel.NumTransmitAntennas;
% %         in = complex(randn(T,Nt),randn(T,Nt));
        [out,pathGains] = channel(timewave);
%         out = timewave;
% out = timewave;
%         pathFilters = getPathFilters(channel);
%         NRB = 24;
%         SCS = 15;
%         nSlot = 0;
% 
%         hest = nrPerfectChannelEstimate(pathGains,pathFilters,NRB,SCS,nSlot);
%         size(hest)
%        
        % test
%         for indx = 1:288
%             c = zeros(4,4);
%             c(:,:)=hest(indx,1,:,:);
%             [u s v] = svd(c)
%         end
        
        %% -----------------------------------------------------------------
        %-------- receiver (eNDB) ----
        % ofdm demodulation timesignal
        [rx_data_sym1] = T2F(out((FFTSize+160*ki)+(1:(4096+144*ki)),:),FFTSize,144*ki,1,0);
        % demapping
        nrSRSseq_pi_rx = rx_data_sym1(nrSRSIndex+sys_start_point,:);
        % channel estimation LS
        for rx_port=1:4
            rx1_ls(:,rx_port) = nrSRSseq_pi_rx(:,rx_port).*conj(nrSRSseq_pi(:,1));
        end
        
        [rx_data_sym2] = T2F(out((FFTSize+160*ki)+(4096+144*ki)+(1:(4096+144*ki)),:),FFTSize,144*ki,1,0);
        % demapping
        nrSRSseq_pi_rx = rx_data_sym2(nrSRSIndex+sys_start_point,:);
        % channel estimation LS
        for rx_port=1:4
            rx2_ls(:,rx_port) = nrSRSseq_pi_rx(:,rx_port).*conj(nrSRSseq_pi(:,2));
        end  
        
        [rx_data_sym3] = T2F(out((FFTSize+160*ki)+2*(4096+144*ki)+(1:(4096+144*ki)),:),FFTSize,144*ki,1,0);
        % demapping
        nrSRSseq_pi_rx = rx_data_sym3(nrSRSIndex+sys_start_point,:);
        % channel estimation LS
        for rx_port=1:4
            rx3_ls(:,rx_port) = nrSRSseq_pi_rx(:,rx_port).*conj(nrSRSseq_pi(:,3));
        end 
        
        [rx_data_sym4] = T2F(out((FFTSize+160*ki)+3*(4096+144*ki)+(1:(4096+144*ki)),:),FFTSize,144*ki,1,0);
        % demapping
        nrSRSseq_pi_rx = rx_data_sym4(nrSRSIndex+sys_start_point,:);
        % channel estimation LS
        for rx_port=1:4
            rx4_ls(:,rx_port) = nrSRSseq_pi_rx(:,rx_port).*conj(nrSRSseq_pi(:,4));
        end 
        
        % filter
        hls1_filte = zeros(length(rx1_ls(:,1))*2,4);
        hls1_filte(nrSRSIndex,:) = rx1_ls;
        hls1_filte(1+nrSRSIndex,:) = rx1_ls;
        hls2_filte = zeros(length(rx2_ls(:,1))*2,4);
        hls2_filte(nrSRSIndex,:) = rx2_ls;
        hls2_filte(nrSRSIndex+1,:) = rx2_ls;
        hls3_filte = zeros(length(rx3_ls(:,1))*2,4);
        hls3_filte(nrSRSIndex,:) = rx3_ls;
        hls3_filte(nrSRSIndex+1,:) = rx3_ls;
        hls4_filte = zeros(length(rx4_ls(:,1))*2,4);
        hls4_filte(nrSRSIndex,:) = rx4_ls;
        hls4_filte(nrSRSIndex+1,:) = rx4_ls;
        
        % LSPP
        rx1_ls_t = ifft(rx1_ls);
        rx2_ls_t = ifft(rx2_ls);
        rx3_ls_t = ifft(rx3_ls);
        rx4_ls_t = ifft(rx4_ls);

        [max_ls_t1, index1] = max(abs(rx1_ls_t(:,1)));
        [max_ls_t2, index2] = max(abs(rx2_ls_t(:,2)));
        [max_ls_t3, index3] = max(abs(rx3_ls_t(:,3)));
        [max_ls_t4, index4] = max(abs(rx4_ls_t(:,4)));
        
        w_hls = 80; offset = 1;
        hls1_lspp = zeros(length(rx1_ls_t(:,1))*2,4);
        for hls_inx=1:4
            hls1_lspp(1:w_hls,hls_inx) = rx1_ls_t(index1+(1:w_hls)-offset,hls_inx);
        end
        hls2_lspp = zeros(length(rx2_ls_t(:,1))*2,4);
        for hls_inx=1:4
            hls2_lspp(1:w_hls,hls_inx) = rx2_ls_t(index2+(1:w_hls)-offset,hls_inx);
        end
        hls3_lspp = zeros(length(rx3_ls_t(:,1))*2,4);
        for hls_inx=1:4
            hls3_lspp(1:w_hls,hls_inx) = rx3_ls_t(index1+(1:w_hls)-offset,hls_inx);
        end
        hls4_lspp = zeros(length(rx4_ls_t(:,1))*2,4);
        for hls_inx=1:4
            hls4_lspp(1:w_hls,hls_inx) = rx4_ls_t(index2+(1:w_hls)-offset,hls_inx);
        end
        
        hls1_lspp_fre = fft(hls1_lspp);
        hls2_lspp_fre = fft(hls2_lspp);
        hls3_lspp_fre = fft(hls3_lspp);
        hls4_lspp_fre = fft(hls4_lspp);
        
        %% --------------------------------------------------------------------------------
        %---------- transmitter (eNDB) ----
        % modulation and mapping
        %   modulation = '256QAM';
        %   nlayers = 4;
        %   ncellid = 42;
        %   rnti = 6143;
        %   data = randi([0 1],8000,1);
        %   sym = nrPDSCH(data,modulation,nlayers,ncellid,rnti);
        %   
          % Generate PDSCH symbols for a single codeword of 8000 bits, using 
          % 256QAM modulation and 4 layers.

          modulation = 'QPSK';%'256QAM';
          nlayers = 4;
          ncellid = 42;
          rnti = 6143;
          data = randi([0 1],26000,1);%8000 for 256QAM
          txsym = nrPDSCH(data,modulation,nlayers,ncellid,rnti);
          data_index = 1:length(txsym(:,1));
          figure;%plot the constellations of send
          for annten=1:4
              subplot(2,2,annten);
              scatter(real(txsym(:,annten)),imag(txsym(:,annten)),'.');
              title(['constell of P',num2str(annten),' symbol 0'])
          end
          Freqsignal_0 = zeros(FFTSize,nrSRSParameters.sysConst.NSRS_ap);
          Freqsignal_0(sys_start_point+data_index,:) = txsym;
          timesignal0 = F2T(Freqsignal_0, 160*ki, 1);
          [dlDMRSSignal, index_dlDMRS] = dlDMRSGenerationi(nrSRSParameters);
          Freqsignal_1 = zeros(FFTSize,nrSRSParameters.sysConst.NSRS_ap);
          figure;
          for annt=1:nrSRSParameters.sysConst.NSRS_ap
              Freqsignal_1(sys_start_point+index_dlDMRS(:,annt),annt) = dlDMRSSignal(:,annt);  
              index_dlDMRS(:,annt)
              subplot(2,2,annt);
              scatter(real(dlDMRSSignal(:,annt)),imag(dlDMRSSignal(:,annt)),'.');
              title(['constell of P',num2str(annt),' DMRS'])
          end
          timesignalx = F2T(Freqsignal_1, 144*ki, 1);
          [a,b]=size(timesignalx);
          timesignal1=zeros(a,b);
          timesignal1(:,1)=timesignalx(:,1);
          timesignal2=zeros(a,b);
          timesignal2(:,2)=timesignalx(:,2);
          timesignal3=zeros(a,b);
          timesignal3(:,3)=timesignalx(:,3);
          timesignal4=zeros(a,b);
          timesignal4(:,4)=timesignalx(:,4);
          %generate frame
          timesignal = [
              timesignal0 
              timesignal1
              timesignal2
              timesignal3
              timesignal4
              timesignalx
              timesignalx];

          in = [timesignal
              timesignal
              ];
        %% ----------------------------------------------------------------------------------------------
        % DL channel the channel is the same as UL
        % channel 
        %% ----------------------------------------------------------------------------------------------
        % channel 
        % number of Tx / Rx Antenna
        velocity = 30.0; 
        fc = 4e9;
        c = physconst('lightspeed');
        fd = (velocity*1000/3600)/c*fc;
        SR = 30.72e6*ki;
        channel = nrTDLChannel;
        channel.SampleRate = SR;
        channel.Seed = 24+loop_indx;
        channel.DelayProfile = 'TDL-C';
        channel.DelaySpread =  300e-9;
        channel.MaximumDopplerShift = fd;
        channel.MIMOCorrelation = 'Low';
        channel.Polarization = 'Cross-Polar';
        channel.NumTransmitAntennas = nrSRSParameters.sysConst.NSRS_ap;
        channel.NumReceiveAntennas = nrSRSParameters.sysConst.NSRS_ap;
        subcSpacing = 30e3;
        
%         % transfer through channel simulation
%         % perfect channel estimation
% %         T = SR*1e-3;
% %         Nt = channel.NumTransmitAntennas;
% %         in = complex(randn(T,Nt),randn(T,Nt));
        [out,pathGains] = channel(in);
%         out = in;
        %% ---------------------------------------------
        % data symbol 
        symbol0 = out(1:FFTSize+160*ki,:);
        [Data_rx] = T2F(symbol0,FFTSize,160*ki,1,0); 
        rxsym = Data_rx(sys_start_point+data_index,:);
        % if used ideal channel estimation

        %equalization mmse
        H_w = zeros(4,4); 
        for k_sc = 1:length(rxsym)
            H_w = [hls1_lspp_fre(k_sc,:).', hls2_lspp_fre(k_sc,:).', hls3_lspp_fre(k_sc,:).', hls4_lspp_fre(k_sc,:).']
            w = (H_w'*H_w+ (1 / 30 * eye(4)))/H_w';
            Data_equelized(k_sc,:) = w*rxsym(k_sc,:).';
        end
        %Data_rx
        for k_sc = 1:length(rxsym)
            H_w(:,:) = [hls1_filte(k_sc,:).', hls2_filte(k_sc,:).', hls3_filte(k_sc,:).', hls4_filte(k_sc,:).'];
            w = (H_w'*H_w+ (1 / 30 * eye(4)))/H_w';
            rxsym_equelized(k_sc,:) = w*rxsym(k_sc,:).';
        end
        rxsym = Data_equelized;
        scatterplot(rxsym_equelized(:,1));
          %bit recover
        rxbits = nrPDSCHDecode(rxsym,modulation,ncellid,rnti);
        rxbit_in = zeros(length(data),1);
        rxbit_in = rxbits{1};
        for bit_indx = 1:length(data)
            if rxbit_in(bit_indx)>0
                rxbits_inf(bit_indx) = 0;
            else
                rxbits_inf(bit_indx) = 1;
            end
        end
        %--result
        isequal(data,rxbits_inf')

        biterr(data',rxbits_inf)
loop_indx
end
loop = 1;


