# src/CMakeLists.txt
cmake_minimum_required(VERSION 3.5.1)

# For Protobuf's cmake warnings
if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif()

project(hello C CXX)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20")

find_package(Threads REQUIRED)

# Find Protobuf installation
# Looks for protobuf-config.cmake file installed by Protobuf's cmake installation.
set(protobuf_MODULE_COMPATIBLE TRUE)
find_package(Protobuf CONFIG REQUIRED)
message(STATUS "Using protobuf ${Protobuf_VERSION}")

set(_PROTOBUF_LIBPROTOBUF protobuf::libprotobuf)
set(_REFLECTION gRPC::grpc++_reflection)
find_program(_PROTOBUF_PROTOC protoc)

# Find gRPC installation
# Looks for gRPCConfig.cmake file installed by gRPC's cmake installation.
find_package(gRPC CONFIG REQUIRED)
message(STATUS "Using gRPC ${gRPC_VERSION}")

set(_GRPC_GRPCPP gRPC::grpc++)
find_program(_GRPC_CPP_PLUGIN_EXECUTABLE grpc_cpp_plugin)

# Protos
file(GLOB PROTOS
     "proto/*.proto"
)
foreach(PROTO ${PROTOS})
  get_filename_component(h_proto ${PROTO} ABSOLUTE)
  get_filename_component(h_proto_path "${h_proto}" PATH)


  set(PROTO_NAME ${PROTO})
  string(REGEX MATCHALL "[a-z_A-Z]+\.proto$" PROTO_NAME ${PROTO_NAME})
  list(GET PROTO_NAME -1 PROTO_NAME)

  set(PROTO_NAME ${PROTO_NAME})
  string(REGEX MATCHALL "^[a-z_A-Z]+" PROTO_NAME ${PROTO_NAME})
  list(GET PROTO_NAME -1 PROTO_NAME)


  message(${PROTO_NAME})


  # Generated sources
  set(h_proto_srcs "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_NAME}.pb.cc")
  set(h_proto_hdrs "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_NAME}.pb.h")
  set(h_grpc_srcs "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_NAME}.grpc.pb.cc")
  set(h_grpc_hdrs "${CMAKE_CURRENT_BINARY_DIR}/${PROTO_NAME}.grpc.pb.h")
endforeach()




add_custom_command(
  OUTPUT "${h_proto_srcs}" "${h_proto_hdrs}" "${h_grpc_srcs}" "${h_grpc_hdrs}"
  COMMAND ${_PROTOBUF_PROTOC}
  ARGS --grpc_out "${CMAKE_CURRENT_BINARY_DIR}"
    --cpp_out "${CMAKE_CURRENT_BINARY_DIR}"
    -I "${h_proto_path}"
    --plugin=protoc-gen-grpc="${_GRPC_CPP_PLUGIN_EXECUTABLE}"
    "${h_proto}"
  DEPENDS "${h_proto}")


# Generated sources headers
include_directories("${CMAKE_CURRENT_BINARY_DIR}")

file(GLOB APP_SOURCE "main.cpp")

add_executable(${PROJECT_NAME}
    ${APP_SOURCE}
    ${h_proto_srcs}
    ${h_grpc_srcs})

target_link_libraries(${PROJECT_NAME}
    ${_REFLECTION}
    ${_GRPC_GRPCPP}
    ${_PROTOBUF_LIBPROTOBUF})
