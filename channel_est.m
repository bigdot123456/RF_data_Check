function [outputArg1,outputArg2] = channel_est(inputArg1,inputArg2)
%CHANNEL_EST 此处显示有关此函数的摘要
%   此处显示详细说明
        %channel estimation ls first get the atenn pi DMRS
        for annt=1:nrSRSParameters.sysConst.NSRS_ap
           dlDMRX_rx_seq(:,annt) = DMRX_rx(index_dlDMRS(:,annt),annt);
        end
        % ls
        ce_cross_matrix_inx=1;
        for annt_rx=1:nrSRSParameters.sysConst.NSRS_ap
            ls(annt_rx,:) = dlDMRX_rx_seq(:,annt_rx).*conj(dlDMRSSignal(:,annt_rx));  
        end
        %frequence interploter  
        nSCperBlock = 288;
        ndmrsRE = 144;
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

            noisevar = 1 / 60 * eye(ndmrsRE);
            MMSE_matrix = auto_covar + noisevar;
            interpWeightmatrix = MMSE_matrix \ cross_covar;
            interpWeightmatrix_all(:,:,port_indx) = interpWeightmatrix.';
            port_indx = port_indx+1;
            
        end
        % freq interpolation with correlation weight matrix
        for annt_rx=1:nrSRSParameters.sysConst.NSRS_ap
            est_channeltmp(:,annt_rx) = interpWeightmatrix_all(:,:,floor(0.5+annt_rx/2)) * ls(annt_rx,:).';
        end 
end

