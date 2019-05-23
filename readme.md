# lncd-docker
attempt to dockerize `fmri_preprocess_functional` while limiting unnessary package dependiencies

N.B. Look to [neurodocker](https://github.com/kaczmarj/neurodocker) for better implementation of dockerized neuroimaging tools.

## Usage

```
# mount standard templates and current data (to data) and run preprocessFunctional
docker run -v ~/standard:/root/standard -v ./:/data preproc:devel preprocessFunctional
```

## Complications
 * `standard_templates` are not included with the docker file. currently need `-v /opt/ni_tools/standard:/root/standard`. 
 * python, R, and octave bring in X11?
 * FSL is huge, can prune `extras` folder?
 * `Dockerfile.*` could be included within main `Dockerfile`, but useful to separate for debug -- use `make` (see [Makefile](./master/Makefile))
 * <s>BrainWavlet uses matlab. Hard to dockerize. Consider including MATLAB runtime?</s> BrainWavlet can use octave, modifcations in `fmri_processing_scripts`

## Included Tools and Resources; Citations

* [AFNI](https://afni.nimh.nih.gov/)
  > [https://doi.org/10.1002/(SICI)1099-1492(199706/08)10:4/5<171::AID-NBM453>3.0.CO;2-L)](https://doi.org/10.1002/(SICI)1099-1492(199706/08)10:4/5<171::AID-NBM453>3.0.CO;2-L)
* [ANTs](http://stnava.github.io/ANTs/)
  > https://dx.doi.org/10.3389%2Ffninf.2014.00044
* [BrainWavelet Toolbox](http://www.brainwavelet.org/downloads/brainwavelet-toolbox/)
  > http://dx.doi.org/10.1016/j.neuroimage.2014.03.012
* [Convert3D](http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Convert3D)
  > 
* [FSL](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/)
  > http://dx.doi.org/10.1016/j.neuroimage.2011.09.015
* [MNI 09c](http://www.bic.mni.mcgill.ca/ServicesAtlases/ICBM152NLin2009)
  > http://dx.doi.org/10.1016/S1053-8119(09)70884-5
* [nipy](https://nipype.readthedocs.io/en/latest/) (`4dSliceMotion`)
  > https://doi.org/10.5281/zenodo.581704
* [ROBEX](https://www.nitrc.org/projects/robex)
  > https://doi.org/10.1109/TMI.2011.2138152

## Building
 * use `make`, see [`Makefile`](./Makefile?raw=True)
 * need a github token to acess private repo. token should be the only line in `github.token`
