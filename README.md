# Low Field Fetal CINE Cardiac MRI
CINE fetal CMR at 0.55T Reconstruction with motion-correction and cardiac gating

# Description
This repository contains code to reconstruct CINE fetal CMR at 0.55T at multiple spatial resolutions. First, real-time images are reconstructed for motion-correction and cardiac gating. Fetal cardiac CINEs are then reconstructed using the corrected data. 

# Citation
Please cite the following paper, if you are using this code:
[1] PLACEHOLDER

# Requirements
The code was been tested on MATLAB R2019b 9.7.0.1296695 Update 4. Some functions are incompatible with older versions. 
For MEX-file compilation, a compatible compiler is required (https://www.mathworks.com/support/requirements/supported-compilers.html).

# Installation
In MATLAB, download repository manually or by using:
```sh
 !git clone https://github.com/datta-g/LowField-Fetal-CINE-CMR.git
 cd LowField-Fetal-CINE-CMR
 run install.m
```
All required repositories will be merged and installed.

# Directory Structure

    LowField-Fetal-CINE-CMR/                           Main directory
     │── install.m                                     Installation script
     │── setpath_cine.m                                Path manager for running reconstruction 
     │── fetal_cardiac_demo.m                          Brief demo script to run reconstruction
     │── addons/                                       Main dependencies directory
     │    ├── fetal_cardiac_utilities/                 Fetal specific depedencies
     └── testdata/                                     Directory with data for testing
          ├── test_fetal_data.mat                      Acquired fetal SSFP data


# Usage
A brief demo script (fetal_cardiac_demo.m) is provided with sample test data. In this script, real-times are reconstructed. Motion correction and metric optimised gating a re performed. A cine reconstruction is then performed. 
```sh
 run fetal_cardiac_demo.m
```
