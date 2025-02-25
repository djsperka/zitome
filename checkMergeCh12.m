function [allGood,nnn] = checkMergeCh12(mergedfile,ch1file,ch2file)
%checkMerge12 Compares images in merged file to originals, returns true if
%all merged images are in the expected order.
%   The images in ch1file (ch2file) are the constituent files that went
%   into the combined file. The combined file should pages in this order: 
%   ch1file, page 1
%   ch2file, page 1
%   ch1file, page 2
%   ch2file, page 2
%   ... and so on. Each image is read from the file(s) and the makeup of
%   the combined file is verified.

    infoMerged = imfinfo(mergedfile);
    infoCh1 = imfinfo(ch1file);
    infoCh2 = imfinfo(ch2file);


    nMerged = size(infoMerged, 1);
    nCh1 = size(infoCh1, 1);
    nCh2 = size(infoCh2, 1);

    allGood = true;
    if nCh1 ~= nCh2 || (nCh1 + nCh2 ~= nMerged)
        fprintf('Error: Merged file has %d images, Ch1 has %d, Ch2 has %d. Should have merged=ch1+ch2\n', nMerged, nCh1, nCh2);
        allGood = false;
    else
        % Compare Ch1 images
        for iCh1 = 1:nCh1
            imCh1 = imread(ch1file,iCh1);
            imMerged = imread(mergedfile,2*iCh1-1);
            if ~isequal(imCh1, imMerged)
                fprintf('Error: Ch1 image %d not equal to combined image %d\n', iCh1, 2*iCh1-1);
                allGood = false;
            end
            if max(imCh1) == min(imCh1)
                fprintf('Warning: Ch1 image %d is uniform %d\n', iCh1, max(imCh1));
            end
        end
        % Compare Ch2 images
        for iCh2 = 1:nCh2
            imCh2 = imread(ch2file,iCh2);
            imMerged = imread(mergedfile,2*iCh2);
            if ~isequal(imCh2, imMerged)
                fprintf('Error: Ch2 image %d not equal to combined image %d\n', iCh2, 2*iCh2);
                allGood = false;
            end
            if max(imCh2) == min(imCh2)
                fprintf('Warning: Ch2 image %d is uniform %d\n', iCh2, max(imCh2));
            end
        end
    end
    nnn = [nMerged, nCh1, nCh2];
end