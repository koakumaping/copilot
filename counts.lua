local var = dofile('/scripts/copilot/var.lua')
local util = dofile('/scripts/copilot/util.lua')
local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 180
local moduleHeight = 50

function module.paint(widget, x, y)
  local xStart = x + 15
  local yStart = y
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  lcd.color(var.textColor)
  util.drawChar(widget, xStart, yStart, string.format('%04d', widget.flyCounts))
end

return module