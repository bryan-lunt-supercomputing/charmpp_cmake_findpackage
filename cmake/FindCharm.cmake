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

if(CHARMXI_COMPILER)

	function(set_charm_target target_name)
		set(options )
		set(oneValueArgs )
		set(multiValueArgs CHARM_SOURCES ADDITIONAL_CHARM_SOURCES CHARM_MODULES )
		cmake_parse_arguments(SET_CHARM_TARGET "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	#	define_property(TARGET PROPERTY "CHARM_SOURCES"
	#	BRIEF_DOCS "Sources for charmxi"
	#	FULL_DOCS  "List of source files that the charm module compiler should interpret."
	#)
		#examine all the sources and find any charm sources.
		#print_target_properties(${target_name})

		get_target_property(ALL_SOURCES_PATHS ${target_name} SOURCES)

		set(TMP_CHARM_SOURCES )
		set(TMP_NON_CHARM_SOURCES )

		foreach(one_source ${ALL_SOURCES_PATHS})
			#message("blah : " ${one_source})
			if(${one_source} MATCHES "\\.ci$")
				#message("Appending : " ${one_source})
				list(APPEND TMP_CHARM_SOURCES ${one_source})
			else()
				list(APPEND TMP_NON_CHARM_SOURCES ${one_source})
			endif()
		endforeach(one_source)
		foreach(one_charm_source ${TMP_CHARM_SOURCES})
			list(REMOVE_ITEM ALL_SOURCES_PATHS ${one_charm_source})
		endforeach(one_charm_source)

		#set_target_properties(${target_name} PROPERTIES SOURCES "${TMP_NON_CHARM_SOURCES}" SCOPE PARENT_SCOPE)
		#TODO: append to if the charm sources property already exists
		#set_target_properties(${target_name} PROPERTIES "CHARM_SOURCES" "${TMP_CHARM_SOURCES}" SCOPE PARENT_SCOPE)

		#message("all charm sources : " "${TMP_CHARM_SOURCES}")
		#message("all non-charm sources : " "${TMP_NON_CHARM_SOURCES}")

		message("THE CHARMXI COMPILER IS " ${CHARMXI_COMPILER})

		foreach(one_charm_source ${TMP_CHARM_SOURCES})
			get_filename_component(SINGLE_CHARM_DEFAULT_OUTPUT ${one_charm_source} NAME)
			string(REGEX REPLACE "\\.ci$" "" SINGLE_CHARM_DEFAULT_OUTPUT ${SINGLE_CHARM_DEFAULT_OUTPUT})
			list(APPEND TMP_NON_CHARM_SOURCES "${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.decl.h")
			list(APPEND TMP_NON_CHARM_SOURCES "${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.def.h")
			include_directories(${target_name} ${CMAKE_CURRENT_BINARY_DIR})

			#If we use an OUTPUT type custom_command, and alter the target's sources list, we might avoid that.
			#message("one_charm_source : " ${CMAKE_CURRENT_SOURCE_DIR}/${one_charm_source} )
			set(SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${one_charm_source})
			#add_custom_command(TARGET ${target_name}
			add_custom_command(
				PRE_BUILD
				OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.decl.h ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.def.h
				COMMAND ${CHARMXI_COMPILER} ${SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH}
				WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
				DEPENDS ${SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH}
				VERBATIM
			)
		endforeach()

		set_target_properties(${target_name} PROPERTIES SOURCES "${TMP_NON_CHARM_SOURCES}" SCOPE PARENT_SCOPE)
		#TODO: append to if the charm sources property already exists
		set_target_properties(${target_name} PROPERTIES "CHARM_SOURCES" "${TMP_CHARM_SOURCES}" SCOPE PARENT_SCOPE)


	endfunction()
endif(CHARMXI_COMPILER)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Charm
	FOUND_VAR CHARM_FOUND
	REQUIRED_VARS CHARM_COMPILER CHARMXI_COMPILER
	VERSION_VAR CHARM_VERSION_STRING)


#Also find AMPI?
