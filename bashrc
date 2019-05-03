export LC_ALL=en_US.UTF-8
nt=/opt/ni_tools
export FSLDIR=$nt/fsl
export PATH="$nt/fmri_processing_scripts:$nt/afni:$nt/fsl/bin:$nt/robex:$nt/fmri_processing_scripts:$nt/c3d/bin:/usr/lib/ants:$PATH"
source $FSLDIR/etc/fslconf/fsl.sh

export AFNI_COMPRESSOR="GZIP"

