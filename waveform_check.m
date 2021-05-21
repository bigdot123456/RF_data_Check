%% use this function to check data is ok or not!
ch=pdsch1;
sch_data=ch.waveform;
DMRS=ch.config.waveform.PDSCH{1,1}.DMRS;

% Antenna port and DM-RS configuration (TS 38.211 section 7.4.1.1)
% pdsch{1}.MappingType = 'A';                % PDSCH mapping type ('A'(slot-wise),'B'(non slot-wise))
% pdsch{1}.DMRSPower = 0;                    % Additional power boosting in dB

% pdsch{1}.DMRS.DMRSConfigurationType = 2;   % DM-RS configuration type (1,2)
% pdsch{1}.DMRS.NumCDMGroupsWithoutData = 2; % Number of DM-RS CDM groups without data. The value can be one of the set {1,2,3}
% pdsch{1}.DMRS.DMRSPortSet = [];            % DM-RS antenna ports used ([] gives port numbers 0:NumLayers-1)
% pdsch{1}.DMRS.DMRSTypeAPosition = 2;       % Mapping type A only. First DM-RS symbol position (2,3)
% pdsch{1}.DMRS.DMRSLength = 1;              % Number of front-loaded DM-RS symbols (1(single symbol),2(double symbol))   
% pdsch{1}.DMRS.DMRSAdditionalPosition = 0;  % Additional DM-RS symbol positions (max range 0...3)
% pdsch{1}.DMRS.NIDNSCID = 1;                % Scrambling identity (0...65535)
% pdsch{1}.DMRS.NSCID = 0;                   % Scrambling initialization (0,1)


% plot1SlotBasebandConstellation(sch_data(:,1));
% plot1SlotBasebandConstellation(sch_data(:,2));
indexSlotInFrame=0;
DMRSSymbolPos=2;
nSCID=DMRS.NSCID;
N_nSCID_ID=DMRS.NIDNSCID;
RBMax=270;

DMRSsignal = DMRS_base_seq_generation(indexSlotInFrame, ...
    DMRSSymbolPos, nSCID, N_nSCID_ID, RBMax);

