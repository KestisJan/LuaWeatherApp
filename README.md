# LuaWeatherApp
 
# Lua Weather App

Lua Weather App is a simple command-line application that allows users to retrieve weather forecasts based on city names, ZIP codes, or geographical coordinates. The application uses the OpenWeather API to fetch weather data and can store favorite cities along with their weather forecasts in an SQLite database.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Getting Weather Forecasts](#getting-weather-forecasts)
  - [Managing Favorite Cities](#managing-favorite-cities)
- [Configuration](#configuration)
- [SQLite Database](#sqlite-database)
- [Docker](#docker)
- [Contributing](#contributing)
- [License](#license)

## Installation

To run the Lua Weather App, you need to have Lua installed on your system. Additionally, the application uses some external Lua modules, which you can install using the following command:

```bash
luarocks install lua-http lsqlite3
```

## Usage

### Getting Weather Forecasts

To get weather forecasts, run the `main.lua` script:

```bash
lua main.lua
```

The application will present a menu with various options:

1. **Get weather forecast by city name:** Enter one or more city names separated by commas.
2. **Get weather forecast by ZIP code:** Enter ZIP codes and country codes separated by commas.
3. **Get weather forecast by coordinates:** Enter latitude and longitude pairs separated by commas.
4. **Check favorite cities forecast:** View the weather forecast for cities saved in the favorites list.
5. **Add city to favorite list:** Add a city to the favorites list for quick access.
6. **Remove city from favorite list:** Remove a city from the favorites list.
7. **Exit application:** Terminate the application.

### Managing Favorite Cities

- When adding a city to the favorites list, you can choose to save or discard the information.
- To check the weather forecast for favorite cities, select option 4, choose a city from the list, and view the forecast.
- To remove a city from the favorites list, select option 6, choose a city from the list, and confirm the removal.

## Configuration

The application uses a configuration file, `config.lua`, to store OpenWeather API key, language code, and data format. You can set environment variables for these configurations or modify the `config.lua` file directly.

Example `config.lua`:

```lua
return {
    apiKey = os.getenv("WEATHER_API_KEY"),
    lang = os.getenv("WEATHER_LANG"),
    mode = os.getenv("WEATHER_MODE"),
}
```

## SQLite Database

The application stores information about favorite cities and their weather forecasts in an SQLite database. The default database file is named `initial-db.sqlite`. You can customize the database file path in the `database_operations.lua` file.

## Docker

This application can be run within a Docker container. A Dockerfile and Docker Compose configuration are provided for easy containerization. Make sure to follow the [Docker instructions](#docker) to build and run the Docker containers.

## Contributing

If you'd like to contribute to this project, feel free to open issues or submit pull requests. Contributions are welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.