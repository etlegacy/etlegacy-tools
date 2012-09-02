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

#include <boost/asio.hpp>
#include <boost/program_options.hpp>
#include <boost/lexical_cast.hpp>

#include "connection.h"
#include "etparser.h"

using boost::asio::ip::udp;

int main(int argc, char *argv[])
{
	try
	{
		/*
		 * Program options
		 */
		boost::program_options::options_description desc("[OPTIONS]");
		desc.add_options()
		    ("help,h", "show this message")
		    ("server,s", boost::program_options::value<std::string>(),
		    "server to query")
		    ("port,p",
		    boost::program_options::value<unsigned int>()->default_value(27960),
		    "port on the server")
		    ("message,m",
		    boost::program_options::value<std::string>()->default_value("getstatus"),
		    "message to be sent")
		    ("timeout,t",
		    boost::program_options::value<float>()->default_value(1.5),
		    "seconds to wait for the server to respond")
		    ("raw,r", "don't parse the server response")
		;
		boost::program_options::variables_map var_map;
		boost::program_options::store(boost::program_options::parse_command_line(argc, argv, desc), var_map);
		boost::program_options::notify(var_map);

		if (var_map.count("help"))
		{
			std::cout << desc << std::endl;
			return EXIT_SUCCESS;
		}
		else if (!var_map.count("server"))
		{
			std::cerr << "Usage: " << argv[0] << " -s <server>" << std::endl;
			std::cerr << "Append -h or --help to see all program options." << std::endl;
			return 1;
		}

		/*
		 * Send the request
		 */
		boost::asio::io_service io_service;
		Connection              client(io_service, var_map["server"].as<std::string>(),
		                               var_map["port"].as<unsigned int>(),
		                               var_map["message"].as<std::string>(),
		                               var_map["timeout"].as<float>());
		io_service.run();

		/*
		 * Parse the response
		 */
		ETParser parser;

		if (var_map.count("raw"))
		{
			std::cout << client.get_response() << std::endl;
		}
		else
		{
			parser.ParseMessage(client.get_response());
		}
	}
	catch (std::exception& e)
	{
		std::cerr << "Exception caught: " << e.what() << std::endl;
	}
	catch (...)
	{
		std::cerr << "Exception of unknown type!" << std::endl;
	}

	return EXIT_SUCCESS;
}

