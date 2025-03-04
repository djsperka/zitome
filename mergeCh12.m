function [newTifFilename] = mergeCh12(varargin)
%MERGECH12 Takes the Ch1 and Ch2 files from a Bruker timepoint, interleaves
%the channels together in a single ome file. xmlfilename is assumed to be
%the same as the folder name, but can be passed separately.
%   Detailed explanation goes here, AND IS DEFINITELY NEEDED. 

%     arguments
%         folder {mustBeFolder}
%         options.outputfolder {mustBeFolderOrEmpty} = ''
%         options.xmlfilename {mustBeText} = ''
%         options.verbose {mustBeNumericOrLogical} = 0
%     end

    p = inputParser;
    addRequired(p, 'folder', @ischar);
    addParamValue(p, 'output', '', @ischar);
    addParamValue(p, 'xmlfilename', '', @ischar);
    addParamValue(p, 'verbose', '', @isnumeric);
    p.parse(varargin{:});
    folder = p.Results.folder;
    options.outputfolder=p.Results.output;
    options.xmlfilename = p.Results.xmlfilename;
    options.verbose = p.Results.verbose;
    
    
    
    %% Parse inputs

    if length(options.outputfolder) ==0
        useOutputFolder = folder;
    else
        useOutputFolder = options.outputfolder;
    end
    if length(options.xmlfilename) == 0
        % try to be clever in case the folder came in with a trailing file
        % separator.
        %TODO Test this on windows 'c:\work\cclab\' vs 'c:\work\cclab'
        if folder(end) == filesep
            folderStripped = folder(1:end-1);
        else
            folderStripped = folder;
        end
        [p,base,~] = fileparts(folderStripped);
        useXmlFilename = fullfile(folder,[base,'.xml']);
        newTifFilename = fullfile(useOutputFolder,[base,'_Ch12.tif']);
    else
        useXmlFilename = fullfile(folder, options.xmlfilename);
        [~,base,~] = fileparts(options.xmlfilename);
        newTifFilename = fullfile(useOutputFolder, [base, '_Ch12.tif']);
    end
    if options.verbose
        fprintf('XML filename %s\n', useXmlFilename);
        fprintf('Combined TIF filename %s\n', newTifFilename);
    end
%     if isfile(newTifFilename)
    if exist(newTifFilename, 'file')==2
         fprintf('*** Combined TIF file %s already exists. It will be overwritten.\n', newTifFilename);
    end

    % Parse xml file, fetch out node PVScan.Sequence.Frame.File. At each
    % such node, get the attributes for channel, page, and filename.
    S = parseXML(useXmlFilename);
    vtmp=XMLfun(S,'PVScan.Sequence.Frame.File',{'channel','page','filename'});
    V = sortrows(vertcat(vtmp{:}),[2]);

    % Assume the structure of the file is such that all channel 1 images
    % are stored in the same file. So here we just find the FIRST occurence
    % of the channel number '1' and take its filename. Same for channel '2'
    % below. 
    filename{1} = V{find(ismember(V(:,1),{'1'}),1),3};
    filename{2} = V{find(ismember(V(:,1),{'2'}),1),3};
    
    % How many pages? Find the max 'page' (column 2)
    maxPage = max(cellfun(@(x) str2double(x), V(:,2)));
    
    %% Add a pseudo header for the image to open in SIA - JF250304
    [nodeattrs]=XMLfun(S,'PVScan.PVStateShard.PVStateValue', {'key';'value'});
    attrsToMatch={'linesPerFrame';'pixelsPerLine';'scanLinePeriod';'opticalZoom'};
    values = cell(4,1);
    for i=1:length(nodeattrs)
        m = strcmp(nodeattrs{i}{1},attrsToMatch);
        if any(m)
            fprintf('%s %s\n',nodeattrs{i}{1}, nodeattrs{i}{2});
            values{m} = nodeattrs{i}{2};
        end
    end
    pseudoHeader = sprintf(...
        ['state.configName=''Bruker''\n' ...
        'state.acq.numberOfChannelsAcquire=2\n' ...
        'state.acq.numberOfChannelsSave=2\n' ...
        'state.acq.linesPerFrame=%s\n' ...
        'state.acq.pixelsPerLine=%s\n' ...
        'state.acq.msPerLine=%s\n' ...
        'state.acq.zoomFactor=%s'], ...
        values{1}, values{2}, values{3}, values{4});

    % pseudoHeader = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s', ...
    %  imagingConfig, nChans, nSavedChans, nLines, nPixels, lineTime, opticalZoom);
    % 
    % 
    %  imagingConfig = 'state.configName=''Bruker''';
    %  nChans = 'state.acq.numberOfChannelsAcquire=2'; 
    %  nSavedChans = 'state.acq.numberOfChannelsSave=2';
    %  nLines = 'state.acq.linesPerFrame=512';
    %  nPixels = 'state.acq.pixelsPerLine=512';
    %  lineTime = 'state.acq.msPerLine=2';
    %  opticalZoom = 'state.acq.zoomFactor=21';
    % 
    %  pseudoHeader = sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s', ...
    %  imagingConfig, nChans, nSavedChans, nLines, nPixels, lineTime, opticalZoom);
    % 
    %%
    
    

    if options.verbose
        fprintf('Found channel 1 file %s\n', filename{1});
        fprintf('Found channel 2 file %s\n', filename{2});
        fprintf('There are %d pages each Ch1,Ch2. There will be %d in the combined file.\n', maxPage, maxPage*2);
    end

    % Write ch1 image, then ch2 image. First ch1 image must be written
    % without append mode - this ensures that previously existing output
    % file is clobbered! All other images written with append.
    for ipage=1:maxPage
        if ipage==1
            imwrite(imread(fullfile(folder,filename{1}), ipage), newTifFilename, 'Description', pseudoHeader); % Added the pseudoHeader to the image description JF250304
        else
            imwrite(imread(fullfile(folder,filename{1}), ipage), newTifFilename, 'WriteMode', 'append');
        end            
        imwrite(imread(fullfile(folder,filename{2}), ipage), newTifFilename, 'WriteMode', 'append');
    end
end

function mustBeFolderOrEmpty(x)
    assert(isempty(x) || isfolder(x));
end