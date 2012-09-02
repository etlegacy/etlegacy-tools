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

#include "etparser.h"

ETParser::ETParser()
{

}

ETParser::~ETParser()
{

}

void ETParser::ParseMessage(std::string recv_msg)
{
//     recv_msg.erase(recv_msg.find('\0'), recv_msg.npos);

	// Omit OOB from the packet name
	size_t headerEnd = recv_msg.find('\n');
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