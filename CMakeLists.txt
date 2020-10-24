cmake_minimum_required(VERSION 3.17 FATAL_ERROR)

if (POLICY CMP0025)
    cmake_policy(SET CMP0025 NEW)
endif ()

project(testMongo)

# Enforce the C++ standard, and disable extensions.
if (NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD 17)
endif ()


include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(CMAKE_CXX_EXTENSIONS OFF)

if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Werror")
endif ()

set(CONNECTION_URI "mongodb://localhost:27017" CACHE STRING "Connection URI string")

configure_file("${PROJECT_SOURCE_DIR}/config.h.in" "${PROJECT_SOURCE_DIR}/src/config.h")

add_executable(testMongo
        src/config.h
        src/main.cpp)

add_custom_target(
        PRE_BUILD
        COMMAND /bin/sh install-mongo-lib.sh
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_dependencies(testMongo PRE_BUILD)

# NOTE: For this to work, the CMAKE_PREFIX_PATH variable must be set to point to the directory that
# was used as the argument to CMAKE_INSTALL_PREFIX when building libmongocxx.
list(APPEND CMAKE_PREFIX_PATH "./drivers/mongo-cxx-driver")
find_package(mongocxx REQUIRED)

# Visual Studio pre 2017 requires boost polyfill.
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND CMAKE_CXX_STANDARD LESS 17)
    find_package(Boost 1.56.0 REQUIRED)
    if (CMAKE_VERSION VERSION_LESS 3.15.0)
        target_include_directories(testMongo PRIVATE ${Boost_INCLUDE_DIRS})
    else ()
        target_link_libraries(testMongo PRIVATE Boost::boost)
    endif ()
endif ()

target_link_libraries(testMongo
        PRIVATE mongo::mongocxx_shared
        )

