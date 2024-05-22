function [MOGwaves, MI] = MOG_MODULE_MASK(RT,times_vec, Mask, ncardphase,scanlength)

% range of searched fetal RR interval
iRRs = 300:550;

% create an ROI of roughly 1/2 the field-of-view centered on the heart
nMask = CINE_Tool_Enlarge_IRREGULAR_ROI(Mask);

% Calculate the mutual information of all frames within the 1/2 FOV ROI described above
MI.post = CINE_Tool_Mutual_Information(cropVOL(RT,repmat(nMask,[1 1 size(RT,3)]),0)); 

% Create structure that will keep the RWaveTimes determined by MOG
MOGwaves=struct('RWaveTimes',[]);

% Run multiparameter RR interval search
MOGwaves=CINE_Tool_MOG(cropVOL(imgaussfilt(RT,0.5),repmat(Mask,[1 1 size(RT,3)]),0),times_vec,iRRs, ncardphase,MI.post,scanlength);