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
    git ca-certificates;\
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

# AFNI -- to avoid X11 depends
COPY --from=afni /root/abin /opt/ni_tools/afni/

# ROBEX
COPY --from=robex /ROBEX /opt/ni_tools/robex/

# FSL
COPY --from=fsl /fsl /opt/ni_tools/fsl/

# neuro dependencies (fsl)
RUN {\
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get -qy --no-install-recommends install \
    tcsh libnewmat10ldbl libnifti2 bc dc libpng16-16 zlib1g libstdc++6;\
}

# clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*  && \
    test -r /etc/apt/apt.conf.d/30proxy && rm /etc/apt/apt.conf.d/30proxy  || echo no proxy


# Our code
RUN {\
  git clone --depth=1 https://${GHTOKEN}github.com/LabNeuroCogDevel/fmri_processing_scripts.git /opt/ni_tools/fmri_processing_scripts; \
}
