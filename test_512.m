
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

for loop_indx = 1:10000000
%% --------------------------------------------------------------------------------
        %---------- transmitter----
        % modulation and mapping
        [nrSRSIndex, nrSRSseq_pi] = nrSRSMapping(nrSRSParameters.SRS_Resource, nrSRSParameters.sysConst);
        [FFTSize, nAntennaTX] = size(nrSRSseq_pi);
        FFTSize = 512;
        % ofdm modulation
        Freqsignal = zeros(FFTSize, nrSRSParameters.sysConst.NSRS_ap);
        Freqsignal(nrSRSIndex,:) = nrSRSseq_pi;
        % generate the frame
        timesignal = F2T(Freqsignal, 160/4, 1);
        for symbinx = 1:6
            timesignal = [timesignal
                            F2T(Freqsignal, 144/4, 1)];
        end
        
        timewave = [timesignal
            timesignal];
        %% ----------------------------------------------------------------------------------------------
        % channel 
        % number of Tx / Rx Antenna
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
        
%         % transfer through channel simulation
%         % perfect channel estimation
% %         T = SR*1e-3;
% %         Nt = channel.NumTransmitAntennas;
% %         in = complex(randn(T,Nt),randn(T,Nt));
        [out,pathGains] = channel(timewave);
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
        [rx_data] = T2F(out(1:(FFTSize+160/4),:),FFTSize,160/4,1,0);
        % demapping
        nrSRSseq_pi_rx = rx_data(nrSRSIndex,:);
        % channel estimation LS
        channells_11 = nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,1));
        channells_12 = nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,2));
        channells_13 = nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,3));
        channells_14 = nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,4));
        channells_21 = nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,1));
        channells_22 = nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,2));
        channells_23 = nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,3));
        channells_24 = nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,4));
        channells_31 = nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,1));
        channells_32 = nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,2));
        channells_33 = nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,3));
        channells_34 = nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,4));
        channells_41 = nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,1));
        channells_42 = nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,2));
        channells_43 = nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,3));
        channells_44 = nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,4));
        
        % find the best filter it seems good in the w_len = 10 or 12
        for w_len=2:length(channells_11)
            b = (1/w_len)*ones(1,w_len);
            ce_filted11 = filter(b,1,channells_11);
            ce_filted12 = filter(b,1,channells_12);
            ce_filted13 = filter(b,1,channells_13);
            ce_filted14 = filter(b,1,channells_14);
            ce_filted21 = filter(b,1,channells_21);
            ce_filted22 = filter(b,1,channells_22);
            ce_filted23 = filter(b,1,channells_23);
            ce_filted24 = filter(b,1,channells_24);
            ce_filted31 = filter(b,1,channells_31);
            ce_filted32 = filter(b,1,channells_32);
            ce_filted33 = filter(b,1,channells_33);
            ce_filted34 = filter(b,1,channells_34);
            ce_filted41 = filter(b,1,channells_41);
            ce_filted42 = filter(b,1,channells_42);
            ce_filted43 = filter(b,1,channells_43);
            ce_filted44 = filter(b,1,channells_44);
            % get the pulse respone in time figure
            figure;
            subplot(2,2,1);
            plot(abs(ifft(ce_filted11)));
            title(['ce filted11 with window ',num2str(w_len)]);
            subplot(2,2,2);
            plot(abs(ifft(ce_filted21)));
            title(['ce filted21 with window ',num2str(w_len)]);
            subplot(2,2,3);
            plot(abs(ifft(ce_filted31)));
            title(['ce filted31 with window ',num2str(w_len)]);
            subplot(2,2,4);
            plot(abs(ifft(ce_filted41)));
            title(['ce filted41 with window ',num2str(w_len)]);
            figure;
            subplot(2,2,1);
            plot(abs(ifft(ce_filted12)));
            title(['ce filted12 with window ',num2str(w_len)]);
            subplot(2,2,2);
            plot(abs(ifft(ce_filted22)));
            title(['ce filted22 with window ',num2str(w_len)]);
            subplot(2,2,3);
            plot(abs(ifft(ce_filted32)));
            title(['ce filted32 with window ',num2str(w_len)]);
            subplot(2,2,4);
            plot(abs(ifft(ce_filted42)));
            title(['ce filted42 with window ',num2str(w_len)]);
            figure;
            subplot(2,2,1);
            plot(abs(ifft(ce_filted13)));
            title(['ce filted13 with window ',num2str(w_len)]);
            subplot(2,2,2);
            plot(abs(ifft(ce_filted23)));
            title(['ce filted23 with window ',num2str(w_len)]);
            subplot(2,2,3);
            plot(abs(ifft(ce_filted33)));
            title(['ce filted33 with window ',num2str(w_len)]);
            subplot(2,2,4);
            plot(abs(ifft(ce_filted43)));
            title(['ce filted43 with window ',num2str(w_len)]);
            figure;
            subplot(2,2,1);
            plot(abs(ifft(ce_filted14)));
            title(['ce filted14 with window ',num2str(w_len)]);
            subplot(2,2,2);
            plot(abs(ifft(ce_filted24)));
            title(['ce filted24 with window ',num2str(w_len)]);
            subplot(2,2,3);
            plot(abs(ifft(ce_filted34)));
            title(['ce filted34 with window ',num2str(w_len)]);
            subplot(2,2,4);
            plot(abs(ifft(ce_filted44)));
            title(['ce filted44 with window ',num2str(w_len)]);
        end
        
        % filter noise for better channel estimaiton
        nrSRSseq_pi_rx_time = ifft(nrSRSseq_pi_rx);
        nrSRSseq_pi_time = ifft(nrSRSseq_pi);
        %received SRS
        figure;
        subplot(2,2,1);
        plot(abs(nrSRSseq_pi_rx_time(:,1)));
        title('SRS port1_rx in time');
        subplot(2,2,2);
        plot(abs(nrSRSseq_pi_rx_time(:,2)));
        title('SRS port2_rx in time');
        subplot(2,2,3);
        plot(abs(nrSRSseq_pi_rx_time(:,3)));
        title('SRS port3_rx in time');
        subplot(2,2,4);
        plot(abs(nrSRSseq_pi_rx_time(:,4)));
        title('SRS port4_rx in time');
        % local SRS
        figure;
        subplot(2,2,1);
        plot(abs(nrSRSseq_pi_time(:,1)));
        title('SRS port1 in time');
        subplot(2,2,2);
        plot(abs(nrSRSseq_pi_time(:,2)));
        title('SRS port2 in time');
        subplot(2,2,3);
        plot(abs(nrSRSseq_pi_time(:,3)));
        title('SRS port3 in time');
        subplot(2,2,4);
        plot(abs(nrSRSseq_pi_time(:,4)));
        title('SRS port4 in time');
        % -----------------------------------------------------------
        % get the pulse respone in time figure
        figure;
        subplot(2,2,1);
        plot(abs(ifft(channells_11)));
        title('channells11 in time');
        subplot(2,2,2);
        plot(abs(ifft(channells_21)));
        title('channells21 in time');
        subplot(2,2,3);
        plot(abs(ifft(channells_31)));
        title('channells31 in time');
        subplot(2,2,4);
        plot(abs(ifft(channells_41)));
        title('channells41 in time');
        figure;
        subplot(2,2,1);
        plot(abs(ifft(channells_12)));
        title('channells12 in time');
        subplot(2,2,2);
        plot(abs(ifft(channells_22)));
        title('channells22 in time');
        subplot(2,2,3);
        plot(abs(ifft(channells_32)));
        title('channells32 in time');
        subplot(2,2,4);
        plot(abs(ifft(channells_42)));
        title('channells42 in time');
        figure;
        subplot(2,2,1);
        plot(abs(ifft(channells_13)));
        title('channells13 in time');
        subplot(2,2,2);
        plot(abs(ifft(channells_23)));
        title('channells23 in time');
        subplot(2,2,3);
        plot(abs(ifft(channells_33)));
        title('channells33 in time');
        subplot(2,2,4);
        plot(abs(ifft(channells_43)));
        title('channells43 in time');
        figure;
        subplot(2,2,1);
        plot(abs(ifft(channells_14)));
        title('channells14 in time');
        subplot(2,2,2);
        plot(abs(ifft(channells_24)));
        title('channells24 in time');
        subplot(2,2,3);
        plot(abs(ifft(channells_34)));
        title('channells34 in time');
        subplot(2,2,4);
        plot(abs(ifft(channells_44)));
        title('channells44 in time');

        figure;
        subplot(2,2,1);
        plot(phase(ifft(channells_11)));
        title('channells11 in phase');
        subplot(2,2,2);
        plot(phase(ifft(channells_12)));
        title('channells12 in phase');
        subplot(2,2,3);
        plot(phase(ifft(channells_13)));
        title('channells13 in phase');
        subplot(2,2,4);
        plot(phase(ifft(channells_14)));
        title('channells14 in phase');
        figure;
        subplot(2,2,1);
        plot(phase(ifft(channells_21)));
        title('channells21 in phase');
        subplot(2,2,2);
        plot(phase(ifft(channells_22)));
        title('channells22 in phase');
        subplot(2,2,3);
        plot(phase(ifft(channells_13)));
        title('channells13 in phase');
        subplot(2,2,4);
        plot(phase(ifft(channells_24)));
        title('channells24 in phase');
        figure;
        subplot(2,2,1);
        plot(phase(ifft(channells_31)));
        title('channells31 in phase');
        subplot(2,2,2);
        plot(phase(ifft(channells_32)));
        title('channells32 in phase');
        subplot(2,2,3);
        plot(phase(ifft(channells_33)));
        title('channells33 in phase');
        subplot(2,2,4);
        plot(phase(ifft(channells_34)));
        title('channells34 in phase');
        figure;
        subplot(2,2,1);
        plot(phase(ifft(channells_41)));
        title('channells41 in phase');
        subplot(2,2,2);
        plot(phase(ifft(channells_42)));
        title('channells42 in phase');
        subplot(2,2,3);
        plot(phase(ifft(channells_43)));
        title('channells43 in phase');
        subplot(2,2,4);
        plot(phase(ifft(channells_44)));
        title('channells44 in phase');
        
        % mimo matrix gereration      
        mimo_matri(:,1,1) = (channells_11);                         %nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,1))
        mimo_matri(:,1,2) = (channells_12);                          %nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,2))
        mimo_matri(:,1,3) = (channells_13);                          %nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,3))
        mimo_matri(:,1,4) = (channells_14);                          %nrSRSseq_pi_rx(:,1).*conj(nrSRSseq_pi(:,4))
        mimo_matri(:,2,1) = (channells_21);                          %nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,1))
        mimo_matri(:,2,2) = (channells_22);                          %nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,2))
        mimo_matri(:,2,3) = (channells_23);                          %nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,3))
        mimo_matri(:,2,4) = (channells_24);                          %nrSRSseq_pi_rx(:,2).*conj(nrSRSseq_pi(:,4))
        mimo_matri(:,3,1) = (channells_31);                          %nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,1))
        mimo_matri(:,3,2) = (channells_32);                          %nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,2))
        mimo_matri(:,3,3) = (channells_33);                          %nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,3))
        mimo_matri(:,3,4) = (channells_34);                          %nrSRSseq_pi_rx(:,3).*conj(nrSRSseq_pi(:,4))
        mimo_matri(:,4,1) = (channells_41);                          %nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,1))
        mimo_matri(:,4,2) = (channells_42);                          %nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,2))
        mimo_matri(:,4,3) = (channells_43);                          %nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,3))
        mimo_matri(:,4,4) = (channells_44);                          %nrSRSseq_pi_rx(:,4).*conj(nrSRSseq_pi(:,4))
        % generate W for precoding
        % inver(H_SRS'*H_SRS)*H_SRS'
        cross_matr = mimo_matrix'*mimo_matrix;
        w = inv(cross_matr)*[mean(channells_11), mean(channells_22), mean(channells_33), mean(channells_44)]';

        
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

          modulation = '64QAM';%'256QAM';
          nlayers = 4;
          ncellid = 42;
          rnti = 6143;
          data = randi([0 1],6600,1);%8000 for 256QAM
          txsym = nrPDSCH(data,modulation,nlayers,ncellid,rnti);
          Freqsignal_0 = zeros(FFTSize,nrSRSParameters.sysConst.NSRS_ap);
          Freqsignal_0(7:281,:) = txsym;
          timesignal0 = F2T(Freqsignal_0, 160/4, 1);
          [dlDMRSSignal, index_dlDMRS] = dlDMRSGenerationi(nrSRSParameters);
          Freqsignal_1 = zeros(FFTSize,nrSRSParameters.sysConst.NSRS_ap);
          for annt=1:nrSRSParameters.sysConst.NSRS_ap
              Freqsignal_1(index_dlDMRS(:,annt),annt) = dlDMRSSignal(:,annt);  
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
        symbol0 = in(1:552,:);
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
        end
        %frequence interploter  
        interpWeightmatrix_all = zeros(288,144,2);
        port_indx = 1;
        for annt_rx = 1:2:4
            subcOffset = repmat((1:nSCperBlock), ndmrsRE, 1) - repmat(index_dlDMRS(:,annt_rx), 1, nSCperBlock);

            interpolationType = 'Bessel';
            if (strcmp(interpolationType, 'Bessel'))
                cross_covar = 1 ./ (1 + 1j * 2 * pi * channel.DelaySpread * subcSpacing * subcOffset);
            elseif (strcmp(interpolationType, 'sinc'))
                cross_covar = sinc(2*hannel.DelaySpread*subcSpacing*subcOffset);
            else
                error('unsupported interpolation type...');
            end

            auto_covar = zeros(ndmrsRE, ndmrsRE);
            for idmrsRE = 1:ndmrsRE
                auto_covar(:, idmrsRE) = cross_covar(:, nrSRSIndex(idmrsRE));
            end

            noisevar = 1 / SNR * eye(ndmrsRE);
            MMSE_matrix = auto_covar + noisevar;
            interpWeightmatrix = MMSE_matrix \ cross_covar;
            interpWeightmatrix_all(:,:,port_indx) = interpWeightmatrix.';
            port_indx = port_indx+1;
            
        end
        % freq interpolation with correlation weight matrix
        ls_tmp = zeros(144,1);
        ls_all = zeros(4,4,288);
         for annt_rx=1:nrSRSParameters.sysConst.NSRS_ap
             for annt_tx=1:nrSRSParameters.sysConst.NSRS_ap
                 ls_tmp(:,1) = ls(annt_rx,annt_tx,:);
                 ls_all(annt_rx,annt_tx,:) = interpWeightmatrix_all(:,:,floor(0.5+annt_rx/2)) * ls_tmp;
             end
        end 
%             est_channeltmp[] = interpWeightmatrix * ls.';
          %equalization irc
        H_w = zeros(4,4); 
        for k_sc = 1:288
            H_w(:,:) = ls_all(:,:,k_sc);
            w = (H_w'*H_w+ (1 / SNR * eye(4)))/H_w';
            Data_equelized(k_sc,:) = w*Data_rx(k_sc,:).';
        end
        %Data_rx
        for k_sc = 1:275
            H_w(:,:) = hi_used(k_sc,:,:);
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


