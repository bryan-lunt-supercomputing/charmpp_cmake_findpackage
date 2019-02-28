cmake_minimum_required(VERSION 2.8)
project(CharmArrayHelloWorld LANGUAGES C CXX)

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

add_charm_module(foobar "main.ci")
add_library(hellolib "main.C" "main.h")
target_link_libraries(hellolib foobar)

add_executable(hello)
target_link_libraries(hello hellolib)
set_target_properties(hello PROPERTIES LINK_FLAGS "${CHARM_LDXX_FLAGS} ${MPI_CXX_LINK_FLAGS} -m64 -fPIC -rdynamic ")

#########

#The mainchar has to have its .C directly as executable sources or it doesn't link right.
#WTF?

add_charm_module(blah "main.ci")
target_link_libraries(blah INTERFACE charm_all)
add_executable(hello-better "main.C" "main.h")
target_link_libraries(hello-better blah)

###########

#cmake_policy(SET CMP0022 NEW)
add_charm_module(baz "main.ci")
add_library(hello-last-lib OBJECT "main.C" "main.h")
target_link_libraries(hello-last-lib baz)

add_executable(hello-last)
target_link_libraries(hello-last hello-last-lib charm_all)
#set_target_properties(hello-last PROPERTIES LINK_FLAGS "${CHARM_LDXX_FLAGS} ${MPI_CXX_LINK_FLAGS} -m64 -fPIC -rdynamic ")


############

#add_executable(hello "main.C" "main.h" "main.ci")
#set_charm_target(hello)
