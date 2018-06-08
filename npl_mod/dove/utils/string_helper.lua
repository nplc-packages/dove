--[[
title: string helper
author: chenqh
date: 2017/12/17
]]
local _M = commonlib.gettable("Dove.Utils.StringHelper")
local str_upper, str_gmatch, str_gsub = string.upper, string.gmatch, string.gsub

-- Returns the Capitalized form of a string
function _M.capitalize(str)
    return (str_gsub(str, '^%l', str_upper))
end

-- Returns the camelCase form of a string keeping the 1st word unchanged
function _M.camelize(str)
    return (str_gsub(str, '%W+(%w+)', _M.capitalize))
end

-- Returns the UpperCamelCase form of a string
function _M.classify(str)
    return (str_gsub(str, '%W*(%w+)', _M.capitalize))
end

-- Separates a camelized string by underscores, keeping capitalization
function _M.decamelize(str)
    return (str_gsub(str, '(%l)(%u)', '%1_%2'))
end

-- Replaces each word separator with a single dash
function _M.dasherize(str)
    return (str_gsub(str, '%W+', '-'))
end

------------------------------------------------------------------------------
-- Iterate substrings by splitting at any character in a set of delimiters
------------------------------------------------------------------------------

local DELIMITERS = ';,'

function _M.split(str, delimiters)
  delimiters = delimiters or DELIMITERS
  return str_gmatch(str, '([^'..delimiters..']+)['..delimiters..']*')
end
