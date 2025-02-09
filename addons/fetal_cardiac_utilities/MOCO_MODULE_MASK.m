function [myTransforms, MI] = MOCO_MODULE_MASK(RT,t,Mask, rotationflag)
% MOCO MODULE
% performs registration for motion compensation on RT (realtime series) with time vector t
% DS Goolaub grabs CW Roy code from fetal ssfp cine

nMask =CINE_Tool_Enlarge_IRREGULAR_ROI(Mask);% % create an ROI of roughly 1/2 the field-of-view centered on the heart

AVGFrames=round(range(t)/400); % Calculate the number of frames needed for motion correction of the real time images (temporal resolution here set to 400 somewhat arbitrarily)

RTAVG=CINE_Tool_Temporal_Averaging(RT,AVGFrames); % Average real-time frames to achieve the temporal resolution described in the previous line

MI.pre = CINE_Tool_Mutual_Information(cropVOL(RTAVG,repmat(nMask,[1 1 size(RTAVG,3)]),0)); % Calculate the mutual information of all frames within the 1/2 FOV ROI described above
% This measure is used to automatically detect and weigh down instances of gross fetal movement

myTransforms=zeros(AVGFrames,3,size(RT,4));
for iSlice=1:size(RT,4)
    Targets=repmat(RTAVG(:,:,MI.pre(:,iSlice)==max(MI.pre(:,iSlice)),iSlice),[1,1,AVGFrames]); % Choose frame that has the highest mutual information with all frames as a target for motion correction
    myTransforms(:,:,iSlice) = CINE_Tool_MOCO_edit(abs(RTAVG(:,:,:,iSlice)),abs(Targets), Mask, rotationflag ); % Estimate translational displacement from the lower temporal resolution real-time images
end
