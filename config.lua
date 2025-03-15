Config = {}

Config.Framework = "ESX" -- ESX or QBCore
Config.Debug = true -- Enable/Disable Debug Messages.
Config.Objects = { -- List of cars that will be spawned once the Job Starts.
  "prop_rub_carwreck_5",
  "prop_rub_carwreck_12",
  "prop_rub_carwreck_10"
}

Config.ObjectPossibleLocations = {
  vec3(-507.3837, -1733.6520, 19.0925),
  vec3(-524.7146, -1722.5188, 19.1263),
  vec3(-523.0551, -1708.9414, 19.3213)
}

Config.MarkerSettings = {
  Type = 2, -- Type of the marker
  Color = {r = 255, g = 20, b = 20, a = 70}, -- Color of the marker using RGB
  Bouncing = true -- Should the marker bounce?
}

Config.SearchTime = 5000 -- Time in milliseconds to search in the "cars".

Config.NPC = {
  Location = vec4(-499.8662, -1714.1547, 19.8991, 98.8228), -- Location of the NPC that will give the job.
  Model = "a_m_m_farmer_01", -- Model of the NPC
}

Config.PossibleItems = { -- List of items that can be found while searching in the "cars" and that can be sold.
  {name="water", amount={1, 3}, sellPrice=10},
  {name="bread", amount={1, 2}, sellPrice=5},
  {name="cola", amount={3, 8}, sellPrice=3},
}

Config.Messages = {
  START_WORKING = 'Start Working',
  STOP_WORKING = 'Stop Working',
  SELL_ITEMS = 'Sell Items',
  SEARCH = 'Search Scraps',
  SEARCHING_SCRAPS = 'Searching Scraps',
  ITEM_FOUND = 'You found an item!',
  ITEMS_SOLD = "You sold your scraps!",
  NO_ITEMS_TO_SELL = "You don't have any items to sell",
  MUST_WORK_TO_SELL = 'You must be in service to sell items',
  STOPPED_WORKING = 'You stopped working',
  STARTED_WORKING = 'You started working',
}

Config.BlipScraps = {
  Sprite = 1,
  Color = 1,
  Scale = 0.65,
  Name = "Car Scraps"
}

Config.BlipStart = {
  Sprite = 478,
  Color = 33,
  Scale = 0.85,
  Name = "Recycler"
}