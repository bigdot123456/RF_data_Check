
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
        %---------- transmitter----
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
        
        %H matrix for 4 layer
        for subcarri = 1:length(rx4_ls_t(:,1))*2
            w = [hls1_lspp_fre(subcarri,:).', hls2_lspp_fre(subcarri,:).', hls3_lspp_fre(subcarri,:).', hls4_lspp_fre(subcarri,:).']
        end
        
%         %test transfer again
%                 % channel 
%         % number of Tx / Rx Antenna
%         velocity = 30.0; 
%         fc = 4e9;
%         c = physconst('lightspeed');
%         fd = (velocity*1000/3600)/c*fc;
%         SR = 30.72e6;
%         channel = nrTDLChannel;
%         channel.SampleRate = SR;
%         channel.Seed = 24+loop_indx;
%         channel.DelayProfile = 'TDL-C';
%         channel.DelaySpread =  300e-9;
%         channel.MaximumDopplerShift = fd;
%         channel.MIMOCorrelation = 'Low';
%         channel.Polarization = 'Cross-Polar';
%         channel.NumTransmitAntennas = nrSRSParameters.sysConst.NSRS_ap;
%         channel.NumReceiveAntennas = nrSRSParameters.sysConst.NSRS_ap;
%         subcSpacing = 15e3;
%         % transfer
%         rxWaveform = channel(timesignal);

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

          modulation = '256QAM';%'256QAM';
          nlayers = 4;
          ncellid = 42;
          rnti = 6143;
          data = randi([0 1],100000,1);%8000 for 256QAM
          txsym = nrPDSCH(data,modulation,nlayers,ncellid,rnti);
          figure;%plot the constellations of send
          for annten=1:4
              subplot(2,2,annten);
              scatter(real(txsym(:,annten)),imag(txsym(:,annten)),'.');
              title(['constell of P',num2str(annten),' symbol 0'])
          end
          Freqsignal_0 = zeros(FFTSize,nrSRSParameters.sysConst.NSRS_ap);
          Freqsignal_0(7:281,:) = txsym;
          timesignal0 = F2T(Freqsignal_0, 160/4, 1);
          [dlDMRSSignal, index_dlDMRS] = dlDMRSGenerationi(nrSRSParameters);
          Freqsignal_1 = zeros(FFTSize,nrSRSParameters.sysConst.NSRS_ap);
          figure;
          for annt=1:nrSRSParameters.sysConst.NSRS_ap
              Freqsignal_1(index_dlDMRS(:,annt),annt) = dlDMRSSignal(:,annt);  
              index_dlDMRS(:,annt)
              subplot(2,2,annt);
              scatter(real(dlDMRSSignal(:,annt)),imag(dlDMRSSignal(:,annt)),'.');
              title(['constell of P',num2str(annt),' DMRS'])
          end
          timesignal1 = F2T(Freqsignal_1, 144/4, 1);
          %generate frame
          timesignal = [
              timesignal0 
              timesignal1
              timesignal1
              timesignal1
              timesignal1
              timesignal1
              timesignal1];

          in = [timesignal
              timesignal
              ];
        %% ----------------------------------------------------------------------------------------------
        % DL channel the channel is the same as UL
        % channel 
        velocity = 30.0; 
        fc = 4e9;
        c = physconst('lightspeed');
        fd = (velocity*1000/3600)/c*fc;
        SR = 30.72e6/4;
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
        subcSpacing = 15e3;
          SNR = 30; % SNR in dB
