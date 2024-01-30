-- Load the SQLite library
local sqllib = require('lsqlite3')
local weatherUtils = require("weather_data_utils")

-- Specify the path to the SQLite database file
local Dbfilename = '/home/kestas/Sqlite/initial-db.sqlite'

-- database_operations.createDataBase(info)
-- Creates or opens an SQLite database and stores information about a favorite location.
local function createDataBase(info)
    -- Open the SQLite database
    local db = sqllib.open(Dbfilename)

    -- Check if the database was successfully opened
    if db then
        -- Create the 'favourites' table if it doesn't exist
        db:exec[=[
            CREATE TABLE IF NOT EXISTS favourites (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp INTEGER,
                name TEXT,
                country TEXT,
                lat REAL,
                lon REAL
            );
        ]=]

        -- Create a favoritesTable with information from the provided 'info' table
        local favoritesTable = weatherUtils.createInfoTable(info)

        -- Check if creating the favoritesTable was successful
        if favoritesTable then
            -- Insert information into the 'favourites' table
            db:exec(string.format([[
                INSERT INTO favourites (timestamp, name, country, lat, lon) VALUES (
                    %d, '%s', '%s', %.2f, %.2f
                )
            ]],
            os.time(),
            favoritesTable.name,
            favoritesTable.country,
            favoritesTable.lat,
            favoritesTable.lon))
        end

        -- Close the database connection
        db:close()
    else
        -- Print an error message if the database couldn't be opened
        print("Error opening the database.")
    end
end

-- database_operations.addCityToFavorites(api)
-- Adds a city to the favorites list.
function addCityToFavorites(api)
    print("Enter city name:")
    local cityName = io.read()

    local success, info = pcall(api.getCoordinates, api, "city", cityName:gsub(" ", "%%20"))

    if success and info then
        print("City Information:")
        print("Name: " .. info.name)
        print("Country: " .. info.country)
        print("Latitude: " .. info.lat)
        print("Longitude: " .. info.lon)

        print("Do you want to add this city to your favorites? (yes/no)")
        local saveOption = io.read()

        if saveOption:lower() == "yes" then
            local infoToSave = weatherUtils.createInfoTable(info)
            local successSave, errorMessage = pcall(createDataBase, infoToSave)

            if successSave then
                print("Information saved to favorites database.")
            else
                print("Error saving information to favorites database:", errorMessage)
            end
        else
            print("Information not saved to favorites database.")
        end
    else
        print("Failed to retrieve information for city:", cityName)
    end
end

-- database_operations.checkFavoriteCitiesForecast(api)
-- Checks the weather forecast for a city in the favorites list.
function checkFavoriteCitiesForecast(api)
    -- Open the SQLite database
    local db = sqllib.open(Dbfilename)

    if db then
        -- Prepare a SELECT query to retrieve information about favorite cities (name, country, latitude, longitude)
        local stmt = db:prepare("SELECT name, country, lat, lon FROM favourites")
        local favoriteCities = {}
        
        -- Iterate through the query result and insert each city's details into the table
        for row in stmt:nrows() do
            table.insert(favoriteCities, row)
        end
        
        -- Finalize the statement
        stmt:finalize()

        -- Display the list of favorite cities with their details to the user
        print("Favorite Cities:")
        for i, city in ipairs(favoriteCities) do
            print(i .. ". " .. "Country: " .. city.country .. ", City: " .. city.name ..
                    ", Latitude: " .. city.lat .. ", Longitude: " .. city.lon)
        end

        -- Prompt the user to enter the number of the city they want to check
        print("Enter the number of the city to check its weather forecast:")
        local cityNumber = tonumber(io.read())

        if cityNumber and cityNumber >= 1 and cityNumber <= #favoriteCities then
            local selectedCity = favoriteCities[cityNumber]

            -- Retrieve the selected city's weather information using the Weather API
            local successWeather, weatherData = pcall(api.getWeather, api, selectedCity.lat, selectedCity.lon)
            
            if successWeather and weatherData then
                local info = { lat = selectedCity.lat, lon = selectedCity.lon, name = selectedCity.name,  country = selectedCity.country }
                
                -- Create a weather table based on the retrieved data
                local weatherTable = weatherUtils.createWeatherTable(weatherData, info)
                
                -- Print the weather forecast for the selected city
                weatherUtils.printWeatherForecast(weatherTable)
            else
                print("Failed to retrieve weather information for city:", selectedCity.name)
            end
        else
            print("Invalid city number.")
        end

        -- Close the database connection
        db:close()
    else
        print("Error opening the database.")
    end
end

-- Return the module
return {
    createDataBase = createDataBase,
    addCityToFavorites = addCityToFavorites,
    checkFavoriteCitiesForecast = checkFavoriteCitiesForecast,
}
