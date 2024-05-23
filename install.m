% This script downloads the additional required code.
%
% Datta Singh Goolaub, 2024
% datta.goolaub@sickkids.ca
% SickKids, Translational Medicine

clear; clc;

% check version and issue warnings
if verLessThan('matlab','9.7')
    fprintf('\nWARNING:  This MATLAB is less than the version the pipeline tested on.\n')
    fprintf('          If some features are not working, upgrade to version 9.7 and above.\n')
end

%get main location
LOWFIELCINEPATH = pwd;
cd('addons')

%sourcing required spiral reconstruction files from https://github.com/usc-mrel/spiral_aliasing_reduction
%adding required files
try
    !git clone --filter=blob:none --no-checkout --depth 1 --sparse https://github.com/usc-mrel/spiral_aliasing_reduction
    cd spiral_aliasing_reduction
    !git sparse-checkout add mfile
    !git checkout
    cd ..
catch
    fprintf(2,'\nERROR: Git is not set up on this machine. To set up git control\n')
    fprintf(2,'       see https://www.mathworks.com/help/matlab/matlab_prog/set-up-git-source-control.html#mw_b5884d8b-7c3e-4c38-b055-28e39b604147\n')
    fprintf(2,'       Or manually clone https://github.com/usc-mrel/spiral_aliasing_reduction into the folder "addons"\n')
end

%install mutual info toolbox
%DOI: 10.1109/TPAMI.2005.159
url = 'https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/14888/versions/1/download/zip';
filename = 'mi.0.912.zip';
websave(filename, url);
unzip(filename,'./tmp')
movefile('./tmp/mi','./fetal_cardiac_utilities/Mutual Information')
rmdir('./tmp','s')
delete *.zip
cd('./fetal_cardiac_utilities/Mutual Information'); makeosmex;

% return to main folder
cd(LOWFIELCINEPATH)