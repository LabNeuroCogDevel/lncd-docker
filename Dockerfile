FROM robex:latest as robex
FROM afni-core:latest as afni
FROM fsl:latest as fsl
FROM neurodebian:latest
ARG GHTOKEN
ENV LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8"
# ENV DEBIAN_FRONTEND noninteractive # unexpected results in run -it ... sh

# create with:
#   docker build -t "preproc:devel" --build-arg GHTOKEN="$(cat github.token):@" . 


# lay off debian servers
# If host is running squid-deb-proxy on port 8000, populate /etc/apt/apt.conf.d/30proxy
RUN {\
  awk '/^[a-z]+[0-9]+\t00000000/ { printf("%d.%d.%d.%d\n", "0x" substr($3, 7, 2), "0x" substr($3, 5, 2), "0x" substr($3, 3, 2), "0x" substr($3, 1, 2)) }' < /proc/net/route > /tmp/host_ip.txt;\
  perl -pe 'use IO::Socket::INET; chomp; $socket = new IO::Socket::INET(PeerHost=>$_,PeerPort=>"8000"); print $socket "HEAD /\n\n"; my $data; $socket->recv($data,1024); exit($data !~ /squid-deb-proxy/)' <  /tmp/host_ip.txt \
  && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) \
  && (echo "Acquire::http::Proxy::neuro.debian.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy) \
  || echo "No squid-deb-proxy detected on docker host"; \
}


# base depends
RUN {\
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update; \
  apt-get -qy --no-install-recommends install \
    r-base bzip2 binutils imagemagick bats curl  libstdc++ \
    git ca-certificates make;\
}

# no more proxy, use neurodebian non-free and contrib
RUN {\
  export DEBIAN_FRONTEND=noninteractive; \
  sed -i 's/main *$/main contrib non-free/g' /etc/apt/sources.list.d/neurodebian.sources.list; \
  test -r  /etc/apt/apt.conf.d/30proxy && mv /etc/apt/apt.conf.d/30proxy /tmp/30proxy;\
  apt-get update; \
}

# big neuro packages
RUN {\
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get -qy --no-install-recommends install \
   python-nipy \
   ants dcm2niix; \
}

# neuro dependencies (fsl, nibable, octave)
RUN {\
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update; \
  apt-get -qy --no-install-recommends install \
    tcsh libnewmat10ldbl libnifti2 bc dc libpng16-16 zlib1g libstdc++6\
    octave liboctave-dev \
    locales python-babel python-future; \
}
## config
# update locale so perl doesn't complain
RUN {\
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen;\
  echo "LANG=en_US.UTF-8" > /etc/locale.conf;\
  locale-gen en_US.UTF-8;\
}

# setup FSLDIR and AFNI, path to Ants and preprocessFunctional
COPY bashrc /etc/environment
COPY bashrc /root/.bashrc  
# .bashrc for root doesn't actually work

# copy in templates
# shuld use mounted volumes -- but we've already got so much junk
# will not work: all files must be in . (symlinks fail)
# COPY standard_templates /opt/ni_tools/

# AFNI -- to avoid X11 depends
COPY --from=afni /root/abin /opt/ni_tools/afni/

# ROBEX
COPY --from=robex /ROBEX /opt/ni_tools/robex/

# FSL
# TODO: limit what comes in. dont need all of it!
COPY --from=fsl /fsl /opt/ni_tools/fsl/

# convert3d
# apt get convert3d brings in wayland!? libdcm8
COPY --from=convert3d /convert3d /opt/ni_tools/c3d/

# get language depends
RUN {\
  cpanp install App::AFNI::SiemensPhysio;\
  PERL_MM_USE_DEFAULT=1 cpan install App::AFNI::SiemensPhysio;\
  Rscript -e 'install.packages("orthopolynom",repos="http://cran.us.r-project.org")';\
}

# Our code
# + BrainWavlet octave setup
RUN {\
  mkdir /data; \
  git clone --depth=1 https://${GHTOKEN}github.com/LabNeuroCogDevel/fmri_processing_scripts.git /opt/ni_tools/fmri_processing_scripts; \
  cd /opt/ni_tools/fmri_processing_scripts/wavelet_despike/linux_windows;\
  octave --eval setup;\
}

# need libcurl?
# Rscript -e 'install.packages("devtools",repos="http://cran.us.r-project.org")';\
# Rscript -e 'devtools::install_github("LabNeuroCogDevel/LNCDR")';\

WORKDIR /data

# 
## clean up
#  # < 150Mb
#  find /opt/ni_tools/afni -iname '*.BRIK*' -or -iname '*HEAD' -or -iname '*.nii.gz' | xargs -r rm
#
# RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  && \
#     test -r /etc/apt/apt.conf.d/30proxy && rm /etc/apt/apt.conf.d/30proxy  || echo no proxy
# 
