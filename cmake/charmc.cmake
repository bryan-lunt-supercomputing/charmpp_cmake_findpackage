include("allprops")

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

	set_target_properties(${target_name} PROPERTIES SOURCES "${TMP_NON_CHARM_SOURCES}" SCOPE PARENT_SCOPE)
	#TODO: append to if the charm sources property already exists
	set_target_properties(${target_name} PROPERTIES "CHARM_SOURCES" "${TMP_CHARM_SOURCES}" SCOPE PARENT_SCOPE)

	#message("all charm sources : " "${TMP_CHARM_SOURCES}")
	#message("all non-charm sources : " "${TMP_NON_CHARM_SOURCES}")

	#this will rebuild the files each time for each target, even if multiple targets use the same output.
	#If we use an OUTPUT type custom_command, and alter the target's sources list, we might avoid that.
	add_custom_command(TARGET ${target_name}
		PRE_BUILD
		COMMAND "echo" ${CHARM_COMPILER} ${CMAKE_CURRENT_SOURCE_DIR}/${TMP_CHARM_SOURCES}
	)


endfunction()
