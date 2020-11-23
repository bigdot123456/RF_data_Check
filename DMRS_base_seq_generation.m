%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DMRSsignal = DMRS_base_seq_generation(indexSlotInFrame, ...
    DMRSSymbolPos, nSCID, N_nSCID_ID, RBMax)
% initial value of PRBS for reference signal
% Support single-symbol DMRS
initC = mod(2^17*(14 * (indexSlotInFrame - 1) + (DMRSSymbolPos - 1) + 1) ...
    *(2 * N_nSCID_ID + 1)+2*N_nSCID_ID+nSCID, 2^31);
% m sequencegeneration
sequenceLength = 2 * 6 * RBMax; % 4m/6m, To be modified
[glodsequence] = randomSequenceGenetator(sequenceLength, initC);
% reference signal sequencegeneration
m = 1:2:sequenceLength;
DMRSsignal = ((1 - 2 * glodsequence(m)) + ...
    1j * (1 - 2 * glodsequence(m+1))) / sqrt(2);
end