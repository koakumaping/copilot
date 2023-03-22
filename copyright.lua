local var = dofile('/scripts/copilot/var.lua')
local util = dofile('/scripts/copilot/util.lua')
local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 480
local moduleHeight = 30

local mask = lcd.loadMask('./bitmaps/copyright.png')
local mainStackAvailable = 0
local version = '0.0.0'

function module.wakeup(widget)
  local _mainStackAvailable = system.getMemoryUsage().mainStackAvailable / 1000
  if _mainStackAvailable ~= mainStackAvailable then
    mainStackAvailable = _mainStackAvailable
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  local _version = system.getVersion().version
  if _version ~= version then
    version = _version
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x - 8
  local yStart = y - 8

  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  lcd.color(var.textColor)
  lcd.drawMask(xStart, yStart, mask, 480, 30)
  lcd.drawText(xStart + 8, yStart + 8, string.format('%s(%dKB)', version, mainStackAvailable))
end

return module