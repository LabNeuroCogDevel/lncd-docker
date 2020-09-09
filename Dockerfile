FROM lncd/nimin

WORKDIR /data
ENV NT="/opt/ni_tools"
ENV PATH="$NT/fmri_processing_scripts:$NT/fsl/bin:$NT/afni:$NT/robex:$NT/c3d/bin:/usr/lib/ants:$PATH"
# source ${FSLDIR}/etc/fslconf/fsl.sh
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV FSLDIR=/opt/ni_tools/fsl

# Our code
# + BrainWavlet octave setup
RUN {\
  mkdir /data; \
  git clone --depth=1 https://github.com/LabNeuroCogDevel/fmri_processing_scripts.git /opt/ni_tools/fmri_processing_scripts; \
  cd /opt/ni_tools/fmri_processing_scripts/wavelet_despike/linux_windows;\
  octave --eval setup;\
}

# reduce size of fsl and afni
# remove extras and all binaries not explictly called by preprocess scripts
# must come after getting preprocess scripts (used to find what to remove)
#
# RUN {\
#  rm -r /opt/ni_tools/fsl/data /opt/ni_tools/fsl/extras /opt/ni_tools/fsl/doc;\
#  find /opt/ni_tools/fmri_processing_scripts/ -not -ipath '*wavelet*' -not -name '*cfg' -not -name '.*' -not -ipath '*.git*' -not -name '*.nii.gz' -type f| \
#     xargs perl -pe 's/[^\w.]+/\n/g' |\
#     sort -u > /tmp/ppwords;\
#  lsbin() { find $1 -maxdepth 1 -type f -size +50k \
#                    -not -name '*.so*' -not -iname '*.a' |\
#           egrep -v 'imtest|remove_ext|fslval|fslhd|avscale|fslswapdim|tmpnam' |\
#           sed s:.*/::|sort -u; } ;\
#  rm_unused() { lsbin $1 | comm -13 /tmp/ppwords - | sed "s:^:$1/:" | xargs -r rm ; } ;\
#  rm_unused /opt/ni_tools/fsl/bin; \
#  rm_unused /opt/ni_tools/afni;\
#  rm /tmp/ppwords;\
#  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ;\ 
# }

# need libcurl?
# Rscript -e 'install.packages("devtools",repos="http://cran.us.r-project.org")';\
# Rscript -e 'devtools::install_github("LabNeuroCogDevel/LNCDR")';\

# 
## clean up
#  # < 150Mb
#  find /opt/ni_tools/afni -iname '*.BRIK*' -or -iname '*HEAD' -or -iname '*.nii.gz' | xargs -r rm
#
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  && \
#     test -r /etc/apt/apt.conf.d/30proxy && rm /etc/apt/apt.conf.d/30proxy  || echo no proxy
# 
