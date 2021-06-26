close all;
clear;
clc;
carrier = nrCarrierConfig('NSlot',0);
pdsch = nrPDSCHConfig;
pdsch.NumLayers = 4;
pdsch.PRBSet = 0:50;
pdsch.MappingType = 'B';
pdsch.SymbolAllocation = [0 7]; % [startSymbol  Length]

dmrs = nrPDSCHDMRSConfig;
dmrs.DMRSConfigurationType = 1;
dmrs.DMRSLength = 2;
dmrs.DMRSAdditionalPosition = 0;
dmrs.DMRSTypeAPosition =  3;
dmrs.NumCDMGroupsWithoutData = 2;
dmrs.NIDNSCID = 1;
dmrs.NSCID = 0;

if pdsch.NumLayers == 1
    
    dmrs.DMRSPortSet = [0];
    
elseif pdsch.NumLayers == 2
    
    dmrs.DMRSPortSet = [0 1];
    
elseif pdsch.NumLayers == 3
    
    dmrs.DMRSPortSet = [0 1 2];
    
elseif pdsch.NumLayers == 4
    
    dmrs.DMRSPortSet = [0 1 2 3];
    
end


pdsch.DMRS = dmrs;



sym_dmrs = nrPDSCHDMRS(carrier,pdsch,'OutputDataType','single');
%sym_dmrs = nrPDSCHDMRS(carrier,pdsch,'OutputDataType','double');

ind_dmrs = nrPDSCHDMRSIndices(carrier,pdsch,'IndexBase','0based','IndexOrientation','carrier');

ind_pdsch = nrPDSCHIndices(carrier,pdsch,'IndexBase','0based','IndexOrientation','carrier');



grid = complex(zeros([carrier.NSizeGrid*12 carrier.SymbolsPerSlot pdsch.NumLayers]));

grid(ind_dmrs+1) = sym_dmrs;

grid(ind_pdsch+1) = 0.5;



% Plot the grid

hFig = figure(2);

set(hFig, 'Position', [100 100 900 200]);

set(gcf,'color','w');



for i = 1:pdsch.NumLayers
    
    subplot(1,4,i)
    
    hold on;
    
    imagesc(abs(grid(:,:,i)));
    
    title(strcat('Port 100',num2str(dmrs.DMRSPortSet(i))));
    
    for i = 2:14
        
        line([i-0.5 i-0.5],[0 273*12],'Color','white');
        
    end
    
    for j = 1:12
        
        line([0 15],[j+0.5 j+0.5],'Color','white');
        
    end
    
    hold off;
    
    axis xy;
    
    box on;
    
    xlabel('OFDM Symbols');
    
    ylabel('Subcarriers');
    
    xlim([0.5 14.5]);
    
    ylim([0.5 12.5]);
    
    set(gca,'xtick',[0:14]);
    
    set(gca,'xticklabel',{'','0','1','2','3','4','5','6','7','8','9','10','11','12','13'});
    
    set(gca,'ytick',[0:12]);
    
    set(gca,'yticklabel',{'','0','1','2','3','4','5','6','7','8','9','10','11'});
    
end