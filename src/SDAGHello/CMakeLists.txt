cmake_minimum_required(VERSION 2.8)
project(CharmSDAGHelloWorld LANGUAGES C CXX)

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

add_library(sdag_hello_lib  "hello.C" "hello.h" "hello.ci" "main.ci")
set_charm_target(sdag_hello_lib)

add_executable(sdag_hello "main.C" "main.h" "main.ci")
set_charm_target(sdag_hello)
target_link_libraries(sdag_hello sdag_hello_lib)

#include("allprops")
#print_target_properties(foobar)
#get_target_property(BLAH foobar CHARM_SOURCES)
#message("CHARM_SOURCES " ${BLAH})
