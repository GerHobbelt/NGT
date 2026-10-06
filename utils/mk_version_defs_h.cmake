# Generate Windows version metadata when the build runs.
string(TIMESTAMP NGT_BUILD_DATE "%Y/%m/%d %H:%M:%S")

if(GIT_EXECUTABLE AND EXISTS "${GIT_EXECUTABLE}")
    foreach(metadata IN ITEMS HASH DATE TAG)
        if(metadata STREQUAL "HASH")
            set(git_args log -1 --format=%H)
        elseif(metadata STREQUAL "DATE")
            set(git_args log -1 --format=%cd)
        else()
            set(git_args describe --abbrev=0)
        endif()
        execute_process(
            COMMAND "${GIT_EXECUTABLE}" ${git_args}
            WORKING_DIRECTORY "${NGT_SOURCE_DIR}"
            RESULT_VARIABLE git_result
            OUTPUT_VARIABLE git_value
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET)
        if("${git_result}" STREQUAL "0" AND NOT "${git_value}" STREQUAL "")
            set(NGT_GIT_${metadata} "${git_value}")
        endif()
    endforeach()
endif()

if(EXISTS "${NGT_SOURCE_DIR}/VERSION")
    file(READ "${NGT_SOURCE_DIR}/VERSION" NGT_VERSION)
    string(STRIP "${NGT_VERSION}" NGT_VERSION)
endif()

set(version_defs "//\n// Do *NOT* edit this file.\n//\n")
foreach(metadata IN ITEMS NGT_BUILD_DATE NGT_GIT_HASH NGT_GIT_DATE NGT_GIT_TAG NGT_VERSION)
    if(DEFINED ${metadata} AND NOT "${${metadata}}" STREQUAL "")
        string(REPLACE "\\" "\\\\" value "${${metadata}}")
        string(REPLACE "\"" "\\\"" value "${value}")
        string(APPEND version_defs "#define\t${metadata}\t\t\"${value}\"\n")
    endif()
endforeach()
file(WRITE "${NGT_VERSION_DEFS}" "${version_defs}")
