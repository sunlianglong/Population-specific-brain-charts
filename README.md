# Population-specific-brain-charts
Population-specific brain charts reveal Chinese-Western differences in neurodevelopmental trajectories

E-mail: lianglongsun@mail.bnu.edu.cn

This repository provides code and source data that support the findings of the article entitled "XXXXXXXXXXXXXXXX".


### Data 
- Growth_curve_global_mean_of_FC.mat
  - The lifespan normative growth curve of the global mean of functional connectome
- Growth_curve_global_variance_of_FC.mat
  - The lifespan normative growth curve of the global variance of functional connectome
- Growth_curve_global_atlas_similarity.mat
  - The lifespan normative growth curve of the global atlas similarity (individual level)
- Growth_curve_global_system_segregation.mat
  - The lifespan normative growth curve of the global system segregation
- Growth_curve_VIS_system_segregation.mat
  - The lifespan normative growth curve of the system segregation of VIS network
- Growth_curve_SM_system_segregation.mat
  - The lifespan normative growth curve of the system segregation of SM network
- Growth_curve_DA_system_segregation.mat
  - The lifespan normative growth curve of the system segregation of DA network
- Growth_curve_VA_system_segregation.mat
  - The lifespan normative growth curve of the system segregation of VA network
- Growth_curve_LIM_system_segregation.mat
  - The lifespan normative growth curve of the system segregation of LIM network
- Growth_curve_FP_system_segregation.mat
  - The lifespan normative growth curve of the system segregation of FP network
- Growth_curve_DM_system_segregation.mat
  - The lifespan normative growth curve of the system segregation of DM network


### Code
#### Quality control for raw images
- MRIQC v0.15.0 (https://github.com/nipreps/mriqc)
#### Data processing
- QuNex v0.93.2 (https://gitlab.qunex.yale.edu/)
- HCP pipeline v4.4.0-rc-MOD-e7a6af9 (https://github.com/Washington-University/HCPpipelines/releases)
- Freesurfer v6.0.0 (https://surfer.nmr.mgh.harvard.edu/)
- dHCP structural pipeline v1 (https://github.com/BioMedIA/dhcp-structural-pipeline)
- iBEAT pipeline v1.0.0 (https://github.com/iBEAT-V2/iBEAT-V2.0-Docker)
#### for-Normative-Modeling
- XXXXXXXXXXXXXX
  - R function for GAMLSS model specification and estimation
  - R v4.2.0 (https://www.r-project.org)
  - GAMLSS package v5.4-3 (https://www.gamlss.com/)

#### for-Visualization
- plot_1_Normative_Growth_Curve.m
  - Plot the normative growth curve
- plot_2_Normative_Growth_Rate.m
  - Plot the growth rate
- plot_3_Normative_Growth_Curve_female_male.m
  - Plot the normative growth curve for famale and male
- R v4.2.0 (https://www.r-project.org)
- ggplot2 package v3.4.2 (https://ggplot2.tidyverse.org/)
