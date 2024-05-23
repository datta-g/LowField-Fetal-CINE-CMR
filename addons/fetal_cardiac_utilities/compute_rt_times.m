function frametimes = compute_rt_times(acq_time_vec, para, nframes)

[times_vec,~] = CINE_Tool_RT_Sort(acq_time_vec,acq_time_vec,para.Recon.narm,para.Recon.overlaparm);
frametimes = mean(squeeze(times_vec));
frametimes = frametimes(1:nframes);

