function sym = nrPDSCH(cws,modulation,nlayers,nid,rnti,varargin)
%nrPDSCH Physical downlink shared channel
%   SYM = nrPDSCH(CWS,MODULATION,NLAYERS,NID,RNTI) returns a complex matrix
%   SYM containing the physical downlink shared channel (PDSCH) modulation
%   symbols as defined in TS 38.211 Sections 7.3.1.1 - 7.3.1.3. The
%   processing consists of scrambling, symbol modulation and layer mapping.
%   
%   CWS represents one or two DL-SCH codewords as described in TS 38.212
%   Section 7.2.6. CWS can be a column vector (representing one codeword)
%   or a cell array of one or two column vectors (representing one or two
%   codewords).
%
%   MODULATION specifies the modulation scheme for the codeword or
%   codewords in CWS. MODULATION can be specified as one of
%   'QPSK','16QAM','64QAM','256QAM'. If CWS contains two codewords, this
%   modulation order will apply to both codewords. Alternatively, a string
%   array or cell array of character vectors can be used to specify
%   different modulation schemes for each codeword.
%
%   NLAYERS is the number of transmission layers (1...4 for one codeword,
%   5...8 for two codewords).
%
%   NID is the scrambling identity, representing either the cell identity
%   NCellID (0...1007) or the higher-layer parameter
%   dataScramblingIdentityPDSCH (0...1023).
%
%   RNTI is the Radio Network Temporary Identifier (0...65535).
%
%   SYM = nrPDSCH(CWS,MODULATION,NLAYERS,NID,RNTI,NAME,VALUE) specifies an
%   additional option as a NAME,VALUE pair to allow control over the format
%   of the symbols:
%
%   'OutputDataType' - 'double' for double precision (default)
%                      'single' for single precision
%
%   Example 1:
%   % Generate PDSCH symbols for a single codeword of 8000 bits, using 
%   % 256QAM modulation and 4 layers.
%
%   modulation = '256QAM';
%   nlayers = 4;
%   ncellid = 42;
%   rnti = 6143;
%   data = randi([0 1],8000,1);
%   sym = nrPDSCH(data,modulation,nlayers,ncellid,rnti);
%
%   Example 2:
%   % Generate PDSCH symbols for two codewords with different modulation 
%   % orders and a total of 8 layers.
%
%   modulation = {'64QAM' '256QAM'};
%   nlayers = 8;
%   ncellid = 1;
%   rnti = 6143;
%   data = {randi([0 1],6000,1) randi([0 1],8000,1)};
%   sym = nrPDSCH(data,modulation,nlayers,ncellid,rnti);
%
%   See also nrPDSCHDecode, nrPDSCHPRBS, nrDLSCH.

%   Copyright 2018 The MathWorks, Inc.

%#codegen

    narginchk(5,7);
    
    % Establish number of codewords from number of layers
    fcnName = 'nrPDSCH';
    validateattributes(nlayers,{'numeric'},{'nonempty','real','scalar',...
            'finite','integer','>=',1,'<=',8},fcnName,'NLAYERS');
    ncw = 1 + (nlayers > 4);
        
    % Validate modulation scheme or schemes, and if only one modulation
    % scheme is specified for two codewords then apply it to both
    mods = nr5g.internal.validatePDSCHModulation( ...
        fcnName,modulation,ncw);
    
    % Validate number of data codewords
    if ~iscell(cws)
        cellcws = {cws};
    else
        cellcws = cws;
    end
    coder.internal.errorIf(ncw~=numel(cellcws), ...
        'nr5g:nrPDSCH:InvalidDataNCW',nlayers,ncw,numel(cellcws));
    
    scrambled = coder.nullcopy(cell(1,ncw));
    modulated = coder.nullcopy(cell(1,ncw));
    for q = 1:ncw

        % Scrambling, TS 38.211 Section 7.3.1.1
        validateattributes(cellcws{q},{'double','int8','logical'}, ...
            {},fcnName,'CWS');
        c = nrPDSCHPRBS(nid,rnti,q-1,length(cellcws{q}));
        scrambled{q} = xor(cellcws{q},c);

        % Modulation, TS 38.211 Section 7.3.1.2
        modulated{q} = nrSymbolModulate(scrambled{q},mods{q},varargin{:});

    end

    % Layer mapping, TS 38.211 Section 7.3.1.3
    sym = nrLayerMap(modulated,nlayers);
    
end
