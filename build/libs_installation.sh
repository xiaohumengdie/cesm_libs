#!/usr/bin/env bash

#
# Sources for all libraries used in this script can be found at
# http://www2.mmm.ucar.edu/people/duda/files/mpas/sources/ 
#

# Where to find sources for libraries
export LIBSRC=/home/cesm01/software/coawst/iolib_installation/sources

# Where to install libraries
export LIBBASE=/home/cesm01/software/coawst/iolib_installation/libs-intel2017

# Compilers
export SERIAL_FC=mpiifort
export SERIAL_F77=mpiifort
export SERIAL_CC=mpiicc
export SERIAL_CXX=mpiicpc
export MPI_FC=mpiifort
export MPI_F77=mpiifort
export MPI_CC=mpiicc
export MPI_CXX=mpiicpc


export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
#unset F90  # This seems to be set by default on NCAR's Cheyenne and is problematic
#unset F90FLAGS
export CFLAGS="-g -O2"
export FFLAGS="-g -O2"
export FCFLAGS="-g -O2"
export F77FLAGS="-g -O2"


########################################
# MPICH
########################################
#tar xzvf ${LIBSRC}/mpich-3.3.1.tar.gz 
#cd mpich-3.3.1
#./configure --prefix=${LIBBASE}
#make -j 4
##make check
#make install
##make testing
#export PATH=${LIBBASE}/bin:$PATH
#export LD_LIBRARY_PATH=${LIBBASE}/lib:$LD_LIBRARY_PATH
#cd ..
#rm -rf mpich-3.3.1

########################################
# zlib
########################################
tar xzvf ${LIBSRC}/zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=${LIBBASE} --static
make -j 4
make install
cd ..
rm -rf zlib-1.2.11

########################################
# HDF5
########################################
tar xjvf ${LIBSRC}/hdf5-1.10.5.tar.bz2
cd hdf5-1.10.5
export FC=$MPI_FC
export CC=$MPI_CC
export CXX=$MPI_CXX
./configure --prefix=${LIBBASE} --enable-parallel --with-zlib=${LIBBASE} --disable-shared
make -j 4
#make check
make install
cd ..
rm -rf hdf5-1.10.5

########################################
# Parallel-netCDF
########################################
tar xzvf ${LIBSRC}/pnetcdf-1.11.2.tar.gz
cd pnetcdf-1.11.2
export CC=$SERIAL_CC
export CXX=$SERIAL_CXX
export F77=$SERIAL_F77
export FC=$SERIAL_FC
export MPICC=$MPI_CC
export MPICXX=$MPI_CXX
export MPIF77=$MPI_F77
export MPIF90=$MPI_FC
### Will also need gcc in path
./configure --prefix=${LIBBASE}
make -j 4
#make check
#make ptest
#make testing
make install
export PNETCDF=${LIBBASE}
cd ..
rm -rf pnetcdf-1.11.2

########################################
# netCDF (C library)
########################################
tar xzvf ${LIBSRC}/netcdf-c-4.7.0.tar.gz
cd netcdf-c-4.7.0
export CPPFLAGS="-I${LIBBASE}/include"
export LDFLAGS="-L${LIBBASE}/lib"
export LIBS="-lhdf5_hl -lhdf5 -lz -ldl"
export CC=$MPI_CC
./configure --prefix=${LIBBASE} --disable-dap --enable-netcdf4 --enable-pnetcdf --enable-cdf5 --enable-parallel-tests --disable-shared
make -j 4 
#make check
make install
export NETCDF=${LIBBASE}
cd ..
rm -rf netcdf-c-4.7.0

########################################
# netCDF (Fortran interface library)
########################################
tar xzvf ${LIBSRC}/netcdf-fortran-4.4.5.tar.gz
cd netcdf-fortran-4.4.5
export FC=$MPI_FC
export F77=$MPI_F77
export LIBS="-lnetcdf ${LIBS}"
./configure --prefix=${LIBBASE} --enable-parallel-tests --disable-shared
make -j 4
#make check
make install
cd ..
rm -rf netcdf-fortran-4.4.5

#######################################
# PIO
#######################################
#git clone https://github.com/NCAR/ParallelIO
#cd ParallelIO
#git checkout -b pio-2.4.4 pio2_4_4
#export PIOSRC=`pwd`
#cd ..
#mkdir pio
#cd pio
tar xzvf ${LIBSRC}/scorpio-scorpio-v1.3.2.tar.gz
cd scorpio-scorpio-v1.3.2
export PIOSRC=`pwd`
export CC=$MPI_CC
export CXX=$MPI_CXX
export FC=$MPI_FC

cp ${LIBSRC}/SPIOUtils.cmake cmake/
CC=$MPI_CC CXX=$MPI_CXX FC=$MPI_FC cmake -DNetCDF_C_PATH=$NETCDF \
      -DNetCDF_Fortran_PATH=$NETCDF \
      -DPnetCDF_PATH=$PNETCDF \
      -DHDF5_PATH=$NETCDF \
      -DCMAKE_VERBOSE_MAKEFILE=1 \
      -DPIO_ENABLE_TIMING:BOOL=OFF \
      -DPIO_ENABLE_IO_STATS:BOOL=OFF \
      -DPIO_MAX_LUSTRE_OSTS=16 \
      -DPIO_STRIPING_UNIT=1048576 \
      -DCMAKE_INSTALL_PREFIX=$LIBBASE $PIOSRC
make
#make check
make install
cd ..
#rm -rf scorpio-scorpio-v1.3.2
export PIO=$LIBBASE

