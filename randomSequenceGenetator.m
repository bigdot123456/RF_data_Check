%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sequencePRBS = randomSequenceGenetator(sequenceLength, initC)
%===============================================================================================
% function: Pseudo-random sequence generation.
% input:
%   sequenceLength: length of random sequence
%   initC: c_init
% output:
%   randomSequence: Pseudo-random sequence
%===============================================================================================
nC = 1600; % Nc parameter
% the initial value of the firs m-sequence, x1
x1 = zeros(nC+sequenceLength, 1);
x1(1) = 1;
% the initial value of the second m-sequence, x2
initCBinary = dec2bin(initC);

nLengthInitCBinary = length(initCBinary);

x2 = zeros(nC+sequenceLength, 1);


x2(nLengthInitCBinary:-1:1) = str2num(initCBinary');
% generate the 2 m-sequences
for iN = 1:nC + sequenceLength
    x1(iN+31) = mod(x1(iN+3)+x1(iN), 2);
    x2(iN+31) = mod(x2(iN+3)+x2(iN+2)+x2(iN+1)+x2(iN), 2);
end

% generate the pseudo-radom Gold sequence
sequencePRBS = zeros(sequenceLength, 1);
for iN = 1:sequenceLength
    sequencePRBS(iN) = mod(x1(iN+nC)+x2(iN+nC), 2);
end
sequencePRBS = sequencePRBS.';
return