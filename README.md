# calcium
Scripts used for preprocessing images of Ca2+ signal during Xenopus neural tube formation. These are associated with Suzuki, M. et al. (submitted).

## Usage
```
perl Ca_imaging_preprocessing.v1.4_short3g.pl path_to_base_dir
```
`Ca_imaging_preprocessing.v1.4_short3g.pl` is basically a script organizing the preprocessing pipeline with other scripts.

Under the directory which path is `path_to_base_dir`, there must be following files and directories:
- GFP multitiff file
- R-GECO multitiff file
- a directory containing single tiff files generated from the GFP multitiff
- a directory containing single tiff files generated from the R-GECO multitiff

__Note__ that strings used in pattern matching such as w0000 are set for our file naming convensions. Change the strings for other file naming convensions.

## Input files/directories
- GFP multitiff file
- R-GECO multitiff file
- a directory containing single tiff files generated from the GFP multitiff
- a directory containing single tiff files generated from the R-GECO multitiff

## Output file
- Normalized R-GECO image file (.tiff)(from `R-GECO_local_normalization_g.R`)

