function [Image_recon] = reconstruction_usc_cine(kdata, kloc, w, para,CP, myTransforms, MI)
%   adapted from:
%               Aliasing Artifact Reduction for Spiral Real-Time MRI. MRM,
%               20.21688
%--------------------------------------------------------------------------
%   adapted by DS Goolaub, SickKids. September 2022.
%--------------------------------------------------------------------------

%% read data
% kdata: kspace data, [nsample, narm, ncoil, nt]
% kloc : real (kx) and imag (ky), [nsample, narm, nt]
% w:     density compensation function [nsample, narm, nt]

rFrames=para.MOG.ncardphases; % forced here for now

matrix_size = para.Recon.matrix_size;
para.Recon.image_size  = round(matrix_size * para.Recon.FOV);

%% fix dimensions for kspace, kx and ky
scale_factor = 1e3 * prod(para.Recon.image_size) / max(abs(kdata(:)));
% kSpace = single(permute(kdata,[1, 3, 2])) * scale_factor;
kSpace = single(kdata) * scale_factor;

% correct image orintation (90 degree roation)
kx = -imag(kloc);
ky = real(kloc);

% transform application
MOCO=exp(-2*pi*1i*(-bsxfun(@times,imresize(-myTransforms(:,2),[size(kSpace,2),1])',kx)-bsxfun(@times,imresize(-myTransforms(:,1),[size(kSpace,2),1])',ky)));

% angles prepped
if para.MOCO.rotation
    ROT = imresize(-myTransforms(:,3),[size(kSpace,2),1]);
end

W = KSpace_Interpolation_Weights(size(kSpace,1),CP,MI,rFrames); % Determine weightings which incorporate the cardiac phase and mutual information for each spoke in order to create motion corrected CINEs


clearvars -except kSpace kx ky w para csm MOCO W rFrames ROT

[sx, ns, nc, nt] = size(kSpace);


[~,SpokeIndices]=sort(squeeze(W(1,:,:)),1,'descend');
rSpokes=max(sum(squeeze(W(1,:,:))>max(W(:))/2)); % Sort spokes according to weights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Re-sort k-space according to the weighting matrix (W) and
% reconstructed spokes per frame (rSpokes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kmx=zeros(size(kSpace,1),rSpokes,rFrames,'single'); %Initialize variable
kmy = kmx;
%     wMOG = kMOG;
param.y=zeros(size(kSpace,1),rSpokes,size(kSpace,3),rFrames,'single'); %Initialize variable
for iFrame=1:rFrames
    param.y(:,:,:,iFrame)=bsxfun(@times,bsxfun(@times,kSpace(:,SpokeIndices(1:rSpokes,iFrame),:),MOCO(:,SpokeIndices(1:rSpokes,iFrame))),W(:,SpokeIndices(1:rSpokes,iFrame),iFrame));
    
    % no rotation correct
    if ~para.MOCO.rotation
        kmx(:,:,iFrame)=kx(:,SpokeIndices(1:rSpokes,iFrame));
        kmy(:,:,iFrame)=ky(:,SpokeIndices(1:rSpokes,iFrame));
        
    % rotation correct
    else
        for nspoke = 1:rSpokes
            cspoke = SpokeIndices(nspoke,iFrame); % current spoke under investigation
            rmat = [cosd(ROT(cspoke)) -sind(ROT(cspoke)); sind(ROT(cspoke)) cosd(ROT(cspoke))];
            ktmp = rmat * [kx(:,cspoke) ky(:,cspoke)]'; % dsg to check if orientation is correct
            kmx(:,nspoke,iFrame) = ktmp(1,:)';
            kmy(:,nspoke,iFrame) = ktmp(2,:)';
        end
    end
    
    %         wMOG(:,:,iFrame)=w(:,SpokeIndices(1:rSpokes,iFrame));
end


kSpace = param.y;
kx = kmx;
ky = kmy;
clear kmy kmx



%% normalize kx, ky
matrix_size = para.Recon.matrix_size;
para.Recon.image_size  = round(matrix_size * para.Recon.FOV);

kx = kx * para.Recon.image_size(1);
ky = ky * para.Recon.image_size(2);

%% NUFFT structure
Data.N = NUFFT.init(kx, ky, 1, [4, 4], para.Recon.image_size(1), para.Recon.image_size(1));
Data.N.W = w(:, 1);

%% initial estimate, sensitivity map
Data.kSpace = permute(kSpace,[1 2 4 3]);
Data.first_est = NUFFT.NUFFT_adj(Data.kSpace, Data.N);

scale = max(abs(Data.first_est(:)));

Data.sens_map = get_sens_map(Data.first_est, '2D');

Data.first_est = sum(Data.first_est .* conj(repmat(Data.sens_map,[1 1 size(Data.first_est,3) 1])), 4);

%% set parameters
para.Recon.no_comp = nc;
para.Recon.weight_tTV = para.weight_tTV;
para.Recon.weight_tTV.val = scale * para.weight_tTV.val; % temporal regularization weight
para.Recon.weight_sTV = scale * para.weight_sTV; % spatial regularization weight

clearvars -except Data para

%% conjugate gradient reconstruction
[Image_recon, ~] = STCR_conjugate_gradient(Data, para);


end
