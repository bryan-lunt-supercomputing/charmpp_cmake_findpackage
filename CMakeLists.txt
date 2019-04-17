cmake_minimum_required(VERSION 2.8)
project(CharmHello LANGUAGES C CXX)

# Location of additional cmake modules
#
set(CMAKE_MODULE_PATH
	${CMAKE_MODULE_PATH}
	${PROJECT_SOURCE_DIR}/cmake
	)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_DATA_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/data)



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

###
## Currently we can't handle having multiple similarily named .ci files in the top level CMakeLists.txt
###
#add_executable(hello "src/hello/main.C" "src/hello/main.h" "src/hello/main.ci")
#set_charm_target(hello)

add_subdirectory("src/hello")

add_subdirectory("src/load_balancing")

add_subdirectory("src/ArrayHelloWorld")

add_subdirectory("src/BroadcastHelloWorld")

add_subdirectory("src/PhasedHello")

add_subdirectory("src/SDAGHello")
