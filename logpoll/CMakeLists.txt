cmake_minimum_required(VERSION 2.6)

project(logpoll)
set(CMAKE_C_FLAGS "-Wall")
option(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
option(CMAKE_C_FLAGS_RELEASE "-O2 -g0")

set(INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${INCLUDE_DIRS})

file(GLOB SRCS ${CMAKE_CURRENT_SOURCE_DIR}/src/logpoll.c)
set(LOGPOLL ${SRCS})

add_executable(${PROJECT_NAME} ${LOGPOLL})

set(LIBS event)
target_link_libraries(${PROJECT_NAME} ${LIBS})
