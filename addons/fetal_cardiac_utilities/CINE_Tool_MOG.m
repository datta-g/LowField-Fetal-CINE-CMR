function MOG_RWaveTimes=CINE_Tool_MOG(RT,Times,RRs,rSpokes,MI,Scanlength,PreviousPara)

RT = RT/max(abs(RT(:)));
M=zeros(length(RRs),1);
if ~exist('PreviousPara','var')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 1 PARAM SEARCH
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for iRR=1:length(RRs)
        M(iRR,1)=imagemetric(resort_RT(RT,Times,Linear_Transition_Model(RRs(iRR),Scanlength),MI,rSpokes),{'CINE'});
    end
    PreviousPara = RRs(find(M==min(M),1,'first'));
end
MOG_RWaveTimes = Linear_Transition_Model(PreviousPara,Scanlength);

log=struct('RWaveTimes',[],'Entropy',[],'ES',[]);
log(1).RWaveTimes=MOG_RWaveTimes;
log(1).Entropy=M;
log(1).RRs=RRs;

BaseRR=PreviousPara;
for loop=1:floor(log2(length(MOG_RWaveTimes)))
    PreviousPara = Gradient_Search(Times,RT,rSpokes,Double_Parameters(PreviousPara),MI,BaseRR);
end

log(2).RWaveTimes=Linear_Transition_Model(PreviousPara,Scanlength);
MOG_RWaveTimes = log(2).RWaveTimes;

end


function [PreviousPara,ES,offsets] = Gradient_Search(Times,RT,nSpokes,PreviousPara,MI,BaseRR)

nPara=length(PreviousPara);
ScanLength=max(Times(:));

PreviousCost=imagemetric(resort_RT(RT,Times,Linear_Transition_Model(PreviousPara,ScanLength),MI,nSpokes),{'CINE'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Numerical Gradient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
StepSizes=0:1:round(0.05*mean(PreviousPara));
G=zeros(nPara,1);

trial=1;
while trial<10
    
    offsets=linspace(-0.05*mean(PreviousPara),0.05*mean(PreviousPara),21);
    ES=zeros(length(offsets),nPara);
    
    
    for iPara=1:nPara
        [g,e] = Numerical_Gradient(iPara,offsets,Times,RT,nSpokes,PreviousPara,MI);
        G(iPara,1)=g;
        ES(:,iPara)=e;
    end
    
    [~,i]=min(ES);
    if isempty(find(offsets(i)~=0, 1))
        % display(['Break Trial ',num2str(trial)])
        break;
    end
    
    
    %%% Minimum Jitter
    [i,j]=find(ES==min(ES(:)),1,'first');
    Para=PreviousPara;
    Para(j)=Para(j)+offsets(i);
    Para(Para>(1.05*BaseRR))=1.05*BaseRR;Para(Para<(0.95*BaseRR))=0.95*BaseRR;
    ParaJitter=Para;
    MinimumJitter=imagemetric(resort_RT(RT,Times,Linear_Transition_Model(Para,ScanLength),MI,nSpokes),{'CINE'});
    
    %%% Minimum Global Shift
    [~,i]=min(ES);
    Para=PreviousPara;
    Para=makerow(Para)+offsets(i);
    Para(Para>(1.05*BaseRR))=1.05*BaseRR;Para(Para<(0.95*BaseRR))=0.95*BaseRR;
    ParaGlobal=Para;
    MinimumGlobal=imagemetric(resort_RT(RT,Times,Linear_Transition_Model(Para,ScanLength),MI,nSpokes),{'CINE'});
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Line Search
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    LineEntropy=zeros(length(StepSizes),1);
    LinePara=zeros(nPara,length(StepSizes));
    
    for loop=1:length(StepSizes)
        Para=PreviousPara;
        Shifts=floor(StepSizes(loop)*G./max(abs(G)));
        Para=makerow(Para)-makerow(Shifts);
        Para(Para>(1.05*BaseRR))=1.05*BaseRR;Para(Para<(0.95*BaseRR))=0.95*BaseRR;
        LinePara(:,loop)=Para;
        tempE=imagemetric(resort_RT(RT,Times,Linear_Transition_Model(Para,ScanLength),MI,nSpokes),{'CINE'});
        LineEntropy(loop,1)=tempE;
    end
    
    [MinimumGrad,i]=min(LineEntropy);
    ParaGrad=LinePara(:,i);
    
    [~,i]=min([MinimumJitter,MinimumGlobal,MinimumGrad]);
    if i==1
        PreviousPara=ParaJitter;
        %         display('Jitter')
    elseif i==2
        PreviousPara=ParaGlobal;
        %         display('Global')
    elseif i==3
        PreviousPara=ParaGrad;
        %         display('Grad')
    end
    
    
    if abs(i-PreviousCost)<10^-9
        % display(['No Change Trial ',num2str(trial)])
        break
    else
        PreviousCost=i;
    end
    trial=trial+1;
end
end

function [g,e] = Numerical_Gradient(iPara,offsets,Times,RT,nSpokes,Previous_Para,MI)
ScanLength=max(Times(:));
e=zeros(length(offsets),1);
for iOffset=1:length(offsets)
    Para=Previous_Para;
    Para(iPara)=Para(iPara)+offsets(iOffset);
    e(iOffset,1)=imagemetric(resort_RT(RT,Times,Linear_Transition_Model(Para,ScanLength),MI,nSpokes),{'CINE'});
end
f=spline(offsets,smooth(e(:,1)));
fp=fnder(f,1);
g=ppval(fp,0);
end

function I = resort_RT(RT,Times,RW,MI,rSpokes)
CP = Calculate_CardiacPhases(Times,RW);
I = RT_Interpolation_Weights(RT,CP,MI,rSpokes);
end

function IMG = RT_Interpolation_Weights(RT,CP,MI,nFrames)
MI=MI./max(abs(MI(:)));
if isempty(MI)
    MI=ones(length(CP),1);
end
CP=col(CP);
MI=col(MI);
MI=imresize(MI,[length(CP),1]);
IMG=zeros(size(RT,1),size(RT,2),nFrames);
CP=[CP-1;CP;CP+1];
% iCP=linspace(0,1,nFrames);
iCP = [1:nFrames]/nFrames; % dsg edit

for iFrame=1:nFrames
    x=mygaus(1,iCP(iFrame),mean(diff(iCP)),CP);
    x=(x(1:size(MI,1))+x(size(MI,1)+1:2*size(MI,1))+x(2*size(MI,1)+1:3*size(MI,1))).*MI;
    IMG(:,:,iFrame) = sum(bsxfun(@times,RT,permute(x,[2,3,1])),3)./sum(x(:));
end
end

function f = mygaus(h,c,s,x)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function used with leastsq to fit data to
% SF=height * exp(-(x-centre)^2/(2o^2)))
% param(1) = height
% param(2) = center
% param(3) = sigma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f= h*exp((-(x-c).^2)./(2*s.^2));
end






