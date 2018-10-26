# lncd-docker
attempt to dockerize `fmri_preprocess_functional` without X11 or unnessary fsl components

## Included Tools/Citations

* [AFNI](https://afni.nimh.nih.gov/)
  > https://doi.org/10.1002/(SICI)1099-1492(199706/08)10:4/5<171::AID-NBM453>3.0.CO;2-L
* [ANTs](http://stnava.github.io/ANTs/)
  > 
* [BrainWavelet Toolbox](http://www.brainwavelet.org/downloads/brainwavelet-toolbox/)
  > http://dx.doi.org/10.1016/j.neuroimage.2014.03.012
* [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)
  > http://dx.doi.org/10.1016/j.neuroimage.2011.09.015
* [nipy](https://nipype.readthedocs.io/en/latest/) (`4dSliceMotion`)
  > https://doi.org/10.5281/zenodo.581704
* [ROBEX](https://www.nitrc.org/projects/robex)
  > https://doi.org/10.1109/TMI.2011.2138152

## Building
 * use `make`, see [`Makefile`](./Makefile?raw=True)
 * need a github token to acess private repo. token should be the only line in `github.token`
