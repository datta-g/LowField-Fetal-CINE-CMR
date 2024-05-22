function Transforms = CINE_Tool_MOCO_edit( SRC_IMGs, TGT_IMGs, mask,rotationflag)

% mask=isnan(SRC_IMGs(:,:,1));mask(ROIy,ROIx)=1;

for normi = 1:size(SRC_IMGs,3)
    SRC_IMGs(:,:,normi)=SRC_IMGs(:,:,normi)./max(abs(col(SRC_IMGs(:,:,normi))));
end
TGT_IMGs=TGT_IMGs./max(abs(TGT_IMGs(:)));

%RREG_IMSEQ2IMSEG
%
%   U = RREG_IMSEQ2IMSEG( SRC_IMGs, TGT_IMGs, mask )
%
%   U = RREG_IMSEQ2IMSEG( SRC_IMGs, TGT_IMGs, mask, pixdim ) use specified
%   pixel dimensions
%
%   See also: transform_imseq, make_imref2d

% jfpva (joshua.vanamerom@kcl.ac.uk)


%% Setup


pixdim = [1,1];

tform2param = @(U) [ U.T(3,1), U.T(3,2), asind(U.T(1,2)) ]; % asind(T(1,2)) or -ve asind(T(1,2)) ? dsg comment
% NOTE: for reference, http://uk.mathworks.com/discovery/affine-transformation.html
% param2tform = @(tx,ty,rz) affine2d( [cosd(rz), sind(rz), 0; -sind(rz), cosd(rz), 0; tx, ty, 1 ] );



%% Frame-to-Frame Rigid Registration

% CWR Edits
%   DSG adds

% Transforms=zeros(size(SRC_IMGs,3),2);
Transforms=zeros(size(SRC_IMGs,3),3);

for iFrame = 1:size(SRC_IMGs,3)
    
    p = tform2param(rreg_im2im( SRC_IMGs(:,:,iFrame), TGT_IMGs(:,:,iFrame), mask, pixdim, rotationflag ));    
    
%     Transforms(iFrame,:) = p(1:2);
    Transforms(iFrame,:) = p;
    
    
    %     p        = tform2param( U(iF).A );
    %     U(iF).tx = p(1);
    %     U(iF).ty = p(2);
    %     U(iF).rz = p(3);
end


% U = struct();
% % CWR Edits
% for iF = nF,
%     U(iF).A = rreg_im2im( SRC_IMGs(:,:,iF), TGT_IMGs(:,:,iF), mask, pixdim );
%     p        = tform2param( U(iF).A );
%     U(iF).tx = p(1);
%     U(iF).ty = p(2);
%     U(iF).rz = p(3);
% end
%
%
% parfor iF = 1:nF-1,
%     U(iF).A = rreg_im2im( SRC_IMGs(:,:,iF), TGT_IMGs(:,:,iF), mask, pixdim );
%     p        = tform2param( U(iF).A );
%     U(iF).tx = p(1);
%     U(iF).ty = p(2);
%     U(iF).rz = p(3);
% end




end  % rreg_imseq2imseq(...)


function A = rreg_im2im( imSrc, imTgt, bwMsk, pixdim, rotationflag )

bwSrc = bwMsk;

maxDisp = 20;  % mm
rMax    = floor( maxDisp / min(pixdim ) );
rEst    = floor(sqrt(sum(bwSrc(:))/pi));  % radius, assuming bwSrc is circular
r       = min( rMax, rEst );
bwTgt   = bwmorph( bwSrc, 'dilate', r );

[OPT,METRIC] = imregconfig('monomodal');
OPT.GradientMagnitudeTolerance  = 1e-6;
OPT.MaximumStepLength           = 6.25e-3;
OPT.MinimumStepLength           = 1e-6;

T0 = [  1 0 0 ; ...     % null transform
    0 1 0 ; ...
    0 0 1 ];
A  = affine2d( T0 );    % initial 2d affine transform

% sigma = [ 0.8, 0.6, 0.4 ]; % source image smoothing, in pixels

% for iS = 1:numel(sigma),
    
%     srcCpx = complex(imgaussfilt(real(imSrc),sigma(iS)),imgaussfilt(imag(imSrc),sigma(iS)));
    srcCpx = abs(imSrc);
    [ srcR, src ] = make_imref2d( abs(srcCpx), bwMsk, pixdim, bwSrc );
    
    [ tgtR, tgt ] = make_imref2d( abs(imTgt),  bwMsk, pixdim, bwTgt );
    
    %     A = imregtform(imSrc,imTgt,'translation',OPT,METRIC,'DisplayOptimization',false,'PyramidLevels',3,'InitialTransformation',A);
    if ~rotationflag
        A = imregtform(src,srcR,tgt,tgtR,'translation',OPT,METRIC,'DisplayOptimization',false,'PyramidLevels',2,'InitialTransformation',A);
        %     A = imregtform(src,srcR,tgt,tgtR,'rigid',OPT,METRIC,'DisplayOptimization',false,'PyramidLevels',1,'InitialTransformation',A);
        
        %         A = imregtform(src,srcR,tgt,tgtR,'rigid',OPT,METRIC,'DisplayOptimization',false,'PyramidLevels',1,'InitialTransformation',A);
        
        % NOTE: imregtform uses bilinear interpolation, http://uk.mathworks.com/matlabcentral/answers/73537-how-does-imregister-work
        
        % JFPvA(2019-05-13) - ensure A.T is a translation; A.T should be a 3x3
        % identity matrix with real-valued translations in the A.T(3,1) and
        % A.T(3,2) positions
        indToCompare = [1 2 4 5 7 8 9];
        I = eye(3);
        if ~isequal( A.T(indToCompare), I(indToCompare) )
            warning( 'Estimated transformation is not a translation.' )
            disp(A.T)
            A.T(indToCompare) = I(indToCompare);
            fprintf( 'Forcing non-translation elements of transformation to be identity.\n' )
            disp(A.T)
        end
        
    else
        A = imregtform(src,srcR,tgt,tgtR,'rigid',OPT,METRIC,'DisplayOptimization',false,'PyramidLevels',2,'InitialTransformation',A);
        if ~isRigid(A)
            display('warning: transform is not rigid, but continuing.')
        end
    end
    
    
    
% end

end  % rreg_im2im(...)