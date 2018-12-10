set(charmc_compiler_names charmc)
set(charmxi_compiler_names charmxi)


set(possible_charm_installations ~/usr /usr/local /usr /usr/charm* /usr/local/charm* /opt/charm*)
file(GLOB possible_charm_installations ${possible_charm_installations})
#message("possible locations" ${possible_charm_installations})

#CHARM Compiler
find_program(CHARM_COMPILER
	NAMES ${charmc_compiler_names}
	HINTS ${CHARM_PATH} ${CHARM_HOME} ENV CHARM_PATH ENV CHARM_HOME
	PATHS ${possible_charm_installations}
	PATH_SUFFIXES bin
	DOC "Charm++ compiler wrapper"
)
mark_as_advanced(CHARM_COMPILER)

#Get the version
if(CHARM_COMPILER)
execute_process(COMMAND ${CHARM_COMPILER} -V
				OUTPUT_VARIABLE charmc_version
				ERROR_QUIET
				OUTPUT_STRIP_TRAILING_WHITESPACE
			)
if(charmc_version MATCHES "^Charm\\+\\+ Version [0-9.]+")
	string(REGEX REPLACE "Charm\\+\\+ Version ([0-9.]+).*" "\\1" CHARM_VERSION_STRING "${charmc_version}")
endif()
	unset(charmc_version)
endif()

#CHARMXI charm module compiler
find_program(CHARMXI_COMPILER
	NAMES ${charmxi_compiler_names}
	HINTS ${CHARM_PATH} ${CHARM_HOME} ENV CHARM_PATH ENV CHARM_HOME
	PATHS ${possible_charm_installations}
	PATH_SUFFIXES bin
	DOC "Charm++ module compiler"
)
mark_as_advanced(CHARMXI_COMPILER)

#Get all options linking, etc.
if(CHARM_COMPILER)
execute_process(COMMAND ${CHARM_COMPILER} -print-building-blocks
				OUTPUT_VARIABLE charmc_all_variables
				ERROR_QUIET
				OUTPUT_STRIP_TRAILING_WHITESPACE
			)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Charm
	FOUND_VAR CHARM_FOUND
	REQUIRED_VARS CHARM_COMPILER CHARMXI_COMPILER
	VERSION_VAR CHARM_VERSION_STRING)


#Also find AMPI?
