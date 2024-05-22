% para = setpara(FOV,isrt, iscine, armtotal, armshared, niters, tTV_val, sTV_val,ncardphcine)
%
% INPUTS
% Header        header from raw data
% isrt          flag for is real-time recon
% iscine        flag for is cine recon
% armtotal      number of arms per frame
% armshared     number of shared arms between frames
% niters        number of iterations
% tTV_val       regularisation coefficient temporal total variation
% sTV_val       regularisation coefficient spatial total variation
% ncardphcine   number of cardiac phases in CINE recon
%
% OUTPUTS
% para          struct controlling recon process


% sets reconstruction parameters for recon pipeline
% Datta Singh Goolaub, SickKids. September 2022

function para = setpara(FOV,isrt, iscine, armtotal, armshared, niters, tTV_val, sTV_val,ncardphcine)

% checks on inputs
if nargin < 9
    ncardphcine = 20; %setting a defaul number of cardiac phases
end
if nargin < 8
    sTV_val = 0; % setting sTV_val to off
end
if nargin < 7
    tTV_val = 0.001; % setting a default tTV_val
end
if nargin < 6
    niters = 30; %number of iterations for CS
end
if nargin < 5
    armshared = 0; % number of arms in shared window is set to off
end
if nargin < 4
    armtotal = 10; % default number of arms in frame
end
if nargin < 3
    iscine = 0; % cine is off
end
if nargin < 2
    isrt = 1; % by default running an rt recon
end
if nargin < 1
    % setting some default Header vals
    FOV.FOv = 1.5;
    FOV.matrix_size = [320 320];
end


para.setting.ifplot     = 0;                        % plot convergence during reconstruction
para.setting.ifGPU      = 0;                        % set to 1 when you want to use GPU
para.Recon.time_frames  = 'all';                    %set to 'all' for reconstructe all time frames (could take a while)
para.weight_tTV.val     = tTV_val;                  % temporal TV regularizaiton parameter (normalized by F^T d)
para.weight_tTV.rt      = isrt;                     % is this for rt recon
para.weight_tTV.cine    = iscine;                   % is this for cine recon
para.weight_sTV         = sTV_val;                  % spatial TV regularizaiton parameter (normalized by F^T d)
para.Recon.narm         = armtotal;                 % number of arms per time frame
para.Recon.overlaparm   = armshared;
para.Recon.FOV          = FOV.FOv;               % reconstruction FOV
para.Recon.epsilon      = eps('single');            % small vale to avoid singularity in TV constraint
para.Recon.step_size    = 2;                        % initial step size
para.Recon.noi          = niters;                   % number of CG iterations 30 for cine 20 for rt
para.Recon.type         = '2D Spiral server';       % stack of spiral
para.Recon.break        = 1;                        % stop iteration if creteria met. Otherwise will run to noi
para.Recon.matrix_size  = FOV.matrix_size;
para.Recon.method = 'no';
para.MOCO.rotation = 0;                             % add or remove rotation to pipeline
para.MOG.ncardphases = ncardphcine;                 % number of cardiac phases