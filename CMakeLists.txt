cmake_minimum_required(VERSION 3.15)
project(p4est
  LANGUAGES C)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules)

cmake_host_system_information(RESULT Ncpu QUERY NUMBER_OF_PHYSICAL_CORES)
message(VERBOSE "CMake ${CMAKE_VERSION} using ${Ncpu} threads")

include(cmake/compilers.cmake)
include(cmake/options.cmake)

if(NOT TARGET MPI::MPI_C)
  find_package(MPI COMPONENTS C)
endif()
find_package(ZLIB REQUIRED)

# --- sc
if(NOT sc_external)
  find_package(sc)
endif()
if(NOT sc_FOUND)
  include(cmake/sc.cmake)
endif(NOT sc_FOUND)


# --- p4est
if(Ep4est)
add_library(p4est)
target_include_directories(p4est
  PRIVATE src ${PROJECT_BINARY_DIR}/include)
target_link_libraries(p4est PRIVATE sc::sc)
if(MPI_FOUND)
  target_link_libraries(p4est PRIVATE MPI::MPI_C)
endif()
endif(Ep4est)

#--- p6est
if(Ep6est AND Ep4est AND Ep8est)
# TODO: check that p6est linked properly
add_library(p6est)
target_include_directories(p6est
  PRIVATE src ${PROJECT_BINARY_DIR}/include)
target_link_libraries(p6est PRIVATE sc::sc)
if(MPI_FOUND)
  target_link_libraries(p6est PRIVATE MPI::MPI_C)
endif()
endif()

#--- p8est
if(Ep8est)
add_library(p8est)
target_include_directories(p8est
  PRIVATE src ${PROJECT_BINARY_DIR}/include)
target_link_libraries(p8est PRIVATE sc::sc)
if(MPI_FOUND)
  target_link_libraries(p8est PRIVATE MPI::MPI_C)
endif()
endif(Ep8est)

add_subdirectory(src)
