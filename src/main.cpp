#include <iostream>

#include "grpc++/create_channel.h"
#include "proto/greeter.grpc.pb.h"
#include "proto/greeter.pb.h"

int main()
{

    std::shared_ptr<grpc::Channel> ch = grpc::CreateChannel("tovarisch-andruha.ru:8080",
                                                            grpc::InsecureChannelCredentials());

    // Create the stub
    std::unique_ptr<greeter_service::Greeter::Stub> stub = greeter_service::Greeter::NewStub(ch);

    // Create the client message
    greeter_service::HelloRequest request;
    request.set_name("Andrey");

    // Invoke the method
    grpc::ClientContext ctx;
    greeter_service::HelloReply response;
    grpc::Status status = stub->SayHello(&ctx, request, &response);

    // Check status
    if (status.ok())
    {
        std::cout << response.message() << std::endl;
    }
    else
    {
        std::cout << status.error_code() << ": "
                  << status.error_message() << std::endl;
    }
    return 0;
}