FROM centos:7
MAINTAINER Ivan Ogasawara <ivan.ogasawara@gmail.com>

# install_yum_deps.sh
RUN yum install -y curl.x86_64 bzip2.x86_64 yum-utils glibc-devel patch \
    unzip bison yasm file make libtool.x86_64 pkgconfig.x86_64

# yum_install_syslibs.sh
RUN yum install -y glib2-devel libX11-devel libXext-devel libXrender-devel  \
    mesa-libGL-devel libICE-devel libSM-devel ncurses-devel \
    openssh-clients.x86_64 patch.x86_64 dbus-devel gtk2-devel \
    chrpath.x86_64 nano bzip2 xz sudo curl

# Install java
RUN yum install -y java-1.7.0-openjdk java-1.7.0-openjdk-devel libgcj ant && \
    yum clean all

# Install miniconda
WORKDIR /build_scripts
COPY build/install_miniconda.sh \
     /build_scripts/

RUN bash install_miniconda.sh

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

RUN /opt/miniconda/bin/conda install -y conda-build

# install devtoolsets
RUN yum update -y && \
    yum install -y \
       centos-release-scl \
       scl-utils-build \
       devtoolset-2-gcc* \
       devtoolset-3-gcc* \
       devtoolset-4-gcc* \
       devtoolset-6-gcc* && \
    yum clean all

RUN echo 'anaconda_upload: True' > /home/dev/.condarc && \
    echo 'channels:' >> /home/dev/.condarc && \
    echo '  - defaults' >> /home/dev/.condarc && \
    echo '  - conda-forge' >> /home/dev/.condarc && \
    echo '  - quansight' >> /home/dev/.condarc

RUN echo 'conda build --user quansight pkg' > /home/dev/.bash_history

RUN echo 'scl enable devtoolset-4 bash' >> /home/dev/.bash_history

WORKDIR /home/dev/code
USER dev
