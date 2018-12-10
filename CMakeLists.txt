cmake_minimum_required(VERSION 2.8)
project(CharmHello VERSION 1.0 LANGUAGES C CXX)

# Location of additional cmake modules
#
set(CMAKE_MODULE_PATH
	${CMAKE_MODULE_PATH}
	${PROJECT_SOURCE_DIR}/cmake
	)

find_package(Charm)
if(CHARM_FOUND)
        message("Charm found: ${CHARM_COMPILER}")
else()
        message(FATAL_ERROR "Charm not found!")
endif()
