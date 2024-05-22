function [KSpaceRT,kRT] = CINE_Tool_RT_Sort(KSpace,k,SpokesPerFrame,SharedSpokes)

TotalFrames=floor((size(KSpace,2)/(SpokesPerFrame-SharedSpokes))-(SharedSpokes/(SpokesPerFrame-SharedSpokes)));

kRT=zeros(size(k,1),SpokesPerFrame,TotalFrames,'single');
KSpaceRT=zeros(size(KSpace,1),SpokesPerFrame,size(KSpace,3),TotalFrames,size(KSpace,4),'single');

for iFrame=1:TotalFrames
    SlidingWindow=1+(iFrame-1)*(SpokesPerFrame-SharedSpokes):(iFrame-1)*(SpokesPerFrame-SharedSpokes)+SpokesPerFrame;
    if max(SlidingWindow)>size(KSpace,2)
        break;
    end
    kRT(:,:,iFrame)=k(:,SlidingWindow);
    KSpaceRT(:,:,:,iFrame,:)=KSpace(:,SlidingWindow,:,:);
end
end

