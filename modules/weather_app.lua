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
        weatherApiUrl = "https://api.openweathermap.org/data/2.5/weather", -- URL for the Weather API
    }

    -- Set the metatable to the WeatherAPI class
    setmetatable(newObj, self)
    self.__index = self

    -- Return the new object
    return newObj
end

-- Get geographical coordinates based on the provided option and input.
-- @param option (string) - The option to specify the input type ("city" or "zipcode")
-- @param input (string) - The input data (either city name or zipcode, depending on the option).
function WeatherAPI:getCoordinates(option, input)
    local queryString

    -- Constructing the query string based on the option
    if option == "city" then
        queryString = string.format("direct?q=%s&appid=%s", input, self.apiKey)
    elseif option == "zipcode" then
        local zip, country = input:match("([^,]+),(%u+)")
        queryString = string.format("zip?zip=%s,%s&appid=%s", zip, country, self.apiKey)
    else
        -- Handling invalid option with an error message
        error("Invalid option: " .. option)
    end

    -- Constructing the full URL for the Geo API
    local fullUrl = self.geoApiUrl .. queryString
    local req = http_request.new_from_uri(fullUrl)

    -- Using pcall to catch errors during the HTTP request
    local success, headers, stream = pcall(req.go, req)
    if not success then
        -- Returning an error table if the HTTP request fails
        return { error = "HTTP request failed."}
    end

    local body = assert(stream:get_body_as_string())

    -- Checking if the HTTP status is not 200 (OK)
    if headers:get("status") ~= "200" then
        -- Returning an error table with the error message
        return { error = body }
    end

    -- Devode the JSON response body into a Lua table
    local result = json.decode(body)

    -- Returning result
    return result
end

-- Get weather information based on geographical coordinates.
-- @param lat (number) - The latitude coordinate.
-- @param lon (number) - The longitude coordinate
-- @return result (table) - The weather information as a Lua table.

function WeatherAPI:getWeather(lat, lon)
    -- Constructing the query string with necessary parameters
    local queryString = string.format("lat=%s&lon=%s&lang=%s&appid=%s&mode=%s", lat, lon, self.lang, self.apiKey, self.mode )
    local fullUrl = self.weatherApiUrl .. "?" .. queryString

    -- Creating an HTTP request object
    local req = http_request.new_from_uri(fullUrl)

    -- Using pcall to catch errors during the HTTP request
    local success, headers, stream = pcall(req.go, req)
    if not success then
        -- Retrieving an error table if the HTTP request fails
        return { error = "HTTP request failed."}
    end

    -- Reading the response body
    local body = assert(stream:get_body_as_string())

    -- Checking if the HTTP status is not 200 (OK)
    if headers:get(":status") ~= "200" then
        -- Returning an error table with the error message
        return { error = body }
    end

    -- Decoding the JSON responsive body into a Lua table
    local result = json.decode(body)

    -- Returning the result table
    return result
end

return WeatherAPI
