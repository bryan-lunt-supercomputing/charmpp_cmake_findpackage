#include(allprops)


cmake_policy(SET CMP0022 NEW)
set(charmxi_compiler_names ${charmxi_compiler_names} charmxi)

include(FindPackageHandleStandardArgs)

#CHARMXI charm module compiler
find_program(CHARMXI_COMPILER
	NAMES ${charmxi_compiler_names}
	HINTS ${CHARM_PATH} ${CHARM_HOME} ENV CHARM_PATH ENV CHARM_HOME
	PATHS ${possible_charm_installations}
	PATH_SUFFIXES bin
	DOC "Charm++ module compiler"
)
mark_as_advanced(CHARMXI_COMPILER)


if(CHARMXI_COMPILER)
	define_property(TARGET PROPERTY "CHARM_SOURCES"
		BRIEF_DOCS "Sources for charmxi"
		FULL_DOCS  "List of source files that the charm module compiler should interpret."
	)

	function(create_modinit_src modinit_src_varname )
		set(options SEARCH STANDALONE NOMAIN) #Tells if we want to search for .ci files in the basic sources list
		set(oneValueArgs TRACEMODE) #TODO: actually look at charmc to figure out how to properly build traces
		set(multiValueArgs CHARM_SOURCES CHARM_MODULES LINK_MODULES )
		cmake_parse_arguments(CREATE_MODINIT_SRC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

		set(my_mi_sourcecode "")
		foreach(one_dependency_module ${CREATE_MODINIT_SRC_LINK_MODULES})
			set(my_mi_sourcecode "${my_mi_sourcecode} extern void _register${one_dependency_module}(void); ")
		endforeach()


		set(my_mi_sourcecode "${my_mi_sourcecode}  void _registerExternalModules(char **argv) {  (void)argv; ")
		foreach(one_dependency_module ${CREATE_MODINIT_SRC_LINK_MODULES})
			set(my_mi_sourcecode "${my_mi_sourcecode} _register${one_dependency_module}(); ")
		endforeach()
		set(my_mi_sourcecode "${my_mi_sourcecode} } " )

		set(my_mi_sourcecode "${my_mi_sourcecode}  void _createTraces(char **argv) { (void)argv; } ")
		set(${modinit_src_varname} "${my_mi_sourcecode}" PARENT_SCOPE)
	endfunction()


	function(add_charm_module module_name)
		set(options SEARCH STANDALONE NOMAIN) #Tells if we want to search for .ci files in the basic sources list
		set(oneValueArgs TRACEMODE) #TODO: actually look at charmc to figure out how to properly build traces
		set(multiValueArgs CHARM_SOURCES CHARM_MODULES LINK_MODULES )
		cmake_parse_arguments(ADD_CHARM_MODULE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

		add_library(${module_name} INTERFACE)

		#message("add_charm_module ARGC " ${ARGC})
		#message("add_charm_module ARGV " ${ARGV})
		#message("add_charm_module ARGN " ${ARGN})
		#message("add_charm_module unparsed " ${ADD_CHARM_MODULE_UNPARSED_ARGUMENTS})

		#the director for the generated files
		set(MODULE_GENPATH "${CMAKE_CURRENT_BINARY_DIR}/${module_name}_charmxi.dir")
		add_custom_target(${module_name}_builddir)
		add_custom_command(TARGET ${module_name}_builddir PRE_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory "${MODULE_GENPATH}")
		add_dependencies(${module_name} INTERFACE ${module_name}_builddir)
		target_include_directories(${module_name} INTERFACE ${MODULE_GENPATH})

		foreach(one_charm_source ${ADD_CHARM_MODULE_UNPARSED_ARGUMENTS})
			get_filename_component(SINGLE_CHARM_DEFAULT_OUTPUT ${one_charm_source} NAME)
			string(REGEX REPLACE "\\.ci$" "" SINGLE_CHARM_DEFAULT_OUTPUT ${SINGLE_CHARM_DEFAULT_OUTPUT})

			#If only certain modules were asked for, we should generate those into a non-default directory.

			target_sources(${module_name} INTERFACE "${MODULE_GENPATH}/${SINGLE_CHARM_DEFAULT_OUTPUT}.decl.h")
			target_sources(${module_name} INTERFACE "${MODULE_GENPATH}/${SINGLE_CHARM_DEFAULT_OUTPUT}.def.h")
			set(SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${one_charm_source})
			add_custom_command(
				PRE_BUILD
				OUTPUT "${MODULE_GENPATH}/${SINGLE_CHARM_DEFAULT_OUTPUT}.decl.h" "${MODULE_GENPATH}/${SINGLE_CHARM_DEFAULT_OUTPUT}.def.h"
				#COMMAND ${CMAKE_COMMAND} -E make_directory "${MODULE_GENPATH}"
				COMMAND ${CHARMXI_COMPILER} ${SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH}
				WORKING_DIRECTORY ${MODULE_GENPATH}
				DEPENDS "${SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH}"
				VERBATIM
			)
			#add_custom_target()

			create_modinit_src(tmp_modinit_sourcecode LINK_MODULES ${ADD_CHARM_MODULE_LINK_MODULES})

			set(mod_init_src "${MODULE_GENPATH}/${SINGLE_CHARM_DEFAULT_OUTPUT}_modinit.C")
			target_sources(${module_name} INTERFACE ${mod_init_src})
			add_custom_command(
				PRE_BUILD
				OUTPUT "${mod_init_src}"
				#COMMAND ${CMAKE_COMMAND} -E make_directory "${MODULE_GENPATH}"
				COMMAND echo "${tmp_modinit_sourcecode}" >> ${mod_init_src}
				WORKING_DIRECTORY ${MODULE_GENPATH}
				VERBATIM
			)
		endforeach()

		foreach(one_linked_module ${ADD_CHARM_MODULE_LINK_MODULES})
			#TODO: Need to process modules dependencies.
			target_link_libraries(${module_name} INTERFACE "module${one_linked_module}")
		endforeach()

		target_include_directories(${module_name} INTERFACE ${MPI_CXX_INCLUDE_PATH})
		target_link_libraries(${module_name} INTERFACE ${MPI_CXX_LIBRARIES})
		target_include_directories(${module_name} INTERFACE ${CHARM_CXX_INCLUDE_PATH})

		#set_target_properties(${module_name} PROPERTIES INTERFACE_COMPILE_FLAGS "${CHARM_CXX_FLAGS} ${MPI_CXX_COMPILE_FLAGS} -m64 -fPIC ")
		#set_target_properties(${module_name}_linkage PROPERTIES INTERFACE_LINK_FLAGS "${CHARM_LDXX_FLAGS} ${MPI_CXX_LINK_FLAGS} -m64 -fPIC -rdynamic ")

	endfunction()

	function(set_charm_target target_name)
		set(options SEARCH STANDALONE NOMAIN) #Tells if we want to search for .ci files in the basic sources list
		set(oneValueArgs TRACEMODE) #TODO: actually look at charmc to figure out how to properly build traces
		set(multiValueArgs CHARM_SOURCES CHARM_MODULES )
		cmake_parse_arguments(SET_CHARM_TARGET "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

		#examine all the sources and find any charm sources.
		#print_target_properties(${target_name})

		get_target_property(ALL_SOURCES_PATHS ${target_name} SOURCES)

		set(TMP_CHARM_SOURCES ) #TODO: Start with / append any charm sources provided here.
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

		#message("THE CHARMXI COMPILER IS " ${CHARMXI_COMPILER})

		foreach(one_charm_source ${TMP_CHARM_SOURCES})
			get_filename_component(SINGLE_CHARM_DEFAULT_OUTPUT ${one_charm_source} NAME)
			string(REGEX REPLACE "\\.ci$" "" SINGLE_CHARM_DEFAULT_OUTPUT ${SINGLE_CHARM_DEFAULT_OUTPUT})

			#TODO: We should create a directory that these generated files go into.
			#If only certain modules were asked for, we should generate those into a non-default directory.

			list(APPEND TMP_NON_CHARM_SOURCES "${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.decl.h")
			list(APPEND TMP_NON_CHARM_SOURCES "${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.def.h")
			include_directories(${target_name} ${CMAKE_CURRENT_BINARY_DIR})

			#If we use an OUTPUT type custom_command, and alter the target's sources list, we might avoid that.
			#message("one_charm_source : " ${CMAKE_CURRENT_SOURCE_DIR}/${one_charm_source} )
			set(SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${one_charm_source})
			add_custom_command(
				PRE_BUILD
				OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.decl.h ${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}.def.h
				COMMAND ${CHARMXI_COMPILER} ${SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH}
				WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
				DEPENDS ${SET_CHARM_TARGET_SINGLE_CHARM_SOURCE_FULL_PATH}
				VERBATIM
			)

			#TODO: needs to be per module
			set(mod_init_src "${CMAKE_CURRENT_BINARY_DIR}/${SINGLE_CHARM_DEFAULT_OUTPUT}_modinit.C")
			list(APPEND TMP_NON_CHARM_SOURCES ${mod_init_src})
			add_custom_command(
				PRE_BUILD
				OUTPUT ${mod_init_src}
				COMMAND echo "void _registerExternalModules(char **argv) { (void)argv; } void _createTraces(char **argv) {(void)argv;}" >> ${mod_init_src}
				WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
				VERBATIM
			)


			#todo: each module needs a modInit
		endforeach()

		set_target_properties(${target_name} PROPERTIES SOURCES "${TMP_NON_CHARM_SOURCES}" SCOPE PARENT_SCOPE)
		#TODO: append to if the charm sources property already exists
		set_target_properties(${target_name} PROPERTIES "CHARM_SOURCES" "${TMP_CHARM_SOURCES}" SCOPE PARENT_SCOPE)

		#compile and linking flags
		#TODO: Charm can be built without MPI, can't it?
		#TODO: Detect the language C/CXX etc.
		#TODO: Get the last compiler/linker flags dynamically from interrogating charmc, not hardcoded as they are here "-m64 etc."
		include_directories(${target_name} ${MPI_CXX_INCLUDE_PATH})
		target_link_libraries(${target_name} ${MPI_CXX_LIBRARIES})
		set_target_properties(${target_name} PROPERTIES COMPILE_FLAGS "${CHARM_CXX_FLAGS} ${MPI_CXX_COMPILE_FLAGS} -m64 -fPIC " SCOPE PARENT_SCOPE)
		set_target_properties(${target_name} PROPERTIES LINK_FLAGS "${CHARM_LDXX_FLAGS} ${MPI_CXX_LINK_FLAGS} -m64 -fPIC -rdynamic " SCOPE PARENT_SCOPE)

		include_directories(${target_name} ${CHARMINC})

	endfunction()
endif(CHARMXI_COMPILER)
