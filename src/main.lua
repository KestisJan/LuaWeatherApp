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

-- Load the database_operations' module, which contains functions related to weather data and database operations.
local weatherDataBase = require("database_operations")

-- Create an instance of WeatherAPI using the internal configuration
local api = WeatherAPI:new()

-- Get user input
print("Choose option:")
print("1. Get weather forecast by city name")
print("2. Get weather forecast by zipcode")
print("3. Get weather forecast by coordinates")
local option = tonumber(io.read())


local input

if option == 1 then
    option = "city"
    print("Enter city/cities separated by commas:")
    input = io.read()

    local cities = {}
    -- Split the input into individual city names
    for city in input:gmatch("([^,]+)") do
        table.insert(cities, city)
    end

    local count = #cities

    -- Handle the case when no cities are provided
    if count == 0 then
        print("No cities provided. Exiting.")
        return
    -- Handle the case when only one city is provided
    elseif count == 1 then
        local city = cities[1]

        -- Attempt to retrieve coordinates for the city
        local success, info = pcall(api.getCoordinates, api, option, city:gsub(" ", "%%20"))

        if success and info then
            -- If coordinates are obtained, attempt to get weather information
            local successWeather, weatherData = pcall(api.getWeather, api, info.lat, info.lon)

            if successWeather and weatherData then
                -- If weather information is obtained, create and print weather forecast
                local weatherTable = weatherUtils.createWeatherTable(weatherData, info)
                weatherUtils.printWeatherForecast(weatherTable)
            else
                print("Failed to retrieve weather information for city:", city)
            end
        else
            print("Failed to retrieve information for city:", city)
        end
    -- Handle the case when multiple cities are provided
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
-- Check if the user chose to get weather forecast by ZIP code
elseif option == 2 then
    option = "zipcode"
    print("Enter ZIP code(s) and country code(s) separated by commas:")
    input = io.read()

    local zipcodes = {}
    -- Split the input into individual ZIP code and country code pairs
    for zip, country in input:gmatch("([^,]+),(%u+)") do
        table.insert(zipcodes, { zip = zip, country = country })
    end

    local count = #zipcodes

    -- Handle the case when no ZIP codes are provided
    if count == 0 then
        print("No ZIP codes provided. Exiting.")
        return
    -- Handle the case when multiple ZIP codes are provided
    else
        for _, zipcode in ipairs(zipcodes) do
            local success, info = pcall(api.getCoordinates, api, option, zipcode.zip .. "," .. zipcode.country)

            if success and info then
                local successWeather, weatherData = pcall(api.getWeather, api, info.lat, info.lon)

                if successWeather and weatherData then
                    local weatherTable = weatherUtils.createWeatherTable(weatherData, info)
                    weatherUtils.printWeatherForecast(weatherTable)
                else
                    print("Failed to retrieve weather information for ZIP code:", zipcode.zip)
                end
            else
                print("Failed to retrieve information for ZIP code:", zipcode.zip)
            end
        end
    end
elseif option == 3 then
    option = "coordinates"
    print("Enter latitude and longitude(s) separated by commas:")
    input = io.read()

    -- Parse user input for coordinates
    local coordinates = {}
    for lat, lon in input:gmatch("([^,]+),([^,]+)") do
        table.insert(coordinates, { lat = lat, lon = lon })
    end

    local count = #coordinates

    if count == 0 then
        print("No coordinates provided. Exiting.")
        return
    elseif count == 1 then
        -- Single set of coordinates
        local coord = coordinates[1]

        -- Attempt to fetch weather information for the given coordinates
        local successWeather, weatherData = pcall(api.getWeather, api, coord.lat, coord.lon)

        if not successWeather or not weatherData then
            print("Failed to retrieve weather information for coordinates:", coord.lat, coord.lon)
            return
        end

        -- Create info table for printing and printing weather forecast
        local info = {
            lat = coord.lat,
            lon = coord.lon,
            name = weatherData.name,
            country = weatherData.sys.country
        }
        local weatherTable = weatherUtils.createWeatherTable(weatherData, info)
        weatherUtils.printWeatherForecast(weatherTable)
    else
        -- Multiple sets of coordinates
        for _, coord in ipairs(coordinates) do
            -- Attempt to fetch weather information for each set of coordinates
            local successWeather, weatherData = pcall(api.getWeather, api, coord.lat, coord.lon)

            if successWeather and weatherData then
                -- Create info table for printing and printing weather forecast
                local info = {
                    lat = coord.lat,
                    lon = coord.lon,
                    name = weatherData.name,
                    country = weatherData.sys.country
                }
                local weatherTable = weatherUtils.createWeatherTable(weatherData, info)
                weatherUtils.printWeatherForecast(weatherTable)
            else
                print("Failed to retrieve weather information for coordinates:", coord.lat, coord.lon)
            end
        end
    end
else
    print("Invalid option")
    return
end