if( ${UNIX} )
	option(NGT_SHARED_MEMORY_ALLOCATOR "enable shared memory" OFF)
	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/defines.h.in ${CMAKE_CURRENT_BINARY_DIR}/defines.h)
	include_directories("${CMAKE_CURRENT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/lib" "${PROJECT_BINARY_DIR}/lib/")

	if(${NGT_QBG_DISABLED})
		file(GLOB NGT_SOURCES *.cpp)
	else()
		file(GLOB NGT_SOURCES *.cpp NGTQ/*.cpp)
	endif()
	file(GLOB HEADER_FILES *.h *.hpp)
	file(GLOB NGTQ_HEADER_FILES NGTQ/*.h NGTQ/*.hpp)

	add_library(ngtstatic STATIC ${NGT_SOURCES})
	set_target_properties(ngtstatic PROPERTIES OUTPUT_NAME ngt)
	set_target_properties(ngtstatic PROPERTIES COMPILE_FLAGS "-fPIC")
	target_link_libraries(ngtstatic)
	if(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
		target_link_libraries(ngtstatic OpenMP::OpenMP_CXX)
	endif()

	add_library(ngt SHARED ${NGT_SOURCES})
	set_target_properties(ngt PROPERTIES VERSION ${ngt_VERSION})
	set_target_properties(ngt PROPERTIES SOVERSION ${ngt_SOVERSION})
	add_dependencies(ngt ngtstatic)
	if((NOT DEFINED NGT_QBG_DISABLED) OR (NOT ${NGT_QBG_DISABLED}))
		if((DEFINED NGT_X86SIMDSORT) OR (DEFINED NGTQG_X86SIMDSORT))
			target_link_libraries(ngt lapack blas x86simdsortcpp)
		else()
			target_link_libraries(ngt lapack blas)
		endif()
	endif()
	if(${APPLE})
		if(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
			target_link_libraries(ngt OpenMP::OpenMP_CXX)
		else()
			target_link_libraries(ngt gomp)
		endif()
	else(${APPLE})
		target_link_libraries(ngt gomp rt)
		if(NGT_FOREST)
			target_link_libraries(ngt stdc++fs)
			target_link_libraries(ngtstatic stdc++fs)
		endif()
	endif(${APPLE})
	add_custom_command(OUTPUT command DEPENDS ${NGT_SOURCES} WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} COMMAND sh ${PROJECT_SOURCE_DIR}/utils/mk_version_defs_h.sh ${PROJECT_SOURCE_DIR} version_defs.h)
	add_custom_target(versiondef DEPENDS command)
	add_dependencies(ngtstatic versiondef)
	install(TARGETS
		ngt
		ngtstatic
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib)
	install(FILES ${HEADER_FILES} ${CMAKE_CURRENT_BINARY_DIR}/defines.h  ${CMAKE_CURRENT_BINARY_DIR}/version_defs.h DESTINATION include/NGT)
	install(FILES ${NGTQ_HEADER_FILES} DESTINATION include/NGT/NGTQ)
endif()

# --- Windows build support (MinGW-w64 / MSYS2 UCRT64) ---
if(WIN32)
	if(NGT_SHARED_MEMORY_ALLOCATOR)
		message(FATAL_ERROR "NGT_SHARED_MEMORY_ALLOCATOR is not supported on Windows")
	endif()
	option(NGT_SHARED_MEMORY_ALLOCATOR "enable shared memory" OFF)
	configure_file(${CMAKE_CURRENT_SOURCE_DIR}/defines.h.in ${CMAKE_CURRENT_BINARY_DIR}/defines.h)
	include_directories("${CMAKE_CURRENT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}/lib" "${PROJECT_BINARY_DIR}/lib/")

	if(${NGT_QBG_DISABLED})
		file(GLOB NGT_SOURCES *.cpp)
	else()
		file(GLOB NGT_SOURCES *.cpp NGTQ/*.cpp)
	endif()
	list(REMOVE_ITEM NGT_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/MmapManager.cpp")
	file(GLOB HEADER_FILES *.h *.hpp)
	file(GLOB NGTQ_HEADER_FILES NGTQ/*.h NGTQ/*.hpp)

	add_library(ngtstatic STATIC ${NGT_SOURCES})
	set_target_properties(ngtstatic PROPERTIES COMPILE_FLAGS "-fPIC")
	target_link_libraries(ngtstatic)
	if(TARGET OpenMP::OpenMP_CXX)
		target_link_libraries(ngtstatic OpenMP::OpenMP_CXX)
	endif()

	find_package(Git QUIET)
	add_custom_target(versiondef
		COMMAND "${CMAKE_COMMAND}"
			"-DGIT_EXECUTABLE=${GIT_EXECUTABLE}"
			"-DNGT_SOURCE_DIR=${PROJECT_SOURCE_DIR}"
			"-DNGT_VERSION_DEFS=${CMAKE_CURRENT_BINARY_DIR}/version_defs.h"
			-P "${PROJECT_SOURCE_DIR}/utils/mk_version_defs_h.cmake"
		BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/version_defs.h"
		VERBATIM)
	add_dependencies(ngtstatic versiondef)

	install(TARGETS ngtstatic
		RUNTIME DESTINATION bin
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib)
	install(FILES ${HEADER_FILES} ${CMAKE_CURRENT_BINARY_DIR}/defines.h  ${CMAKE_CURRENT_BINARY_DIR}/version_defs.h DESTINATION include/NGT)
	install(FILES ${NGTQ_HEADER_FILES} DESTINATION include/NGT/NGTQ)
endif()
