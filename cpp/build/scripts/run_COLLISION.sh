module load mpi

export TEST_MPI_COMMAND="salloc -Q -n 1 --gres=gpu mpirun"
export PARALLEL_NETCDF_ROOT="/shared/common/pnetcdf-1.14.1"
export LD_LIBRARY_PATH=/shared/common/pnetcdf-1.14.1/lib:$LD_LIBRARY_PATH
export GATOR_INITIAL_MB=32

cd ~/miniWeather/cpp/build

./cmake_clean.sh

cmake -DCMAKE_CXX_COMPILER=mpic++         \
      -DCMAKE_C_COMPILER=mpicc            \
      -DCMAKE_Fortran_COMPILER=mpif90     \
      -DYAKL_CXX_FLAGS="-Ofast -march=native -mtune=native -DNO_INFORM -I${PARALLEL_NETCDF_ROOT}/include"   \
      -DLDFLAGS="-L${PARALLEL_NETCDF_ROOT}/lib -lpnetcdf"  \
      -DNX=256                            \
      -DNZ=128                            \
      -DSIM_TIME=700                      \
      -DOUT_FREQ=10                       \
      -DDATA_SPEC=DATA_SPEC_COLLISION     \
      ..

make -j $(nproc)


salloc -Q -n 4 mpirun ./parallelfor

mv output.nc output_COLLISION.nc