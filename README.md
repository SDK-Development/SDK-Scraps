## Description
SDK-Scraps is a FiveM script that allows players to search for scraps and sell them to an NPC. The script is compatible with both ESX and QBCore frameworks.

## Features
* Start and stop working by interacting with an NPC
* Search for scraps in predefined locations
* Sell found items to the NPC
* Configurable item list and prices
* Debug messages for easier troubleshooting

## Installation
1. Download the script and place it in your `resources` folder.
2. Make sure to setup everything inside `config.lua` for everything to work as expected.
3. Add the following line to your `server.cfg`: `ensure SDK-Scraps`

## Configuration
Edit the `config.lua` file to customize the script settings:
* `Config.Framework`: Set to "ESX" or "QBCore" depending on your server's framework.
* `Config.Debug`: Enable or disable debug messages.
* `Config.Objects`: List of objects that will be spawned once the job starts.
* `Config.ObjectPossibleLocations`: List of possible locations for the objects.
* `Config.MarkerSettings`: Settings for the markers displayed on the map.
* `Config.SearchTime`: Time in milliseconds to search in the objects.
* `Config.NPC`: Settings for the NPC that gives the job.
* `Config.PossibleItems`: List of items that can be found while searching and their sell prices.
* `Config.Messages`: Customizable messages displayed to the player.
* `Config.Blip`: Settings for the blip displayed on the map.

## Usage
1. Start the script by interacting with the NPC.
2. Search for scraps in the predefined locations.
3. Sell the found items to the NPC.

## Dependencies
* ox_lib
* oxmysql

## Contribution
Every issues reported/pull request is appreciated; however when contributing make sure to include one of these tags here (in the commits/issue name) to help us address the issue better!
- (fix) Use this tag if there's actually a problem with already written code, maybe a nil error, maybe some simple mistakes.
- (feat) Use this one instead when adding (or suggesting) to new features!
- (refactor) Use this last one when you didn't actually fixed any bug, just changed the general structure of the code.

Thanks <3

## License
This project is licensed under the MIT License. See the LICENSE file for details.