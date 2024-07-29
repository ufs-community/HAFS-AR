help([[
  This module loads libraries required for building and running HAFS
  on the NOAA RDHPC machine Gaea C5 using Intel-2023.1.0.
]])

whatis("Description: HAFS Application environment")

--- prepend_path("MODULEPATH", "/ncrc/proj/epic/spack-stack/spack-stack-1.6.0/envs/unified-env/install/modulefiles/Core")
prepend_path("MODULEPATH", "/autofs/ncrc-svm1_proj/epic/spack-stack/spack-stack-1.6.0/envs/g2tmpl-addon-env/install/modulefiles/Core")
prepend_path("MODULEPATH", "/ncrc/proj/gsl-glo/hafs/soft/modulefiles/")

stack_intel_ver=os.getenv("stack_intel_ver") or "2023.1.0"
load(pathJoin("stack-intel", stack_intel_ver))

stack_cray_mpich_ver=os.getenv("stack_cray_mpich_ver") or "8.1.25"
load(pathJoin("stack-cray-mpich", stack_cray_mpich_ver))

stack_python_ver=os.getenv("stack_python_ver") or "3.10.13"
load(pathJoin("stack-python", stack_python_ver))

cmake_ver=os.getenv("cmake_ver") or "3.23.1"
load(pathJoin("cmake", cmake_ver))

local ufs_modules = {
  {["py-numpy"]        = "1.22.3"},
  {["py-xarray"]       = "2023.7.0"},
  {["py-netcdf4"]      = "1.5.8"},
  {["jasper"]          = "2.0.32"},
  {["zlib"]            = "1.2.13"},
  {["libpng"]          = "1.6.37"},
  {["hdf5"]            = "1.14.0"},
  {["netcdf-c"]        = "4.9.2"},
  {["netcdf-fortran"]  = "4.6.1"},
  {["parallelio"]      = "2.5.10"},
  {["esmf"]            = "8.6.0"},
  {["fms"]             = "2023.04"},
  {["bacio"]           = "2.4.1"},
  {["crtm"]            = "2.4.0"},
  {["g2"]              = "3.4.5"},
  {["g2tmpl"]          = "1.12.0"},
  {["ip"]              = "4.3.0"},
  {["nemsio"]          = "2.5.4"},
  {["sp"]              = "2.5.0"},
  {["w3emc"]           = "2.10.0"},
  {["w3nco"]           = "2.4.1"},
  {["gftl-shared"]     = "1.6.1"},
-- no yafyaml
  {["mapl"]            = "2.40.3-esmf-8.6.0"},
  {["bufr"]            = "12.0.1"},
  {["sfcio"]           = "1.4.1"},
  {["sigio"]           = "2.3.2"},
-- no szip
  {["wrf-io"]          = "1.2.0"},
  {["prod_util"]       = "2.1.1"},
  {["grib-util"]       = "1.3.0"},
  {["wgrib2"]          = "2.0.8"},
-- no gempak
  {["nco"]             = "5.0.1"},
  {["cdo"]             = "1.9.10"},
}

for i = 1, #ufs_modules do
  for name, default_version in pairs(ufs_modules[i]) do
    local env_version_name = string.gsub(name, "-", "_") .. "_ver"
    load(pathJoin(name, os.getenv(env_version_name) or default_version))
  end
end

load("rocoto")

unload("cray-libsci")

setenv("CMAKE_C_COMPILER", "cc")
setenv("CMAKE_CXX_COMPILER", "CC")
setenv("CMAKE_Fortran_COMPILER", "ftn")
setenv("CMAKE_Platform", "gaea_c5.intel")
