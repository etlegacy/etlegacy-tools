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

#include <iostream>
#include <string>
#include <map>
#include <iomanip> // using 'setw'

#include <boost/asio.hpp>
#include <boost/asio/deadline_timer.hpp>
#include <boost/program_options.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/bind.hpp>

using boost::asio::ip::udp;

class Connection
{
public:
	Connection(std::string server_name = "etlegacy.com",
	           int server_port = 27960,
	           std::string message = "getstatus");

	std::size_t ReceiveMessage(const boost::asio::mutable_buffer& buffer,
	                           boost::posix_time::time_duration timeout,
	                           boost::system::error_code& ec);
	void ParseMessage(std::string recv_msg);
private:
	boost::asio::io_service        io_service_;
	boost::asio::ip::udp::socket   socket_;
	boost::asio::deadline_timer    deadline_;
	boost::asio::ip::udp::resolver resolver_;

	std::string wrap_message(std::string message);

	void check_deadline();
	static void handle_receive(
	    const boost::system::error_code& ec, std::size_t length,
	    boost::system::error_code *out_ec, std::size_t *out_length);
};
