function [newTifFilename] = mergeCh12(folder,options)
%MERGECH12 Takes the Ch1 and Ch2 files from a Bruker timepoint, interleaves
%the channels together in a single ome file. xmlfilename is assumed to be
%the same as the folder name, but can be passed separately.
%   Detailed explanation goes here, AND IS DEFINITELY NEEDED. 

    arguments
        folder {mustBeFolder}
        options.outputfolder {mustBeFolderOrEmpty} = ''
        options.xmlfilename {mustBeText} = ''
        options.verbose {mustBeNumericOrLogical} = 0
    end

    %% Parse inputs

    if strlength(options.outputfolder) ==0
        useOutputFolder = folder;
    else
        useOutputFolder = options.outputfolder;
    end
    if strlength(options.xmlfilename) == 0
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
    if isfile(newTifFilename)
        warning('Combined TIF file %s already exists. It will be overwritten.', newTifFilename);
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
            imwrite(imread(fullfile(folder,filename{1}), ipage), newTifFilename);
        else
            imwrite(imread(fullfile(folder,filename{1}), ipage), newTifFilename, 'WriteMode', 'append');
        end            
        imwrite(imread(fullfile(folder,filename{2}), ipage), newTifFilename, 'WriteMode', 'append');
    end
end

function mustBeFolderOrEmpty(x)
    assert(isempty(x) || isfolder(x));
end