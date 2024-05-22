% set paths
setpath_cine;
clear; clc;

%% RAW DATA LOAD
% load test data: kspace + traj + dcf
load('./testdata/test_fetal_data.mat','kspace','traj','dcf','FOV')
kspace = kspace(:,1:1500,:); fprintf(2,'remove after test\n')
traj = traj(:,1:1500); fprintf(2,'remove after test\n')
%% REAL TIME RUN
% recon FOV setup
FOV.matrix_size = [296 296];
FOV.FOv = 1.5;
% reconstruction parameter setup
para = setpara(FOV,1, 0, 15, 10, 20, 0.08, 0);

% real-time reconstruction
fetalRT_recon = reconstruction_usc(kspace, traj, dcf, para);


%% MOG + MOCO RUN
% computing real-time times
load('./testdata/test_fetal_data.mat','TR')
indx = 1:size(kspace,2);
[gpindx,~] = CINE_Tool_RT_Sort(indx,indx,para.Recon.narm,para.Recon.overlaparm);
times_vec = TR*mean(squeeze(gpindx)); clear gpindx;
times_vec = times_vec(1:size(fetalRT_recon,3));

% motion correction
load('./testdata/test_fetal_data.mat','Mask')
[myTransforms] = MOCO_MODULE_MASK(fetalRT_recon,times_vec, Mask, 0);

% motion correction applied to real-time
fetalRT_recon_moco = CINE_Tool_Correct_RT(fetalRT_recon,-myTransforms,0);

% computing RR intervals for fetal data
[MOGwaves, MI] = MOG_MODULE_MASK(abs(fetalRT_recon_moco),times_vec, Mask,para.MOG.ncardphases,(indx(end)-1)*TR);


%% CINE RUN
% reconstruction parameter setup
para = setpara(FOV,0, 1, 0, 0, 50, 0.02, 0);

% Calculate caridac phase for each slice according to RWaveTimes from MOG
load('./testdata/test_fetal_data.mat','acq_time_vec');
acq_time_vec = acq_time_vec(:,1:1500);fprintf(2,'remove after test\n')
CP = Calculate_CardiacPhases(acq_time_vec(:), MOGwaves);

% CINE reconstruction starts here
[fetalCardiacCINE] = reconstruction_usc_cine(kspace, traj, dcf, para,CP, myTransforms, MI.post);


%% CLEAR PATHS
restoredefaultpath