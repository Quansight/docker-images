FROM centos:6
# MAINTAINER Michael Sarahan <msarahan@continuum.io>
MAINTAINER Ivan Ogasawara <ivan.ogasawara@gmail.com>

WORKDIR /build_scripts

# install_yum_deps.sh
RUN yum install -y curl.x86_64 bzip2.x86_64 yum-utils glibc-devel patch \
    unzip bison yasm file make libtool.x86_64 pkgconfig.x86_64

# COPY build_gcc.sh yum_cleanup.sh symlink_libraries.sh /build_scripts/
COPY yum_cleanup.sh symlink_libraries.sh /build_scripts/

# RUN yum install -y centos-release-SCL devtoolset-2
RUN yum install -y centos-release-SCL

# Install devtoolset 2.
RUN yum update -y && \
    yum install -y \
       centos-release-scl \
       yum-utils

RUN yum-config-manager --add-repo http://people.centos.org/tru/devtools-2/devtools-2.repo

RUN yum update -y && \
    yum install -y \
       devtoolset-2-binutils \
       devtoolset-2-gcc \
       devtoolset-2-gcc-c++ && \
    yum clean all

# RUN curl http://linuxsoft.cern.ch/cern/devtoolset/slc5-devtoolset.repo -o /etc/yum.repos.d/slc5-devtoolset.repo
# RUN rpm --import http://ftp.mirrorservice.org/sites/ftp.scientificlinux.org/linux/scientific/obsolete/51/i386/RPM-GPG-KEYs/RPM-GPG-KEY-cern

# COPY build_gcc.sh /build_scripts/

# RUN bash build_gcc.sh
RUN bash yum_cleanup.sh && \
    bash symlink_libraries.sh && \
    rm -rf /build_scripts

# from continuumio/centos5_gcc5_base:5.11-5.2-1
# MAINTAINER Michael Sarahan <msarahan@continuum.io>

# Install latex
RUN yum install -y texlive && \
    yum clean all

# Install java
RUN yum install -y java-1.7.0-openjdk java-1.7.0-openjdk-devel libgcj ant && \
    yum clean all

WORKDIR /build_scripts
COPY build/yum_install_syslibs.sh \
     build/install_miniconda.sh \
     build/yum_cleanup.sh \
     /build_scripts/

RUN bash yum_install_syslibs.sh
RUN bash install_miniconda.sh
RUN bash yum_cleanup.sh

RUN rm -rf /build_scripts && \
    mkdir -p /opt/share && \
    mkdir -p /opt/miniconda/conda-bld/work/linux-64 && \
    mkdir -p /opt/miniconda/conda-bld/work/linux-32 && \
    mkdir -p /opt/miniconda/conda-bld/work/noarch && \
    chmod -R 777 /opt && \
    useradd -m --uid 1000 -G wheel dev && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'Defaults:%wheel !requiretty' >> /etc/sudoers

ADD build/internal_startup.sh /opt/share/internal_startup.sh
ADD build/alias_32bit.sh /opt/share/alias_32bit.sh

# MANTAINER Ivan Ogasawara <ivan.ogasawara@gmail.com>

RUN yum update -y && \
    yum install -y \
       gcc-gfortran \
       gcc-c++ && \
    yum clean all

RUN yum update -y && \
    yum install -y \
       devtoolset-3-gcc* \
    yum clean all

RUN yum update -y && \
    yum install -y devtoolset-4-gcc* && \
    yum clean all

RUN echo 'anaconda_upload: True' > /home/dev/.condarc && \
    echo 'channels:' >> /home/dev/.condarc && \
    echo '  - defaults' >> /home/dev/.condarc && \
    echo '  - conda-forge' >> /home/dev/.condarc

RUN echo 'conda build --user quansight pkg' > /home/dev/.bash_history

RUN echo 'scl enable devtoolset-4 bash' >> /home/dev/.bash_history

WORKDIR /home/dev/code
USER dev
