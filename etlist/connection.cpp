/*
 * ET: Legacy
 * Copyright (C) 2012 Jan Simek <mail@etlegacy.com>
 *
 * This file is part of ET: Legacy - http://www.etlegacy.com
 *
 * ET: Legacy is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * ET: Legacy is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with ET: Legacy. If not, see <http://www.gnu.org/licenses/>.
 */

#include "connection.h"

Connection::Connection(boost::asio::io_service& io_service,
                       std::string server_address /*=etlegacy.com*/,
                       unsigned short server_port /*=27960*/,
                       std::string message /*=getstatus*/,
                       float timeout /*=1.5*/)
	: io_service_(io_service), socket_(io_service, udp::v4()), timer_(io_service)
{
	// Allow ip:port address format
	if (server_address.find(":") != std::string::npos)
	{
		server_port = boost::lexical_cast<unsigned short>
		                  (server_address.substr(server_address.find(":") + 1));
		server_address = server_address.substr(0, server_address.find(":"));
	}

	udp::resolver        resolver(io_service_);
	udp::resolver::query query(udp::v4(), server_address,
	                           boost::lexical_cast<std::string>(server_port));
	receiver_endpoint_ = *resolver.resolve(query);

	socket_.async_send_to(boost::asio::buffer(wrap_message(message)),
	                      receiver_endpoint_,
	                      boost::bind(&Connection::HandleSend, this));

	// How long should we wait for the server to respond
	timer_.expires_from_now(boost::posix_time::seconds(timeout));
	timer_.async_wait(boost::bind(&Connection::close, this));
}

void Connection::close()
{
	socket_.close();
}

/**
 * @brief Wraps messages into the Quake III protocol format
 */
std::string Connection::wrap_message(std::string message)
{
	// NOTE: master server doesn't react to a message terminated with 0xfa
	return std::string(4, 0xff) + message;
}

std::vector<std::string> Connection::get_response()
{
	return response_;
}

/**
 * @brief Calls itself after every received packet.
 * @note It hangs after the last received packet until it is stopped.
 */
void Connection::HandleReceive(const boost::system::error_code& error,
                               size_t bytes_recvd)
{
	if (!error && bytes_recvd > 0)
	{
		socket_.async_receive_from(
		    boost::asio::buffer(data_, max_length), receiver_endpoint_,
		    boost::bind(&Connection::HandleReceive, this,
		                boost::asio::placeholders::error,
		                boost::asio::placeholders::bytes_transferred));

		// std::cout.write(data_, bytes_recvd) << std::endl;
		response_.push_back(std::string(data_, bytes_recvd));
	}
#if 0
	else if (error)
	{
		std::cout << "Receive error: [" << error.category().name() << "] " << error.message() << std::endl;
	}
#endif
	// io_service will quit when it has no more work to do
}

/**
 * @brief Calls HandleReceive for the first packet.
 *
 * Separate from the HandleReceive method to avoid adding whitespace to response_
 */
void Connection::HandleSend()
{
	socket_.async_receive_from(
	    boost::asio::buffer(data_, max_length), receiver_endpoint_,
	    boost::bind(&Connection::HandleReceive, this,
	                boost::asio::placeholders::error,
	                boost::asio::placeholders::bytes_transferred));
}
