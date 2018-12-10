
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
