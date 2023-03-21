local var = require('var')
local util = require('util')
local module = {}

local flyTimeX = 0
local flyTimeY = 0
local flyTimeWidth = 48 *4 + 22
local flyTimeHeight = 60

local flyTime = 0
local allTime = 0

function module.wakeup(widget)
  local _flyTime = tonumber(model.getTimer(0):value())
  local allTime = tonumber(model.getTimer(1):value())
  if _flyTime ~= flyTime then
    flyTime = _flyTime
    lcd.invalidate(flyTimeX, flyTimeY, flyTimeWidth, flyTimeHeight)
  end

  if _allTime ~= allTime then
    allTime = _allTime
    lcd.invalidate(flyTimeX, flyTimeY, flyTimeWidth, flyTimeHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x + 33
  local yStart = y

  if flyTimeX ~= xStart then flyTimeX = xStart end
  if flyTimeY ~= yStart then flyTimeY = yStart end

  local flyTimeSeconds = string.format('%02d', flyTime % 60)
  local flyTimeMinutes = string.format('%02d', (flyTime - flyTimeSeconds) / 60)

  local allTimeHour = string.format('%02d', math.floor(allTime / 3600))
  local allTimeMinutes = string.format('%02d', math.floor((allTime - allTimeHour * 3600) / 60))

  -- if switchTable[5] > 0 then
  --   if flyTimeSeconds % 2 == 0 then
  --     lcd.color(blackColor)
  --   else
  --     lcd.color(themeBgColor)
  --   end
  -- else
  --   lcd.color(blackColor)
  -- end

  util.drawChar(widget, xStart, yStart, string.format('%s:%s', flyTimeMinutes, flyTimeSeconds))
  lcd.color(var.textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(xStart + 5, y + 66, 'Latabu')
  lcd.drawText(x + 176, y + 66, string.format('%s:%s', allTimeHour, allTimeMinutes))
end

return module