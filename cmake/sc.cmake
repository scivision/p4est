include(ExternalProject)

set(sc_external true CACHE BOOL "build sc library")

find_package(Autotools REQUIRED)

set(sc_ROOT ${PROJECT_BINARY_DIR}/sc CACHE PATH "sc library" FORCE)

set(sc_LIBRARY ${sc_ROOT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}sc${CMAKE_STATIC_LIBRARY_SUFFIX} CACHE FILEPATH "sc library" FORCE)

set(sc_flags --prefix=${sc_ROOT})
set(sc_mpi)
if(MPI_C_FOUND)
  set(sc_mpi --enable-mpi)
endif()

ExternalProject_Add(SC
GIT_REPOSITORY https://github.com/cburstedde/libsc.git
GIT_TAG a8137f6c807bde7c04a8e2d85c7a2dea2c675067
CONFIGURE_COMMAND ${PROJECT_BINARY_DIR}/SC-prefix/src/sc/configure ${sc_flags} ${sc_mpi}
BUILD_COMMAND ${MAKE_EXECUTABLE} -j${Ncpu}
INSTALL_COMMAND ${MAKE_EXECUTABLE} -j${Ncpu} install
BUILD_BYPRODUCTS ${sc_LIBRARY}
)

ExternalProject_Get_Property(SC SOURCE_DIR)

ExternalProject_Add_Step(SC
  bootstrap
  COMMAND ./bootstrap
  DEPENDEES download
  DEPENDERS configure
  WORKING_DIRECTORY ${SOURCE_DIR})

set(sc_INCLUDE_DIRS ${sc_ROOT}/include)
set(sc_LIBRARIES ${sc_LIBRARY})

# --- imported target
file(MAKE_DIRECTORY ${sc_ROOT}/include)  # avoid race condition

add_library(sc::sc INTERFACE IMPORTED GLOBAL)
target_include_directories(sc::sc INTERFACE ${sc_INCLUDE_DIRS})
target_link_libraries(sc::sc INTERFACE "${sc_LIBRARIES}")  # need the quotes to expand list
# set_target_properties didn't work, but target_link_libraries did work

add_dependencies(sc::sc SC)
