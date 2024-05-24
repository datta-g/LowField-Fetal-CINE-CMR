% NAME :  
%           setpath_cine
% 
% DESCRIPTION:
%           This script sets paths for the required code.
% INPUTS:
%           - 
%
% OUTPUTS:
%           alters MATLAB path
%           
% NOTES:
%           
%
% Datta Singh Goolaub, 2024
% datta.goolaub@sickkids.ca
% SickKids, Translational Medicine

%% path modification

ADDONS = [pwd filesep 'addons'];
addpath(genpath(ADDONS));

% remove certain files from path for no confusion
MFILPATH=[pwd filesep 'addons' filesep 'spiral_aliasing_reduction' filesep 'mfile'];

%moving editted files for CINE
mkdir([MFILPATH filesep 'original'])
if exist([MFILPATH filesep 'compute_tTV.m'])
    movefile([MFILPATH filesep 'compute_tTV.m'],[MFILPATH filesep 'original' filesep 'compute_tTV.m']);
end
if exist([MFILPATH filesep 'cost_STCR.m'])
    movefile([MFILPATH filesep 'cost_STCR.m'],[MFILPATH filesep 'original' filesep 'cost_STCR.m']);
end

%remove this from path if not already
rmpath([MFILPATH filesep 'original'])
