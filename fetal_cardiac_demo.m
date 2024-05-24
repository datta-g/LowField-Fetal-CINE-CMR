% NAME :  
%           fetal_cardiac_demo
% 
% DESCRIPTION:
%           This script sets runs a brief demo CINE reconstruction of 
%           low field fetal spiral SSFP acquisition
% INPUTS:
%           - 
%
% OUTPUTS:
%           reconstructed CINE in fetalCardiacCINE
%           
% NOTES:
%           
%
% Datta Singh Goolaub, 2024
% datta.goolaub@sickkids.ca
% SickKids, Translational Medicine

%% path modification
setpath_cine;
clear; clc;

%% RAW DATA LOAD
% load test data: kspace + traj + dcf
% kspace        acquired raw data [readout arms coil]
% traj          trajectory [kspace-position arms]
% dcf           density compensation factor
% TR            repetition time [ms]
% FOV           struct containing recon FOV specs
% acq_time_vec  timestamp for acquistion [ms]
% Mask          region of interest for fetal heart
load('./testdata/test_fetal_data.mat')

%% REAL TIME RUN
% reconstruction parameter setup
para = setpara(FOV,1, 0, 15, 10, 20, 0.08, 0);

% real-time reconstruction
fetalRT_recon = reconstruction_usc(kspace, traj, dcf, para);


%% MOG + MOCO RUN
% computing real-time timestamps
frametimes = compute_rt_times(acq_time_vec, para, size(fetalRT_recon,3));

% motion correction
[myTransforms] = MOCO_MODULE_MASK(fetalRT_recon,frametimes, Mask, 0);

% motion correction applied to real-time
fetalRT_recon_moco = CINE_Tool_Correct_RT(fetalRT_recon,-myTransforms,0);

% computing RR intervals for fetal data
[MOGwaves, MI] = MOG_MODULE_MASK(abs(fetalRT_recon_moco),frametimes, Mask,para.MOG.ncardphases,frametimes(end));


%% CINE RUN
% reconstruction parameter setup
para = setpara(FOV,0, 1, 0, 0, 50, 0.02, 0);

% Calculate caridac phase for each slice according to RWaveTimes from MOG
CP = Calculate_CardiacPhases(acq_time_vec(:), MOGwaves);

% CINE reconstruction starts here
[fetalCardiacCINE] = reconstruction_usc_cine(kspace, traj, dcf, para,CP, myTransforms, MI.post);


%% CLEAR PATHS
restoredefaultpath