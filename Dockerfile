# Use a base image with build tools
FROM debian:stable-slim as build

ARG ZLIB_URL=https://www.zlib.net/fossils/zlib-1.2.13.tar.gz
ARG HDF5_URL=https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.14/hdf5-1.14.0/src/hdf5-1.14.0.tar.gz
ARG NETCDF_URL=https://downloads.unidata.ucar.edu/netcdf-c/4.9.2/netcdf-c-4.9.2.tar.gz
ARG JASPER_URL=http://www.ece.uvic.ca/~frodo/jasper/software/jasper-1.900.1.zip
ARG ECCODES_URL=https://confluence.ecmwf.int/download/attachments/45757960/eccodes-2.20.0-Source.tar.gz
ARG CDO_URL=https://code.mpimet.mpg.de/attachments/download/24638/cdo-1.9.10.tar.gz


# Set environment variable
ENV home=/opt/cdo-install

# Install necessary packages
RUN apt update

RUN apt install -y wget build-essential checkinstall unzip m4 curl libcurl4-gnutls-dev libxml2-dev cmake gfortran libjpeg-dev libpng-dev libaec-dev libcurl4-gnutls-dev libssl-dev

# Create the installation directory
RUN mkdir -p ${home}

# zlib
WORKDIR ${home}
RUN wget ${ZLIB_URL} -O zlib.tar.gz && \
    tar -xzvf zlib.tar.gz && \
    cd zlib-* && \
    ./configure --prefix=${home} && \
    make && make check && make install

# hdf5
WORKDIR ${home}
RUN wget ${HDF5_URL} -O hdf5.tar.gz && \
    tar -xzvf hdf5.tar.gz && \
    cd hdf5-* && \
    ./configure --with-zlib=${home} --prefix=${home} CFLAGS=-fPIC && \
    make && make check && make install

# netCDF
WORKDIR ${home}
RUN wget ${NETCDF_URL} -O netcdf.tar.gz && \
    tar -xzvf netcdf.tar.gz && \
    cd netcdf-* && \
    CPPFLAGS=-I${home}/include LDFLAGS=-L${home}/lib ./configure --prefix=${home} CFLAGS=-fPIC && \
    make && make check && make install

# jasper
WORKDIR ${home}
RUN wget ${JASPER_URL} -O jasper.zip && \
    unzip jasper.zip && \
    cd jasper-* && \
    ./configure --prefix=${home} CFLAGS=-fPIC && \
    make && make check && make install

# eccodes
WORKDIR ${home}
RUN wget ${ECCODES_URL} -O eccodes.tar.gz && \
    tar -xzvf eccodes.tar.gz && \
    mv eccodes-* eccodes && \
    cd eccodes && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=${home} -DENABLE_NETCDF=ON -DENABLE_JPEG=ON -DENABLE_PYTHON=OFF && \
    make && ctest && make install

# cdo
WORKDIR ${home}
RUN wget ${CDO_URL} -O cdo.tar.gz && \
    tar -xvzf cdo.tar.gz && \
    cd cdo-* && \
    ./configure --prefix=${home} CFLAGS=-fPIC --with-netcdf=${home} --with-jasper=${home} --with-hdf5=${home} --with-eccodes=${home}/eccodes && \
    make && make install

WORKDIR ${home}


# Create a new image based on a minimal image
FROM debian:stable-slim as minimal

# Install the necessary packages
RUN apt-get update && apt-get install -y libcurl4-gnutls-dev libxml2-dev libgomp1

# Copy the installation from the build image
COPY --from=build /opt/cdo-install /opt/cdo-install

# Set the environment variable
ENV PATH="/opt/cdo-install/bin:${PATH}"

# Set the working directory
WORKDIR /data

# Set the entrypoint
ENTRYPOINT ["cdo"]