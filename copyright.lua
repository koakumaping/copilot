local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 480
local moduleHeight = 30

local mask = lcd.loadMask('./bitmaps/copyright.png')
local version = '0.0.0'

local luaRamAvailable = 0

function module.wakeup(widget)
  local _luaRamAvailable = system.getMemoryUsage().luaRamAvailable / 1000
  if _luaRamAvailable ~= luaRamAvailable then
    luaRamAvailable = _luaRamAvailable
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
  local yStart = y - 8 - 4

  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  lcd.color(widget.libs.var.textColor)
  lcd.drawMask(xStart, yStart, mask, 480, 30)
  lcd.drawText(xStart + 58, yStart + 8, version)
  lcd.drawText(xStart + 108, yStart + 8, luaRamAvailable)
end

return module