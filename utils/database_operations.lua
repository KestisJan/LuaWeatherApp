-- Import the lsqlite3 library for SQLite database operations
local sqllib = require('lsqlite3')

-- Create a namespace (table) to encapsulate database-related operations
local DatabaseOperations = {}

-- DatabaseOperations.create_db(info)
-- Creates or opens an SQLite database and stores information about a favorite location.

function DatabaseOperations.create_db(info)
    -- Load the SQLite library
    local sqllib = require('lsqlite3')

    -- Specify the path to the SQLite database file
    local Dbfilename = '/home/kestas/Sqlite/initial-db.sqlite'

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



return DatabaseOperations