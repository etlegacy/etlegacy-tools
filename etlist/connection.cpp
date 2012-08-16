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

Connection::Connection(std::string server_name, int server_port /*=27960*/,
                       std::string message /*=getstatus*/)
	: socket_(io_service_), resolver_(io_service_), deadline_(io_service_)
{
	udp::resolver::query query(udp::v4(), server_name,
	                           boost::lexical_cast<std::string>(server_port));
	udp::endpoint receiver_endpoint = *resolver_.resolve(query);

	socket_.open(udp::v4());
	socket_.send_to(boost::asio::buffer(wrap_message(message), 1024),
	                receiver_endpoint);

	// Set to positive infinity so that there's no action until a specific
	// deadline is set.
	deadline_.expires_at(boost::posix_time::pos_infin);

	// Start the persistent actor that checks for deadline expiry.
	check_deadline();
}

/*
 * @brief Wraps messages into the Quake III protocol format
 */
std::string Connection::wrap_message(std::string message)
{
	// NOTE: master server doesn't react to a message terminated with 0xfa
	return std::string(4, 0xff) + message + std::string(1, 0xfa);
}

std::size_t Connection::ReceiveMessage(
    const boost::asio::mutable_buffer& buffer,
    boost::posix_time::time_duration timeout,
    boost::system::error_code& ec)
{
	deadline_.expires_from_now(timeout);
	ec = boost::asio::error::would_block;
	std::size_t length = 0;

	// Start the asynchronous operation itself. The handle_receive function
	// used as a callback will update the ec and length variables.
	socket_.async_receive(boost::asio::buffer(buffer),
	                      boost::bind(&Connection::handle_receive, _1, _2,
	                                  &ec, &length));

	// Block until the asynchronous operation has completed.
	do
		io_service_.run_one();
	while (ec == boost::asio::error::would_block);

	return length;
}

void Connection::handle_receive(
    const boost::system::error_code& ec, std::size_t length,
    boost::system::error_code *out_ec, std::size_t *out_length)
{
	*out_ec     = ec;
	*out_length = length;
}

void Connection::check_deadline()
{
	// Check whether the deadline has passed. We compare the deadline against
	// the current time since a new asynchronous operation may have moved the
	// deadline before this actor had a chance to run.
	if (deadline_.expires_at() <= boost::asio::deadline_timer::traits_type::now())
	{
		// The deadline has passed. The outstanding asynchronous operation needs
		// to be cancelled so that the blocked receive() function will return.
		//
		// Please note that cancel() has portability issues on some versions of
		// Microsoft Windows, and it may be necessary to use close() instead.
		// Consult the documentation for cancel() for further information.
		socket_.cancel();

		// There is no longer an active deadline. The expiry is set to positive
		// infinity so that the actor takes no action until a new deadline is set.
		deadline_.expires_at(boost::posix_time::pos_infin);
	}

	// Put the actor back to sleep.
	deadline_.async_wait(boost::bind(&Connection::check_deadline, this));
}

void Connection::ParseMessage(std::string recv_msg)
{
//     recv_msg.erase(recv_msg.find('\0'), recv_msg.npos);
	size_t headerEnd = recv_msg.find('\n');

	// Omit OOB from the packet name
	std::cout << "Parsing " <<
	recv_msg.substr(4, headerEnd - 4) << " packet.... ";

	std::map<std::string, std::string> recv_tokens;

	std::string key, value;
	size_t      tokenStart = 0;
	size_t      tokenEnd   = 0;

	for (;; )
	{
		/*
		 * Search for a key
		 */
		tokenStart = recv_msg.find('\\', tokenEnd++);
		tokenEnd   = recv_msg.find('\\', ++tokenStart);

		// No more keys
		if (tokenStart == std::string::npos)
		{
			break;
		}

		// Key without a value
		if (tokenEnd == std::string::npos)
		{
			key = recv_msg.substr(tokenStart,
			                      recv_msg.length() - tokenStart);
			recv_tokens[key] = "";
			std::cout << "Warning: adding a key with empty value." << std::endl;
			break;
		}

		key = recv_msg.substr(tokenStart, tokenEnd - tokenStart);

		/*
		 * Search for a value
		 */
		tokenStart = recv_msg.find('\\', tokenEnd++);
		tokenEnd   = recv_msg.find('\\', ++tokenStart);

		// No more values
		if (tokenStart == std::string::npos)
		{
			break;
		}

		// Value is not at the end
		if (tokenEnd != std::string::npos)
		{
			value = recv_msg.substr(tokenStart, tokenEnd - tokenStart);
		}
		else
		{
			// Last value
			value = recv_msg.substr(tokenStart, recv_msg.length() - tokenStart);
		}

		/*
		 * Store key->value pair in a map
		 */
		recv_tokens[key] = value;

		// FIXME: This should not happen, but it does. Why?
		if (tokenStart >= recv_msg.length() || tokenEnd >= recv_msg.length())
		{
			break;
		}
	}

	/*
	     * Display key->value pairs
	     */
	std::cout << recv_tokens.size() << " variables paired" << std::endl << std::endl;

	std::map <std::string, std::string>::iterator it;
	for (it = recv_tokens.begin(); it != recv_tokens.end(); ++it)
	{
		std::cout << std::setw(22) << it->first << ": " << it->second <<
		std::endl;
	}
}
