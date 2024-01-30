-- Loading the LuaFileSystem (lfs) module for filesystem operations
local lfs = require("lfs")

-- Get the current working directory
local script_path = lfs.currentdir()

-- Remove the last component (in this case, 'src') from the path
script_path = script_path:gsub("/[^/]+$", "")

-- Update package.path to include the WeatherApp folder
package.path = package.path .. ";" .. script_path .. "/modules/?.lua;" .. script_path .. "/utils/?.lua";

local WeatherAPI = require("weather_app")

-- Load the weather data utility module
local weatherUtils = require("weather_data_utils")

-- Create an instance of WeatherAPI using the internal configuration
local api = WeatherAPI:new()

-- Get user input
print("Choose option:")
print("1. Get weather forecast by city name")
print("2. Get weather forecast by zipcode")
print("3. Get weather forecast by coordinates")
local option = tonumber(io.read())

local input

local input

if option == 1 then
    option = "city"
    print("Enter city/cities separated by commas:")
    input = io.read()

    local cities = {}
    for city in input:gmatch("([^,]+)") do
        table.insert(cities, city)
    end

    local count = #cities

    if count == 0 then
        print("No cities provided. Exiting.")
        return
    elseif count == 1 then
        local city = cities[1]

        local success, info = pcall(api.getCoordinates, api, option, city:gsub(" ", "%%20"))

        if success and info then
            local successWeather, weatherData = pcall(api.getWeather, api, info.lat, info.lon)
         
            if successWeather and weatherData then
                local weatherTable = weatherUtils.createWeatherTable(weatherData, info)
                weatherUtils.printWeatherForecast(weatherTable)
            else
                print("Failed to retrieve weather information for city:", city)
            end
        else
            print("Failed to retrieve information for city:", city)
        end
    else
        for _, city in ipairs(cities) do
            local success, info = pcall(api.getCoordinates, api, option, city:gsub(" ", "%%20"))

            if success and info then
                local successWeather, weatherData = pcall(api.getWeather, api, info.lat, info.lon)

                if successWeather and weatherData then
                    local weatherTable = weatherUtils.createWeatherTable(weatherData, info)
                    weatherUtils.printWeatherForecast(weatherTable)
                else
                    print("Failed to retrieve weather information for city:", city)
                end
            else
                print("Failed to retrieve information for city:", city)
            end
        end
    end
end