%           rxWaveform = timesignal;
%           rxWaveform0 = awgn(timesignal,SNR);
        [rxWaveform,pathGains] = channel(in);
        pathFilters = getPathFilters(channel);
        NRB = 24;
        SCS = 15;
        nSlot = 0;

        hest = nrPerfectChannelEstimate(pathGains,pathFilters,NRB,SCS,nSlot);
        size(hest)
        %% ---------------------------------------------
        % data symbol 
        symbol0 = rxWaveform(1:552,:);
        [Data_rx] = T2F(symbol0,FFTSize,160/4,1,0); 
        rxsym = Data_rx(7:281,:);
        % if used ideal channel estimation
        hi_used = zeros(275,4,4);
        hi_used(:,:,:) = hest(7:281,1,:,:);
        % DMRS symbol
        nSCperBlock = 288;
        ndmrsRE = 144;
        symbol1 = rxWaveform(553:552+512+36,:);    
        [DMRX_rx] = T2F(symbol1,FFTSize,144/4,1,0); 
        dlDMRX_rx_seq = zeros(ndmrsRE, nrSRSParameters.sysConst.NSRS_ap);
       
        %channel estimation ls first get the atenn pi DMRS 
        % ls
        for annt_rx=1:nrSRSParameters.sysConst.NSRS_ap
            for annt_tx=1:nrSRSParameters.sysConst.NSRS_ap
                ls(annt_rx,annt_tx,:) = DMRX_rx(index_dlDMRS(:,annt_tx),annt_rx).*conj(dlDMRSSignal(:,annt_tx));  
            end
            %plot ls result
            plot_tmp(:,:)=ls(annt_rx,:,:);
            figure;
            subplot(4,1,1);
            plot(abs(ifft(plot_tmp(1,:))));
            title(['ce in time H',num2str(annt_rx),num2str(1)]);
            subplot(4,1,2);
            plot(abs(ifft(plot_tmp(2,:))));
            title(['ce in time H',num2str(annt_rx),num2str(2)]);
            subplot(4,1,3);
            plot(abs(ifft(plot_tmp(3,:))));
            title(['ce in time H',num2str(annt_rx),num2str(3)]);
            subplot(4,1,4);
            plot(abs(ifft(plot_tmp(4,:))));
            title(['ce in time H',num2str(annt_rx),num2str(4)]);
        end
        w_len = 12;
        b = (1/w_len)*ones(1,w_len);
        %filter
        filter_tmp = zeros(1,w_len+144);
        ce_h_filted = zeros(144,4,4);
        figure;plotidx = 1;
        for filte_pi_r = 1:4
            for filte_pi_t = 1:4
                filter_tmp(1:w_len/2)=ls(filte_pi_r,filte_pi_t,(length(ls(filte_pi_r,filte_pi_t,:))-w_len/2+1):end);
                filter_tmp(w_len/2+(1:144))=ls(filte_pi_r,filte_pi_t,:);
                filter_tmp(w_len/2+144+(1:w_len/2))=ls(filte_pi_r,filte_pi_t,1:w_len/2);
                filter_tmp = filter(b,1,filter_tmp);
                ce_h_filted(:,filte_pi_r,filte_pi_t) = filter_tmp(w_len/2+(1:144));
                subplot(4,4,plotidx);
                plot(abs(ifft(filter_tmp(w_len/2+(1:144)))));
                title(['filted ce H',num2str(filte_pi_r),num2str(filte_pi_t)]);
                plotidx = plotidx + 1;
            end
        end
        %frequence interploter  
        interp_h_all = zeros(288,4,4);
        for annt_rx = 1:2
            interp_h_all(index_dlDMRS(:,annt_rx),annt_rx,:) = ce_h_filted(:,annt_rx,:);
            interp_h_all(index_dlDMRS(:,annt_rx+2),annt_rx,:) = ce_h_filted(:,annt_rx,:);
        end
        for annt_rx = 3:4
            interp_h_all(index_dlDMRS(:,annt_rx),annt_rx,:) = ce_h_filted(:,annt_rx,:);
            interp_h_all(index_dlDMRS(:,annt_rx-2),annt_rx,:) = ce_h_filted(:,annt_rx,:);
        end
        % freq interpolation with correlation weight matrix
        w_len = 12;
        b = (1/w_len)*ones(1,w_len);
        %filter
        filter_tmp = zeros(1,w_len+288);
        ce_h_all = zeros(288,4,4);
        figure;plotidx = 1;
        for filte_pi_r = 1:4
            for filte_pi_t = 1:4
                filter_tmp(1:w_len/2)=interp_h_all((length(interp_h_all(:,filte_pi_r,filte_pi_t))-w_len/2+1):end, filte_pi_r,filte_pi_t);
                filter_tmp(w_len/2+(1:288))=interp_h_all(:,filte_pi_r,filte_pi_t);
                filter_tmp(w_len/2+288+(1:w_len/2))=interp_h_all(1:w_len/2,filte_pi_r,filte_pi_t);
                filter_tmp = filter(b,1,filter_tmp);
                ce_h_all(:,filte_pi_r,filte_pi_t) = filter_tmp(w_len/2+(1:288));
                subplot(4,4,plotidx);
                plot(abs(ifft(filter_tmp(w_len/2+(1:288)))));
                title(['all ce H',num2str(filte_pi_r),num2str(filte_pi_t)]);
                plotidx = plotidx + 1;
            end
        end

        %equalization irc
        H_w = zeros(4,4); 
        for k_sc = 1:288
            H_w(:,:) = ce_h_all(k_sc,:,:);
            H_w = H_w.';
            w = (H_w'*H_w+ (1 / SNR * eye(4)))/H_w';
            Data_equelized(k_sc,:) = w*Data_rx(k_sc,:).';
        end
        %Data_rx
        for k_sc = 1:275
            H_w(:,:) = ce_h_all(k_sc,:,:);
            w = (H_w'*H_w+ (1 / SNR * eye(4)))/H_w';
            rxsym_equelized(k_sc,:) = w*rxsym(k_sc,:).';
        end
%         rxsym = Data_equelized(7:281,:);
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


