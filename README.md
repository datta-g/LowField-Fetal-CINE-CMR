# Low Field Fetal CINE Cardiac MRI
CINE fetal CMR at 0.55T Reconstruction with motion-correction and cardiac gating

# Description
This repository contains code to reconstruct CINE fetal CMR at 0.55T at multiple spatial resolutions. First, real-time images are reconstructed for motion-correction and cardiac gating. Fetal cardiac CINEs are then reconstructed using the corrected data. 

# Citation
Please cite the following paper, if you are using this code:
[1] PLACEHOLDER

# Requirements
The code was been tested on MATLAB R2019b 9.7.0.1296695 Update 4. Some functions are incompatible with older versions. 

# Installation
Download repository manually or by using:
git clone https://github.com/datta-g/Low-Field-Fetal-Cardiac-MRI.git

In MATLAB, run the install.m script. This script will merge and install other required repositories.

# Usage
A brief demo script (fetal_cardiac_demo.m) is provided with sample test data. In this script, real-times are reconstructed. Motion correction and metric optimised gating a re performed. A cine reconstruction is then performed. 
