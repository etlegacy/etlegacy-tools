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
#include "etparser.h"

ETParser::ETParser(std::vector<std::string> packets)
{
	for (int i = 0; i < packets.size(); i++)
	{
		ParseResponse(packets[i]);
	}

	// Just print it all out for now:
	std::map <std::string, std::string>::iterator it;
	for (it = response_variables_.begin(); it != response_variables_.end(); ++it)
	{
		std::cout << std::setw(22) << it->first << ": " << it->second <<
		std::endl;
	}
}

void ETParser::ParseResponse(std::string rsp_to_parse)
{
	set_response_name(rsp_to_parse);

	if (get_variable("response_name") == "statusResponse"
	    || get_variable("response_name") == "infoResponse")
	{
		std::vector<std::string> parts;
		boost::split(parts, rsp_to_parse, boost::is_any_of("\n"), boost::token_compress_on);

		SplitVariables(parts.at(1));
		if (parts.size() > 1)
		{
			std::string players;
			for (int i = 2; i < parts.size(); i++)
			{
				if (!parts[i].empty())
				{
					players += parts[i] + std::string(1, 0xFF);
				}
			}
			if (!players.empty())
			{
				add_variable("players", players);
			}
		}
	}
	else if (get_variable("response_name") == "getserversResponse")
	{
		// TODO
	}
	else
	{
		std::cout << "UNKNOWN RESPONSE TYPE" << std::endl;
	}
}

void ETParser::SplitVariables(std::string rsp_to_split)
{
//     recv_msg.erase(recv_msg.find('\0'), recv_msg.npos);

	std::string key, value;
	size_t      tokenStart = 0, tokenEnd = 0;

	for (;; )
	{
		/*
		 * Search for a key
		 */
		tokenStart = rsp_to_split.find('\\', tokenEnd++);
		tokenEnd   = rsp_to_split.find('\\', ++tokenStart);

		// No more keys
		if (tokenStart == std::string::npos)
		{
			break;
		}

		// Key without a value
		if (tokenEnd == std::string::npos)
		{
			key = rsp_to_split.substr(tokenStart,
			                          rsp_to_split.length() - tokenStart);
			response_variables_[key] = std::string("");
			std::cout << "Warning: adding a key with empty value." << std::endl;
			break;
		}

		key = rsp_to_split.substr(tokenStart, tokenEnd - tokenStart);

		/*
		 * Search for a value
		 */
		tokenStart = rsp_to_split.find('\\', tokenEnd++);
		tokenEnd   = rsp_to_split.find('\\', ++tokenStart);

		// No more values
		if (tokenStart == std::string::npos)
		{
			break;
		}

		// Value is not at the end
		if (tokenEnd != std::string::npos)
		{
			value = rsp_to_split.substr(tokenStart,
			                            tokenEnd - tokenStart);
		}
		else
		{
			// Last value
			value = rsp_to_split.substr(tokenStart,
			                            rsp_to_split.length() - tokenStart);
		}

		response_variables_[key] = value;

		// FIXME: This should not happen, but it does. Why?
		if (tokenStart >= rsp_to_split.length() ||
		    tokenEnd >= rsp_to_split.length())
		{
			break;
		}
	}
}

std::string ETParser::get_variable(std::string key)
{
	return response_variables_.find(key)->second;
}

void ETParser::add_variable(std::string key, std::string value)
{
	response_variables_.insert(
	    std::pair<std::string, std::string>(key, value));
}

void ETParser::set_response_name(std::string rsp_header)
{
	try
	{
		// Omit OOB (4x0xFF) from the packet start
		rsp_header = rsp_header.substr(4);

		// getserversResponse is delimited by a backslash
		// statusResponse and infoResponse are delimited by a newline
		std::vector<std::string> parts;
		boost::split(parts, rsp_header, boost::is_any_of("\\ \n"), boost::token_compress_on);

		add_variable("response_name", parts[0]);
	}
	catch (std::out_of_range& exception)
	{
		std::cerr << "Invalid response: " << rsp_header << std::endl;
		exit(EXIT_FAILURE);
	}
}
