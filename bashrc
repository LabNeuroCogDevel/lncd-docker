nt=/opt/ni_tools
export FSLDIR=$nt/fsl
export PATH="$nt/afni:$nt/fsl/bin:$nt/robex:$nt/fmri_processing_scripts:$nt/c3d/bin:$PATH"
source $FSLDIR/etc/fslconf/fsl.sh

export AFNI_COMPRESSOR="GZIP"

