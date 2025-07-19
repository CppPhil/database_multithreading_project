cmake_minimum_required(VERSION 3.22)

project(Database_Multithreading_Project)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if(WIN32)
  set(MYSQL_DIR
      "C:\\Program Files\\MySQL\\MySQL Server 8.0"
      CACHE STRING "set MySQL root dir" FORCE)
  set(MYSQL_INCLUDE_DIR
      "${MYSQL_DIR}\\include"
      CACHE STRING "set MySQL include dir" FORCE)
  set(MYSQL_LIBRARY
      "${MYSQL_DIR}\\lib\\libmysql.lib"
      CACHE STRING "set MySQL lib" FORCE)
  file(GLOB mysql_headers "${MYSQL_INCLUDE_DIR}/*.h")
  foreach(header ${mysql_headers})
    file(COPY ${header} DESTINATION "${MYSQL_INCLUDE_DIR}/mysql")
  endforeach()

  file(COPY "${MYSQL_DIR}\\lib\\libmysql.dll"
       DESTINATION "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
endif()

# Global configuration
set(BUILD_SHARED_LIBS
    OFF
    CACHE BOOL "Build shared libraries" FORCE)

# POCO Configuration
set(ENABLE_ENCODINGS
    OFF
    CACHE BOOL "Enable Encodings" FORCE)
set(ENABLE_XML
    OFF
    CACHE BOOL "Enable XML" FORCE)
set(ENABLE_MONGODB
    OFF
    CACHE BOOL "Enable MongoDB" FORCE)
set(ENABLE_DATA_SQLITE
    OFF
    CACHE BOOL "Enable Data SQlite" FORCE)
set(ENABLE_REDIS
    OFF
    CACHE BOOL "Enable Redis" FORCE)
set(ENABLE_ZIP
    OFF
    CACHE BOOL "Enable Zip" FORCE)
set(ENABLE_PAGECOMPILER
    OFF
    CACHE BOOL "Enable PageCompiler" FORCE)
set(ENABLE_PAGECOMPILER_FILE2PAGE
    OFF
    CACHE BOOL "Enable File2Page" FORCE)
set(ENABLE_ACTIVERECORD
    OFF
    CACHE BOOL "Enable ActiveRecord" FORCE)
set(ENABLE_ACTIVERECORD_COMPILER
    OFF
    CACHE BOOL "Enable ActiveRecord Compiler" FORCE)
set(ENABLE_JSON
    ON
    CACHE BOOL "Enable JSON" FORCE)
set(ENABLE_NET
    ON
    CACHE BOOL "Enable Net" FORCE)
set(ENABLE_DATA_MYSQL
    ON
    CACHE BOOL "Enable MySQL" FORCE)
set(ENABLE_NETSSL
    ON
    CACHE BOOL "Enable NetSSL" FORCE)

add_subdirectory(external/POCO)

add_subdirectory(external/GSL)

add_executable(Database_App src/main.cpp include/get_session.hpp
                            src/get_session.cpp)

target_link_libraries(
  Database_App
  PRIVATE Poco::Net
          Poco::Data
          Poco::DataMySQL
          Poco::NetSSL
          Poco::JWT
          Poco::JSON
          Microsoft.GSL::GSL)

target_include_directories(Database_App
                           PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
