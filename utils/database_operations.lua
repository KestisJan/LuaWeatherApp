-- Load the SQLite library
local sqllib = require('lsqlite3')

-- Specify the path to the SQLite database file
local Dbfilename = '/home/kestas/Sqlite/initial-db.sqlite'

-- createDataBase(info)
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
        local favoritesTable = createInfoTable(info)

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

-- addCityToFavorites(api)
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
            local infoToSave = createInfoTable(info)
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

-- Return the module
return {
    createDataBase = createDataBase,
    addCityToFavorites = addCityToFavorites,
}
