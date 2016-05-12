FROM cuda:7.5_cudnn70

MAINTAINER Luiggino Obreque Minio <luiggino.om@gmail.com>

# Link in our build files to the docker image
#ADD src/ /tmp

# Docker no --net=host build command
#CMD "sh" "-c" "echo nameserver 8.8.8.8 > /etc/resolv.conf"

# Create luiggino user, get anaconda by web or locally
#RUN useradd --create-home --home-dir /home/luiggino --shell /bin/bash luiggino
RUN adduser --disabled-password --gecos '' luiggino
RUN adduser luiggino sudo
CMD "sh" "-c" "echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

# all runtime requirements
RUN apt-get update &&\
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        cython \
        gfortran \
        vim \
        protobuf-compiler \
        pypy-dev \
        libopencv-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        libopencv-dev \
        bzip2 \
        libglib2.0-0 \
        libxext6 \
        libsm6 \
        libxrender1 \
        wget \
        ca-certificates \
        git mercurial subversion && \
    apt-get purge -y --auto-remove wget ca-certificates  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Run all python installs
# Perform any cleanup of the install as needed
USER luiggino

ENV PATH=/home/luiggino/anaconda2/bin:$PATH
ENV CONDA_INSTALLER="Anaconda2-4.0.0-Linux-x86_64.sh"

#COPY ${CONDA_INSTALLER} /home/luiggino

# install anaconda3
RUN cd /home/luiggino && \
    RUN wget --quiet https://repo.continuum.io/archive/${CONDA_INSTALLER} && \
    /bin/bash /home/luiggino/${CONDA_INSTALLER} -b && \
    rm ${CONDA_INSTALLER} && \
    conda install --yes conda && \
    conda install conda-build -y  && \
    conda clean --yes --tarballs --packages --source-cache

# Set persistent environment variables for python2
RUN conda create --yes -n opencv numpy scipy scikit-learn matplotlib python=2 anaconda
#RUN conda install scikit-image protobuf yaml --yes

USER root
# Compile OpenBlas
RUN cd /root && \
    git clone -q --branch=master git://github.com/xianyi/OpenBLAS.git && \
    cd OpenBLAS && \
    make FC=gfortran USE_OPENMP=0 NO_AFFINITY=1 NUM_THREADS=$(nproc) && \
    make install PREFIX=/usr/local && \
    cd ~ & \
    rm -rf /root/OpenBLAS && \
    ldconfig
