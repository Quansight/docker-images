#!/bin/bash

if [[ -z "${ABI}" ]]; then
    ABI_WARNING="WARNING: No ABI default set.  Falling back to compatibility mode with GCC 4."
    export ABI=4
fi

# Setup home environment

export PATH=/usr/local/bin:/opt/miniconda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:/opt/miniconda/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=/usr/local/lib64:/usr/local/lib:/opt/miniconda/lib:$LIBRARY_PATH
export INCLUDE=/opt/miniconda/include:$INCLUDE
export CXXFLAGS="${CXXFLAGS} -Wabi=2"

if [ $ABI -lt 5 ]; then
    export CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=0"
else
    export CXXFLAGS="${CXXFLAGS} -D_GLIBCXX_USE_CXX11_ABI=1"
fi

echo "alias clone_recipes='git clone https://github.com/conda/conda-recipes'" >> ~/.bashrc
# Continuum internal build system (private repo, requires on-site or VPN, may require Docker VM restart if network settings change)
echo "alias clone_anaconda='git clone git@github.com:continuumIO/anaconda'" >> ~/.bashrc
echo "alias anaconda_setup='clone_anaconda && cd anaconda && python setup.py develop && cd .. && mkdir aroot'" >> ~/.bashrc

if [[ "$ARCH" -eq "64" || -z "$ARCH" ]]; then
    ARCH_DOC=$'To build 32-bit code, set the ARCH environment
        variable to 32. (-e \"ARCH=32\" docker argument)'
else
    ARCH_DOC=$'Pretending to be i686 (using multilib gcc) and
        filtering uname to output i686.'
    export CFLAGS="${CFLAGS} -m32"
    export CXXFLAGS="${CXXFLAGS} -m32"
    export CONDA_FORCE_32BIT=1
    # this will get picked up by subshells
    sudo mv /bin/uname /bin/uname_x64
    sudo ln -s /opt/share/alias_32bit.sh /bin/uname
    sudo chmod +x /bin/uname
fi

# jumping through hoops for file ownership - we can't have the owner be
#    the native linux owner, and we also can't have permissions too wide open,
#    or ssh complains.
if [ -f /id_rsa ]; then
    mkdir -p .ssh
    sudo cp /id_rsa .ssh/
    chmod 700 .ssh
    sudo chown dev: .ssh/id_rsa
    sudo chmod 600 .ssh/id_rsa
    echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
    echo -e "Host bremen\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
fi

if [[ $# < 1 ]]; then
    # save stdout as file descriptor 3, and redirect stdout to stderr
    exec 3>&1
    exec 1>&2

    # interactive session
    echo "$ABI_WARNING"
    echo
    echo "Welcome to the conda-builder image, brought to you by Continuum Analytics."
    echo
    echo "Binaries produced with this image should be compatible with any Linux OS"
    echo "that is at least CentOS 5 or newer (Glibc lower bound), and anything "
    echo "that uses G++ 5.2 or older (libstdc++ upper bound)"
    echo
    echo "    GCC is: $(gcc --version | head -1)"
    echo "    Default C++ ABI: ${ABI} (C++$([ "${ABI}" == "4" ] && echo "98" || echo "11"))"
    echo "    GLIBC is: $(getconf GNU_LIBC_VERSION)"
    echo "    ld/binutils is: $(ld --version | head -1)"
    echo
    echo "    Native arch is x86_64.  ${ARCH_DOC}"
    echo
    echo "    The dev user (currently signed in) has passwordless sudo access."
    echo "    miniconda (2.7) is installed at /opt/miniconda."
    echo "    git is also available."

    if [ -f "/home/dev/.gitconfig" ]; then
        echo "    Your .gitconfig has been imported."
    fi

    if [ -f /id_rsa ]; then
        echo "    Your ssh private key has been imported for passwordless ssh."
    fi

    echo

    echo "Helpful aliases:"
    echo "    clone_recipes: clones the conda/conda-recipes repo from Github"
    echo "    clone_anaconda: clones the continuumIO/anaconda (private) repo from Github"
    echo "    anaconda_setup: clones anaconda repo and sets up continuum internal build system."

    echo

    # restore stdout
    exec 1>&3

    exec bash
else
    # Run whatever the user wants to pass in
    exec "$@"
fi
