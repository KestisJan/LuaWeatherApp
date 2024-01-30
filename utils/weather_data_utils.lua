
-- Safely create an info table based on provided data.
-- @param info (table) - The information data.
-- @return infoTable (table or nil) - The created info table or nil if info is not provided.
function createInfoTable(info)
    if info then
        return { name = info.name, country = info.country, lat = info.lat, lon = info.lon }
    else
        return nil
    end
end


-- Safely create a weather table based on provided weather data and info.
-- @param weatherData (table) - The weather data.
-- @param info (table) - The information data.
-- @return weatherTable (table) - The created weather table.
function createWeatherTable(weatherData, info)
    local weatherTable = {}

    if info then
        weatherTable["name"] = info.name
        weatherTable["country"] = info.country
        weatherTable["lat"] = info.lat
        weatherTable["lon"] = info.lon
    end

    if weatherData then
        weatherTable["timestamp"] = os.time()
        weatherTable["description"] = weatherData.weather[1].description
        weatherTable["temperature"] = weatherData.main.temp
        weatherTable["feels_like"] = weatherData.main.feels_like
        weatherTable["temp_min"] = weatherData.main.temp_min
        weatherTable["temp_max"] = weatherData.main.temp_max
        weatherTable["pressure"] = weatherData.main.pressure
        weatherTable["humidity"] = weatherData.main.humidity
    end

    return weatherTable
end

-- Print the weather forecast from the provided weather table.
-- @param weatherTable (table) - The weather table.
function printWeatherForecast(weatherTable)
    local success, result = pcall(function()
        if type(weatherTable) == "table" then
            print("Weather Forecast, date: " .. os.date("%Y-%m-%d", weatherTable.timestamp))
    
            if weatherTable.name then
                print("Location: " .. weatherTable.name .. ", " .. weatherTable.country)
                print("Coordinates: " .. weatherTable.lat .. ", " .. weatherTable.lon)
            end
    
            if weatherTable.timestamp then
                print("Time: " .. os.date("%H:%M:%S", weatherTable.timestamp))
                print("Description: " .. weatherTable.description)
                print("Temperature: " .. weatherTable.temperature .. " °C")
                print("Feels Like: " .. weatherTable.feels_like .. " °C")
                print("Min Temperature: " .. weatherTable.temp_min .. " °C")
                print("Max Temperature: " .. weatherTable.temp_max .. " °C")
                print("Pressure: " .. (weatherTable.pressure or "N/A") .. " hPa")
                print("Humidity: " .. weatherTable.humidity .. " %")
                print() -- Empty line between weather forecasts
            else
                print("Failed to fetch weather data")
            end
        else
            print("Failed to fetch weather data")
        end
    end)

    if not success then
        print("An error occurred while processing the weather data: " .. result)
    end
end


return {
    createInfoTable = createInfoTable,
    createWeatherTable = createWeatherTable,
    printWeatherForecast = printWeatherForecast,
}
