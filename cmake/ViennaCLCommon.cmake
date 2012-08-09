
# do not build tests by default, since they require Boost
if (VIENNACL_SRC_DIST)
 option(BUILD_TESTING "Build the tests " ON)
else (VIENNACL_SRC_DIST)
 option(BUILD_TESTING "Build the tests " OFF)
endif(VIENNACL_SRC_DIST)

include(CTest)
include(CMakeDependentOption)

# Installation directories
##########################

set(INSTALL_INCLUDE_DIR include CACHE PATH
   "Installation directory for headers")
if(WIN32 AND NOT CYGWIN)
   set(DEF_INSTALL_CMAKE_DIR CMake)
else()
   set(DEF_INSTALL_CMAKE_DIR lib/cmake/viennacl)
endif()
set(INSTALL_CMAKE_DIR ${DEF_INSTALL_CMAKE_DIR} CACHE PATH
   "Installation directory for CMake files")

if(NOT IS_ABSOLUTE "${INSTALL_CMAKE_DIR}")
   set(INSTALL_CMAKE_DIR "${CMAKE_INSTALL_PREFIX}/${INSTALL_CMAKE_DIR}")
endif()
file(RELATIVE_PATH CONF_REL_INSTALL_PREFIX "${INSTALL_CMAKE_DIR}"
   "${CMAKE_INSTALL_PREFIX}")
if(NOT IS_ABSOLUTE "${INSTALL_INCLUDE_DIR}")
   set(INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_PREFIX}/${INSTALL_INCLUDE_DIR}")
endif()
file(RELATIVE_PATH CONF_REL_INCLUDE_DIR "${INSTALL_CMAKE_DIR}"
   "${INSTALL_INCLUDE_DIR}")

# User options
##############

option(BUILD_EXAMPLES "Build example programs" ON)

# If you are interested in the impact of different kernel parameters on
# performance, you may want to give ViennaProfiler a try (see
# http://sourceforge.net/projects/viennaprofiler/) Set your connection
# parameters in examples/parameters/common_vprof.hpp accordingly.
cmake_dependent_option(ENABLE_VIENNAPROFILER
   "Enable examples using ViennaProfiler" OFF BUILD_EXAMPLES OFF)


# If you want to build the examples that use boost::numeric::ublas, enable
# the following:
cmake_dependent_option(ENABLE_UBLAS "Enable examples using uBLAS" OFF
   BUILD_EXAMPLES OFF)

# If you want to build the examples that use Eigen
cmake_dependent_option(ENABLE_EIGEN "Enable examples that use Eigen" OFF
   BUILD_EXAMPLES OFF)

# If you want to build the examples that use MTL4
cmake_dependent_option(ENABLE_MTL4 "Enable examples that use MTL4" OFF
   BUILD_EXAMPLES OFF)

cmake_dependent_option(ENABLE_PEDANTIC_FLAGS "Enable pedantic compiler flags"
   ON CMAKE_COMPILER_IS_GNUCXX OFF)

mark_as_advanced(BOOSTPATH ENABLE_VIENNAPROFILER ENABLE_UBLAS ENABLE_EIGEN
   ENABLE_MTL4 ENABLE_PEDANTIC_FLAGS)

# Find prerequisites
####################

# Boost:
IF (BOOSTPATH)
 SET(CMAKE_INCLUDE_PATH ${CMAKE_INCLUDE_PATH} ${BOOSTPATH})
 SET(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${BOOSTPATH}/lib")
 SET(BOOST_ROOT ${BOOSTPATH})
ENDIF (BOOSTPATH)


if(ENABLE_UBLAS OR BUILD_TESTING OR VIENNACL_SRC_DIST)
   set(Boost_USE_MULTITHREADED TRUE)
   find_package(Boost REQUIRED COMPONENTS filesystem system)
endif()

find_package(OpenCL REQUIRED)
find_package(OpenMP)

if(ENABLE_VIENNAPROFILER)
   find_package(ViennaProfiler REQUIRED)
endif()

if(ENABLE_EIGEN)
   # find Eigen
   find_path(EIGEN_INCLUDE_DIR Eigen/Dense)
   if(NOT EIGEN_INCLUDE_DIR)
      message(SEND_ERROR "Failed to find Eigen")
   endif()
   mark_as_advanced(EIGEN_INCLUDE_DIR)
endif()

if(ENABLE_MTL4)
   # MTL4 comes with a MTLConfig.cmake
   find_package(MTL REQUIRED)
endif()

include_directories(
   ${PROJECT_BINARY_DIR}
   ${PROJECT_SOURCE_DIR}
   ${OPENCL_INCLUDE_DIRS})

# Set high warning level on GCC
if(ENABLE_PEDANTIC_FLAGS)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic")
endif()

# Export
########

configure_file(cmake/FindOpenCL.cmake
   ${PROJECT_BINARY_DIR}/FindOpenCL.cmake COPYONLY)

configure_file(cmake/ViennaCLConfig.cmake.in
   ${PROJECT_BINARY_DIR}/ViennaCLConfig.cmake @ONLY)

configure_file(cmake/ViennaCLConfigVersion.cmake.in
   ${PROJECT_BINARY_DIR}/ViennaCLConfigVersion.cmake @ONLY)

export(PACKAGE ViennaCL)

# Install
#########

install(FILES
   ${PROJECT_BINARY_DIR}/FindOpenCL.cmake
   ${PROJECT_BINARY_DIR}/ViennaCLConfig.cmake
   ${PROJECT_BINARY_DIR}/ViennaCLConfigVersion.cmake
   DESTINATION ${INSTALL_CMAKE_DIR} COMPONENT dev)