% get list of folders beginning with 'ds', e.g. ds0345a-001
fstruct=dir('/home/dan/work/zito/ds0345-c/ds*');
dirflags = [fstruct.isdir];
dirstruct = fstruct(dirflags);
folders = {dirstruct(:).name};

% folders is a list of directory names. 
% run mergeCh12 on each directory, dumping all output into a single folder.
for i=1:length(folders)
    fprintf('%s\n', folders{i});
    mergeCh12(folders{i},verbose=1,outputfolder='combined');
end