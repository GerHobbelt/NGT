if( ${UNIX} )
	add_subdirectory(${PROJECT_SOURCE_DIR}/lib/NGT)
endif()

if(WIN32)
	add_subdirectory(${PROJECT_SOURCE_DIR}/lib/NGT)
endif()
