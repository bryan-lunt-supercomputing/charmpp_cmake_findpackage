cmake_minimum_required(VERSION 2.8)
project(load_balanced_hello LANGUAGES C CXX)

# Location of additional cmake modules
#
set(CMAKE_MODULE_PATH
	${CMAKE_MODULE_PATH}
	${PROJECT_SOURCE_DIR}/cmake
	)

#	define_property(TARGET PROPERTY "CHARM_SOURCES"
#	BRIEF_DOCS "Sources for charmxi"
#	FULL_DOCS  "List of source files that the charm module compiler should interpret."
#	)

find_package(Charm)
if(CHARM_FOUND)
        message("Charm found: ${CHARM_COMPILER}")
		#include("charmc")
		#set(CMAKE_C_COMPILER "${CHARM_COMPILER}")
		#set(CMAKE_CXX_COMPILER "${CHARM_COMPILER}")
		#set(CMAKE_C_FLAGS "-O3 -language charm++")
		#set(CMAKE_CXX_FLAGS "-O3 -language charm++")


else()
        message(FATAL_ERROR "Charm not found!")
endif()


#The mainchar has to have its .C directly as executable sources or it doesn't link right.
#WTF?

add_charm_module(lbhellomodule "hello.ci" LINK_MODULES "CommonLBs")
target_link_libraries(lbhellomodule INTERFACE charm_all)
add_executable(lbhello "hello.C")
target_link_libraries(lbhello lbhellomodule)
