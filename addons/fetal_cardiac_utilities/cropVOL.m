function VOL = cropVOL(VOL, M, togle)
% M is mask
% removes padded zeros
% togle: 1 is padded, 0 is cropped
% DS Goolaub

if ndims(VOL) == 3
    
    if size(M,3) ~= size(VOL,3)
        M=M(:,:,1:size(VOL,3));
    end
    tvol = sum(M,3);
    
    if ~togle
        VOL = VOL.*M;
        VOL(sum(tvol,2)==0,:,:) = [];
        VOL(:,sum(tvol,1)==0,:) = [];
        
    elseif togle == 1
        VOL = VOL.*M;
        
    elseif togle == 2
        aVOL = tvol;
        aVOL(sum(tvol,2)~=0,:,:) = 1;
        bVOL = tvol;
        bVOL(:,sum(tvol,1)~=0,:) = 1;
        tvol = aVOL.*bVOL;
        VOL(sum(tvol,2)==0,:,:) = [];
        VOL(:,sum(tvol,1)==0,:) = [];
    end
    
elseif ndims(VOL) == 4
    
    % dim 3 in vol is time
    % dim 4 in vol is slice
    M = repmat(M,[1 1 1 size(VOL,3)]);
    M = permute(M,[1 2 4 3]);
    if size(M,3) ~= size(VOL,4)
        M=M(:,:,:,1:size(VOL,4));
    end
    
    tvol = sum(sum(M,4),3);
    if ~togle
        VOL = VOL.*M;
        VOL(sum(tvol,2)==0,:,:,:) = []; % same mask for all times, so using index 1
        VOL(:,sum(tvol,1)==0,:,:) = []; % same mask for all times, so using index 1
        
    elseif togle == 1
        VOL = VOL.*M;
        
    elseif togle == 2
        aVOL = tvol;
        aVOL(sum(tvol,2)~=0,:,:,:) = 1;
        bVOL = tvol;
        bVOL(:,sum(tvol,1)~=0,:,:) = 1;
        tvol = aVOL.*bVOL;
        VOL(sum(tvol,2)==0,:,:,:) = [];
        VOL(:,sum(tvol,1)==0,:,:) = [];
    end
elseif ndims(VOL) == 5
    
    % dim 3 in vol is time
    % dim 4 in vol is slice
    % dim 5 is vel
    M = repmat(M,[1 1 1 size(VOL,3) size(VOL,5)]);
    M = permute(M,[1 2 4 3 5]);
    if size(M,3) ~= size(VOL,4)
        M=M(:,:,:,1:size(VOL,4),:);
    end
    VOL = VOL.*M;
    tvol = sum(sum(sum(M,4),3),5);
    
    if ~togle
        VOL = VOL.*M;
        VOL(sum(tvol,2)==0,:,:,:,:) = []; % same mask for all times, so using index 1
        VOL(:,sum(tvol,1)==0,:,:,:) = []; % same mask for all times, so using index 1
    elseif togle == 1
        VOL = VOL.*M;
        
    elseif togle == 2
        aVOL = tvol;
        aVOL(sum(tvol,2)~=0,:,:,:,:) = 1;
        bVOL = tvol;
        bVOL(:,sum(tvol,1)~=0,:,:,:) = 1;
        tvol = aVOL.*bVOL;
        VOL(sum(tvol,2)==0,:,:,:,:) = [];
        VOL(:,sum(tvol,1)==0,:,:,:) = [];
    end
end


end
