ESX,QBCore = nil, nil

if Config.Framework == "ESX" then
  ESX = exports["es_extended"]:getSharedObject()
elseif Config.Framework == "QBCore" then
  QBCore = exports["qb-core"]:getModule("QBCore")
end

Notification = function(message, type)
  if not message then return end
  lib.notify({
      title = 'Recycling',
      description = message,
      type = type or 'info'
  })
end

Debug = function(...)
  if not Config.Debug then return end
  print('^3[SDK-Recycling]^7', ...)
end