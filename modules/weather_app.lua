-- Importing the 'http.request module to make HTTP requests'
local http_request = require("http.request")
-- Importing the 'cjson.safe' module for safe JSON encoding and decoding
local json = require("cjson.safe")
-- Loading the LuaFileSystem (lfs) module for filesystem operations
local lfs = require("lfs")
-- Getting the current working directory using LuaFileSystem (lfs)
local script_path = lfs.currentdir()
-- Remove the last component (in this case, 'src') from the path
script_path = script_path:gsub("/[^/]+$", "")
-- Updating package.path to include the WeatherApp folders for module loading
package.path = package.path .. ";" .. script_path .. "/config/?.lua;"
-- Require the configuration module for API key and settings
local config = require("config")

-- WeatherAPI module to interact with OpenWeather APIs
local WeatherAPI = {}

-- Create a new WeatherAPI object
-- @param apiKey (string) - The API key for accessing weather data (optional, defaults to the one in the config)
-- @param lang (string) - The language for the weather data (optional, defaults to the one in the config)
-- @param format (string) - The format for the weather data (optional, defaults to the one in the config)
-- @return newObj (table) - The new WeatherAPI object
function WeatherAPI:new(apiKey, lang, format)
    local newObj = {
        apiKey = apiKey or config.apiKey, -- API key for OpenWeather
        lang = lang or config.lang, -- Language for weather data
        format = format or config.format, -- Format for weather data
        geoApiUrl = "http://api.openweathermap.org/geo/1.0/", -- URL for the Geo API
        weatherApiURl = "https://api.openweathermap.org/data/2.5/weather", -- URL for the Weather API
    }

    -- Set the metatable to the WeatherAPI class
    setmetatable(newObj, self)
    self.__index = self

    -- Return the new object
    return newObj
end


