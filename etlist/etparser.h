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
#ifndef ETPARSER_H
#define ETPARSER_H

#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <iomanip> // using 'setw'

#include <boost/tokenizer.hpp>
#include <boost/algorithm/string.hpp>

class ETParser
{
public:
	ETParser(std::vector<std::string> packets);

	void ParseResponse(std::string rsp_to_parse);
	void SplitVariables(std::string rsp_to_split);

	void set_response_name(std::string rsp_header);
	std::string get_variable(std::string key);
	void add_variable(std::string key, std::string value);
private:
	std::multimap<std::string, std::string> response_variables_;
};

#endif // ETPARSER_H
