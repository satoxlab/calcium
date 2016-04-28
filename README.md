# calcium
scripts used for preprocessing images of Ca2+ signal during Xenopus neural tube formation. These are associated with Suzuki, M. et al. (submitted).

## Usage
```
perl Ca_imaging_preprocessing.v1.4_short3g.pl path_to_base_dir
```

Under the directory which path is `path_to_base_dir`, there must be following files and directories:
- GFP multitiff file
- R-GECO multitiff file
- a directory containing single tiff files generated from the GFP multitiff
- a directory containing single tiff files generated from the R-GECO multitiff

`Ca_imaging_preprocessing.v1.4_short3g.pl` is basically a script organizing the preprocessing pipeline by invoking other scripts.

