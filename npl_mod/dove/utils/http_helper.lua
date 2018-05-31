local _M = commonlib.gettable("Dove.Utils.HttpHelper")

-- Encodes a character as a percent encoded string
local function char_to_pchar(c)
	return string.format("%%%02X", c:byte(1, 1))
end

-- encode_uri replaces all characters except the following with the appropriate UTF-8 escape sequences:
-- ; , / ? : @ & = + $
-- alphabetic, decimal digits, - _ . ! ~ * ' ( )
-- #
local function encode_uri(str)
	return (str:gsub("[^%;%,%/%?%:%@%&%=%+%$%w%-%_%.%!%~%*%'%(%)%#]", char_to_pchar))
end

-- encode_uri_component escapes all characters except the following: alphabetic, decimal digits, - _ . ! ~ * ' ( )
local function encode_uri_component(str)
	return (str:gsub("[^%w%-_%.%!%~%*%'%(%)]", char_to_pchar))
end

-- decode_uri unescapes url encoded characters
-- excluding for characters that are special in urls
local decode_uri
do
	-- Keep the blacklist in numeric form.
	-- This means we can skip case normalisation of the hex characters
	local decode_uri_blacklist = {}
	for char in ("#$&+,/:;=?@"):gmatch(".") do
		decode_uri_blacklist[string.byte(char)] = true
	end
	local function decode_uri_helper(str)
		local x = tonumber(str, 16)
		if not decode_uri_blacklist[x] then
			return string.char(x)
		end
		-- return nothing; gsub will not perform the replacement
	end
	function decode_uri(str)
		return (str:gsub("%%(%x%x)", decode_uri_helper))
	end
end

-- Converts a hex string to a character
local function pchar_to_char(str)
	return string.char(tonumber(str, 16))
end

-- decode_uri_component unescapes *all* url encoded characters
local function decode_uri_component(str)
	return (str:gsub("%%(%x%x)", pchar_to_char))
end

-- An iterator over query segments (delimited by "&") as key/value pairs
-- if a query segment has no '=', the value will be `nil`
local function query_args(str)
	local iter, state, first = str:gmatch("([^=&]+)(=?)([^&]*)&?")
	return function(state, last) -- luacheck: ignore 431
		local name, equals, value = iter(state, last)
		if name == nil then
			return nil
		end
		name = decode_uri_component(name)
		if equals == "" then
			value = nil
		else
			value = decode_uri_component(value)
		end
		return name, value
	end, state, first
end

-- Converts a dictionary (string keys, string values) to an encoded query string
local function dict_to_query(form)
	local r, i = {}, 0
	for name, value in pairs(form) do
		i = i + 1
		r[i] = encode_uri_component(name) .. "=" .. encode_uri_component(value)
	end
	return table.concat(r, "&", 1, i)
end


_M.encode_uri = encode_uri
_M.encode_uri_component = encode_uri_component
_M.decode_uri = decode_uri
_M.decode_uri_component = decode_uri_component
_M.query_args = query_args
_M.dict_to_query = dict_to_query
