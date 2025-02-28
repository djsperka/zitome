% Run mergeCh12 on a list of folders. I'm arbitrarily choosing the folders
% that begin with 'ds' - this gives a list of 29 folders. The folder names
% alone are used, so this must be run from the folder directly above.

% get list of folders beginning with 'ds', e.g. ds0345a-001
fstruct=dir('C:\Users\jcflores\Desktop\djs\ds0345-c\ds*');
dirflags = [fstruct.isdir];
dirstruct = fstruct(dirflags);
folders = {dirstruct(:).name};

% folders is a list of directory names. 
% run mergeCh12 on each directory, dumping all output into a single folder.
for i=1:length(folders)
    fprintf('%s\n', folders{i});
    mergeCh12(folders{i}, 'verbose', 1, 'output', 'combined');
end
