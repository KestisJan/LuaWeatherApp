-- config.lua

-- Load configuration from environment variables

return {
    -- OpenWeather API key for accessing weather data
    apiKey = os.getenv("WEATHER_API_KEY"),

    -- Language code for weather data ( 'lt' for Lithuanian )
    lang = os.getenv("WEATHER_LANG"),

    -- Data format for weather response ( 'json' )
    mode = os.getenv("WEATHER_MODE"),
}