# Lifespan Brain Charts from the Chinese Population

E-mail: lianglongsun@mail.bnu.edu.cn

This repository provides code and source data that support the findings of the article entitled "Population-specific brain charts reveal Chinese-Western differences in neurodevelopmental trajectories" by Sun et al.


### Code
#### 1. Quality control
Details regarding the quality control procedures can be found in our previous publication: [Sun et al., 2025](https://www.nature.com/articles/s41593-025-01907-4) <sup>[1]</sup>.
- Quality control for raw images: MRIQC v0.15.0 <sup>[2]</sup> (https://github.com/nipreps/mriqc) 
- The tutorial of visual-check quality control: https://github.com/sunlianglong/BrainChart-FC-Lifespan/tree/main/QC
#### 2. Data processing
- QuNex v0.93.2 <sup>[3]</sup> (https://gitlab.qunex.yale.edu/)
- HCP pipeline v4.4.0-rc-MOD-e7a6af9 <sup>[4]</sup> (https://github.com/Washington-University/HCPpipelines/releases)
- Freesurfer v6.0.0 <sup>[5]</sup> (https://surfer.nmr.mgh.harvard.edu/)
- dHCP structural pipeline v1 <sup>[6]</sup> (https://github.com/BioMedIA/dhcp-structural-pipeline)
- iBEAT pipeline v1.0.0 <sup>[7]</sup> (https://github.com/iBEAT-V2/iBEAT-V2.0-Docker)
#### 3. Normative Modeling
> Betlehem et al. <sup>[8]</sup> provided a robust GAMLSS framework for modeling lifespan trajectories of the human brain. The brain chart modeling component in our work was adapted from this framework. We gratefully acknowledge the contributions of Betlehem et al. for their efforts in developing this framework.
  - R function for GAMLSS model specification and estimation
  - R v4.2.0 (https://www.r-project.org)
  - GAMLSS package v5.4-3 (https://www.gamlss.com/)
  - Brain chart modelling framework (https://github.com/brainchart/Lifespan)
#### 4. Visualization
- R v4.2.0 (https://www.r-project.org)
- ggplot2 package v3.4.2 (https://ggplot2.tidyverse.org/)
- Figure-Plot_Data_distribution.r
  - Plots the uncorrected raw data distribution across 0–100 years.
- Figure-Plot_Growth-Curve_and_Growth-Rate.r
  - Visualizes the lifespan growth trajectories and corresponding rates across ages 0–100 years.
- Figure-Plot_Boot.r
  - Illustrates the confidence intervals of the lifespan growth trajectories and rates across ages 0–100 years.
- Figure-Plot_DK_atlas.r
  - Displays the data distribution mapped onto the Desikan-Killiany (DK) atlas.
- Figure-Plot_Subcortical_Atlas.r
  - Displays the data distribution mapped onto the subcortical atlas.

### Data 
- Model
  - Contains the fitted brain chart models for all 296 structural phenotypes.
- Model_BOOT
  - Contains the models generated via bootstrapping. For each phenotype, 1,000 bootstrap-sampled models were fitted.


#### Reference
[1] Sun, L., et al. Human lifespan changes in the brain’s functional connectome. *Nat Neurosci* **28**, 891–901 (2025).

[2] Esteban, O., et al. MRIQC: Advancing the automatic prediction of image quality in MRI from unseen sites. *PLoS One* **12**, e0184661 (2017).

[3] Ji, J.L., et al. QuNex—An integrative platform for reproducible neuroimaging analytics. *Frontiers in Neuroinformatics* **17** (2023).

[4] Glasser, M.F., et al. The minimal preprocessing pipelines for the Human Connectome Project. *Neuroimage* **80**, 105-124 (2013).

[5] Dale, A.M., Fischl, B., Sereno, M.I. Cortical surface-based analysis. I. Segmentation and surface reconstruction. *Neuroimage* **9**, 179-194 (1999).

[6] Makropoulos, A., et al. The developing human connectome project: A minimal processing pipeline for neonatal cortical surface reconstruction. *Neuroimage* **173**, 88-112 (2018).

[7] Wang, L., et al. iBEAT V2.0: a multisite-applicable, deep learning-based pipeline for infant cerebral cortical surface reconstruction. *Nat Protoc* **18**, 1488-1509 (2023).

[8] Bethlehem, R.A.I., et al. Brain charts for the human lifespan. *Nature* **604**, 525-533 (2022).











