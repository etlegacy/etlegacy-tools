cmake_minimum_required(VERSION 2.8)
project(etlist)

# Dependencies
Find_Package(Boost REQUIRED COMPONENTS system program_options) # Specifying 'asio' doesn't work
Find_Package(Threads) # asio dependency

add_executable(etlist connection.cpp main.cpp)

target_link_libraries(etlist ${Boost_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})