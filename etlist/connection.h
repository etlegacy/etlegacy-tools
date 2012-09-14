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
#ifndef CONNECTION_H
#define CONNECTION_H

#include <iostream>
#include <string>

#include <boost/asio.hpp>
#include <boost/asio/deadline_timer.hpp>
#include <boost/date_time/posix_time/posix_time_types.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/bind.hpp>

using boost::asio::ip::udp;

class Connection
{
public:
	Connection(boost::asio::io_service& io_service,
	           std::string server_name = "etlegacy.com",
	           int server_port = 27960,
	           std::string message = "getstatus",
	           float timeout = 1.5);
	void close();
	std::vector<std::string> get_response();
private:
	boost::asio::deadline_timer timer_;
	boost::asio::io_service     &io_service_;
	udp::socket                 socket_;
	udp::endpoint               receiver_endpoint_;

	enum { max_length = 2048 };
	char                     data_[max_length];
	std::vector<std::string> response_;

	void HandleReceive(const boost::system::error_code& error, size_t bytes_recvd);
	void HandleSend();

	std::string wrap_message(std::string message);
};

#endif // CONNECTION_H
