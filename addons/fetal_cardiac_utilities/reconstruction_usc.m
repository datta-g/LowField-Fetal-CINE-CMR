function [Image_recon] = reconstruction_usc(kdata, kloc, w, para)
%--------------------------------------------------------------------------
%   Image_recon = reconstruction(para)
%--------------------------------------------------------------------------
%   Main reconstruction function used in MRM-20-21688, to reproduce no
%   correction, ES correction, and LF reconstruction for a dataset
%   corresponding to Figure 3.
%--------------------------------------------------------------------------
%   Please cite this paper if you use this code:
%       [1]     Aliasing Artifact Reduction for Spiral Real-Time MRI. MRM,
%               20.21688
%--------------------------------------------------------------------------
%   Author:
%       Ye Tian
%       E-mail: phye1988@gmail.com
%
%   Copyright:
%       MREL, 2020
%       https://mrel.usc.edu
%--------------------------------------------------------------------------
% adapted by DS Goolaub

%% read data
% kdata: kspace data, [nsample, narm, ncoil, nt]
% kloc : real (kx) and imag (ky), [nsample, narm, nt]
% w:     density compensation function [nsample, narm, nt]

matrix_size = para.Recon.matrix_size;
para.Recon.image_size  = round(matrix_size * para.Recon.FOV);

%% fix dimentions for kspace, kx and ky
scale_factor = 1e3 * prod(para.Recon.image_size) / max(abs(kdata(:)));
% kSpace = single(permute(kdata,[1, 3, 2])) * scale_factor;
kSpace = single(kdata) * scale_factor;

% correct image orientation (90 degree roation)
kx = -imag(kloc);
ky = real(kloc);

clearvars -except kSpace kx ky w para sens_map first_est

[sx, ns, nc, nt] = size(kSpace);

narm = para.Recon.narm;
oarm = para.Recon.overlaparm;

% nof = floor(ns/(narm-oarm));
% kSpace(:, nof*narm+1:end, :) = [];
% kx(:, nof*narm+1:end) = [];
% ky(:, nof*narm+1:end) = [];
%
% kSpace = reshape(kSpace, [sx, narm, nof, nc]);
% kx = reshape(kx, [sx, narm, nof]);
% ky = reshape(ky, [sx, narm, nof]);

[~,kx] = CINE_Tool_RT_Sort(kSpace,kx,narm,oarm);
[kSpace,ky] = CINE_Tool_RT_Sort(kSpace,ky,narm,oarm);

%% normalize kx, ky
matrix_size = para.Recon.matrix_size;
para.Recon.image_size  = round(matrix_size * para.Recon.FOV);

kx = kx * para.Recon.image_size(1);
ky = ky * para.Recon.image_size(2);

%% NUFFT structure
Data.N = NUFFT.init(kx, ky, 1, [4, 4], para.Recon.image_size(1), para.Recon.image_size(1));
Data.N.W = w(:, 1);

%% initial estimate, sensitivity map
Data.kSpace = permute(kSpace,[1 2 4 3]); % memory issues

Data.first_est = NUFFT.NUFFT_adj(Data.kSpace, Data.N);

scale = max(abs(Data.first_est(:)));

Data.sens_map = get_sens_map(Data.first_est, '2D');

Data.kSpace = permute(kSpace,[1 2 4 3]);
Data.first_est = sum(Data.first_est .* conj(repmat(Data.sens_map,[1 1 size(Data.first_est,3) 1])), 4);

%% set parameters
para.Recon.no_comp = nc;
para.Recon.weight_tTV = para.weight_tTV;
para.Recon.weight_tTV.val = scale * para.weight_tTV.val; % temporal regularization weight
para.Recon.weight_sTV = scale * para.weight_sTV; % spatial regularization weight

clearvars -except Data para

%% conjugate gradient reconstruction (STCR == spatiotemporal constrained reconstruction)
[Image_recon, para] = STCR_conjugate_gradient(Data, para);
%% crop image
Image_recon = abs(Image_recon);
Image_recon = crop_half_FOV(Image_recon, para.Recon.matrix_size);
end
