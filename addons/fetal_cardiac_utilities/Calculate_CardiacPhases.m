function CP=Calculate_CardiacPhases(Times,RWaveTimes)

while RWaveTimes(end)<max(Times(:))
    RWaveTimes(end+1)=RWaveTimes(end)+median(diff(RWaveTimes));%ScanLength+10;
end


% Times=single(Times);
if size(RWaveTimes,1)<size(RWaveTimes,2)
RWaveTimes=RWaveTimes';
end

if 10*size(Times,1)<size(Times,2)
Times=Times';
end


Before_Index=zeros(size(Times,1),size(Times,2),length(RWaveTimes)-1,'double');
After_Index=zeros(size(Times,1),size(Times,2),length(RWaveTimes)-1,'double');
% Determine which time points occur before and after each RWaveTime
% (indices)
for loop=1:(length(RWaveTimes)-1)
Before_Index(:,:,loop)=Times<=RWaveTimes(loop+1);
After_Index(:,:,loop)=Times>RWaveTimes(loop+1);
end
Before_Index=abs(sum(Before_Index,3)-length(RWaveTimes));
After_Index=sum(After_Index,3)+1;
%Keeps track of indices where data was not collected
Before_Index(isnan(Times))=1;
After_Index(isnan(Times))=1;
% For each time point, determine which RWaves come before and after
Last_RWaves=RWaveTimes(After_Index);
Next_RWaves=RWaveTimes(Before_Index+1);
% Calculate Cardiac Phase for each time point
CP=(Times-Last_RWaves)./(Next_RWaves-Last_RWaves);
%Keeps track of indices where data was not collected
CP(isnan(Times))=nan;
CP(CP==1)=0;
end