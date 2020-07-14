#!/bin/bash
# These are all of the packages that need to be installed before bootstrap
# is run
# 
# Note that all apache modules should have already been installed
# in the bootstrap image.  Otherwise you will have the system attempt
# to reload httpd which causes the httpd connection to go down
#
# dokuwiki also needs to be in bootstrap for the same reasons
set -e -v

cat <<EOF >> $rootfsDir/etc/dnf/dnf.conf
fastestmirror=true
max_parallel_downloads=15
EOF
if [ -e $rootfsDir/tmp/proxy.sh ]; then
    source $rootfsDir/tmp/proxy.sh
fi

dnf makecache $rootfsArg
dnf upgrade --best --nodocs --allowerasing --refresh -y \
    --setopt=install_weak_deps=False $rootfsArg

# workaround bug RHEL #1765718
dnf autoremove python3-dnf-plugins-core -y $rootfsArg

# Refresh locale and glibc for missing latin items
# needed for R to build packages
dnf reinstall -v -y --setopt=install_weak_deps=False --best --nodocs --allowerasing \
    locales locales-en glibc $rootfsArg

#repeat packages in setup
dnf --setopt=install_weak_deps=False --best --allowerasing install -v -y --nodocs $rootfsArg \
      apache \
      apache-mod_proxy \
      php-fpm \
      apache-mod_authnz_external \
      apache-mod_ssl \
      dokuwiki \
      dokuwiki-plugin-auth \
      dokuwiki-plugin-dokufreaks \
      dokuwiki-plugin-s5  \
      python3-flask \
      python3-pexpect \
      python3-matplotlib \
      webmin \
      sudo \
      git \
      R-base \
      nodejs \
      npm \
      octave \
      redis \
      unzip \
      mongodb-server \
      mongodb \
      mongo-tools \
      bitcoind \
      java \
      texlive \
      vim-minimal \
      ruby-sass \
      zeromq-utils \
      python3-pip \
      python3-cffi \
      python3-cython \
      python3-pexpect \
      R-Rcpp-devel \
      root \
      python3-jupyroot \
      root-r \
      libglu-devel \
      rclone \
      root-physics \
      root-geom \
      root-fftw \
      root-hist \
      root-foam \
      root-vecops \
      root-graf \
      root-graf-asimage \
      root-graf-gpad \
      root-graf-gpadv7 \
      root-graf-gviz \
      root-graf-postscript \
      root-graf-primitives \
      root-graf3d \
      root-geom \
      root-gui \
      root-hist \
      root-mathcore \
      root-mathmore \
      root-matrix \
      root-minuit \
      root-multiproc \
      root-graf-postscript \
      root-graf-asimage \
      fuse \
      parallel \
      gcc-c++

chmod a+x $rootfsDir/usr/lib64/R/bin/*
dnf clean all $rootfsArg
rm -rf $rootfsDir/var/log/*.log
rm -rf $rootfsDir/usr/share/gems/doc/*
rm -rf $rootfsDir/usr/lib/python3.5
rm -rf $rootfsDir/usr/lib64/python3.5

pushd $rootfsDir/etc/httpd/conf
rm -f conf.d/security.conf
cp $rootfsDir/tmp/00_mpm.conf modules.d
if [ -e modules.d/00-php-fpm.conf ] ; then
    mv modules.d/00-php-fpm.conf modules.d/10-php-fpm.conf
fi
popd

if grep -q '^7 ' /etc/version
then export RDKAFKA=
else  export RDKAFKA=librdkafka-devel
fi


dnf --setopt=install_weak_deps=False --best install -v -y \
    --nodocs --allowerasing $rootfsArg \
      make \
      r-quantlib \
      pkgconfig\(libczmq\) \
      zeromq-devel \
      giflib-devel \
      cmake \
      python3-tornado \
      python3-mglob \
      python3-pytz \
      python3-devel \
      readline-devel \
      lapack-devel \
      python3-pandas \
      python3-pandas-datareader \
      python3-numpy \
      python3-numpy-devel \
      python3-tables \
      python3-fs \
      python3-scipy \
      python3-qstk \
      python3-scikits-learn \
      python3-rpy2 \
      python3-xlwt \
      python3-xlrd \
      python3-gevent \
      python3-sqlalchemy \
      python3-sympy \
      python3-pillow \
      python3-lxml \
      python3-mistune \
      python3-cryptography \
      python3-pyasn1 \
      python3-pyglet \
      python3-py4j \
      python3-mysql \
      python3-wheel \
      curl-devel \
      icu-devel \
      libpcre-devel \
      liblzma-devel \
      libbzip2-devel \
      zeromq-devel \
      ta-lib-devel \
      libxml2-devel \
      make \
      python3-cairo-devel \
      jpeg-devel \
      java-devel \
      openmpi-devel \
      libssh2-devel \
      ruby-devel \
      libtool \
      automake \
      autoconf \
      swig \
      protobuf-devel \
      unwind-devel \
      graphviz-devel \
      glpk-devel \
      glpk \
      llvm-devel \
      llvm \
      $RDKAFKA \
      libumfpack-devel \
      hdf5-devel \
      libxt-devel \
      libmagick-devel \
      cargo \
      lib64git2-devel \
      pybind11-devel \
      gzip \
      ncurses \
      nss \
      nspr \
      passwd \
      tar \
      xeus-devel \
      xtl-devel \
      'pkgconfig(Magick++)' \
      spack \
      spack-repos \
      distcc \
      distcc-server

# xeus-devel for r juniper

# nss/nspr to prevent poppler from pulling in firefox
# cargo for gifski
# libxt-devel for R cairo
# libmagick-devel for R magick
# git-devel for git2r
# pybind11 for onnx

# glpk for swiglpk
# llvm-devel for pyfolio
# kafka for tributary?
#      python3-quantlib
# ruby-sass for ethercalc
#zeromq-devel for R kernel
#libxml2-devel for RCurl
#unzip for R devtool builds
#cffi for caravel
#cairo for jupyterlab_bokeh.git or jpeg-devel
# llvm for numba
# openmpi-devel for horvod
# libssh2-devel for git2r ssh transport

#cmake is for building shiny-server
#tornado and mglob is for ipython
#readline-devel, python-devel, lapack-devel are for Rpy
# python-backports-ssl_match_hostname is a require of python-urllib3 which
#    is required by cloud-init

# For ipython we including 
# python-pandas
# python-tables
# python-scipy

# python-mistune is needed by jupyter-nbconvert but the autorequires
# seems broken

# curl-devel is needed for Rcurl
# icu-i18n-devel is needed for Rpy

#python-cythong is for Finance-Python

#gcc-c++ is needed for ethercalc
#make is needed for ethercalc

# Compression libraries needed for Rpy

# sox to play sounds for algobroker
# pillow is for toyplot
# lxml for matta
# zeromq-utils are necessary for IRkernel
# pyasn1 for jupyter extensions
