local module = {}

local mask = lcd.loadMask('./bitmaps/time.png')

local moduleX = 0
local moduleY = 0
local moduleWidth = 48 * 4 + 22
local moduleHeight = 90

local flyTime = 0
local lastFlyTime = 0
local allTime = 0

function module.wakeup(widget)
  local _direction = model.getTimer(0):direction()
  local _resetCondition = model.getTimer(0):resetCondition():value()
  local _flyTime = tonumber(model.getTimer(0):value())
  local _allTime = tonumber(model.getTimer(1):value())

  if _flyTime ~= flyTime then
    flyTime = _flyTime
    if _resetCondition < 0 then
      lastFlyTime = _direction < 0 and model.getTimer(0):start() - _flyTime or _flyTime
    end
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if _allTime ~= allTime then
    allTime = _allTime
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x + 33
  local yStart = y

  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  local flyTimeSeconds = string.format('%02d', flyTime % 60)
  local flyTimeMinutes = flyTime - flyTimeSeconds >= 0 and string.format('%02d', (flyTime - flyTimeSeconds) / 60) or string.format('%01d', (flyTime - flyTimeSeconds) / 60)

  local lastFlyTimeSeconds = string.format('%02d', lastFlyTime % 60)
  local lastFlyTimeMinutes = string.format('%02d', (lastFlyTime - lastFlyTimeSeconds) / 60) 

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

  widget.libs.util.drawChar(widget, xStart, yStart, string.format('%s:%s', flyTimeMinutes, flyTimeSeconds))
  lcd.color(widget.libs.var.textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 86, yStart + 65, string.format('%s:%s .. %s:%s', lastFlyTimeMinutes, lastFlyTimeSeconds, allTimeHour, allTimeMinutes))

  -- lcd.color(widget.libs.var.themeColor)
  -- lcd.drawFilledRectangle(xStart + 2 + 4, yStart + 69 + 2, 200, 16)
  -- lcd.color(widget.libs.var.textColor)
  -- lcd.drawMask(xStart + 4, yStart + 69, mask)
end

return module