cmake_minimum_required(VERSION 3.13)
project(example-grpc LANGUAGES CXX)

find_package(Protobuf CONFIG REQUIRED)
find_package(gRPC CONFIG REQUIRED)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_CXX_STANDARD 17)

add_subdirectory(proto)

include_directories("${CMAKE_CURRENT_BINARY_DIR}")

file(GLOB GRPC_SOURCES "${CMAKE_CURRENT_BINARY_DIR}/proto/*.cc")

file(GLOB APP_SOURCE "main.cpp")

add_executable(${PROJECT_NAME} ${APP_SOURCE})

target_link_libraries(${PROJECT_NAME}
        ${_PROTOBUF_LIBPROTOBUF}
        ${_REFLECTION}
        ${_GRPC_GRPCPP}
        ${GRPC_SOURCES}
        gRPC::grpc++ 
        gRPC::grpc++_reflection 
        gRPC::gpr gRPC::grpc 
        gRPC::grpc++ 
        protobuf::libprotoc 
        protobuf::libprotobuf 
        protobuf::libprotobuf-lite
    )