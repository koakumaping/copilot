local var = dofile('/scripts/copilot/var.lua')
local util = dofile('/scripts/copilot/util.lua')
local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 280
local moduleHeight = 70

local channelMask = lcd.loadMask('./bitmaps/channel.png')

local size = 60
local width = 18
local borderWidth = 2
local fix = 6

local p1 = 0
local p2 = var.MIN
local p3 = 0
local p4 = 0
local p5 = 0
local p6 = 0
local p7 = 0
local p8 = 0

local channelTable = { 0, 0, var.MIN, 0, 0, 0, 0, 0 }
local channelNameTable = { 'p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8' }

padding = 18 + var.padding

function drawChannel(index, value)
  index = index - 1
  lcd.color(var.themeColor)
  lcd.drawFilledRectangle(
    moduleX + padding * index + borderWidth,
    moduleY + borderWidth + 28,
    width - borderWidth * 2,
    util.convertChannel(value)
  )
  lcd.color(var.textColor)
  lcd.drawMask(moduleX + padding * index, moduleY, channelMask)
end

function module.wakeup(widget)
  local chTable = {
    system.getSource({category=CATEGORY_CHANNEL, member=0}):value(),
    system.getSource({category=CATEGORY_CHANNEL, member=1}):value(),
    system.getSource({category=CATEGORY_CHANNEL, member=2}):value(),
    system.getSource({category=CATEGORY_CHANNEL, member=3}):value(),
    system.getSource({category=CATEGORY_CHANNEL, member=4}):value(),
    system.getSource({category=CATEGORY_CHANNEL, member=5}):value(),
    system.getSource({category=CATEGORY_CHANNEL, member=6}):value(),
    system.getSource({category=CATEGORY_CHANNEL, member=7}):value(),
  }
  -- print(chTable)

  for i, v in ipairs(chTable) do
    if channelTable[i] ~= v then
      channelTable[i] = v
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
      -- print(i, v, chTable[i])
    end
  end

  -- if ch1 ~= p1 then
  --   p1 = ch1
  --   lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  -- end

  -- if ch2 ~= p2 then
  --   p2 = ch2
  --   lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  -- end

  -- if ch3 ~= p3 then
  --   p3 = ch3
  --   lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  -- end

  -- if ch4 ~= p4 then
  --   p4 = ch4
  --   lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  -- end
end

function module.paint(widget, x, y)
  local xStart = x + 12
  local yStart = y

  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  for i, v in ipairs(channelTable) do
    drawChannel(i, v)
  end

  -- lcd.color(var.themeColor)
  -- lcd.drawFilledRectangle(xStart + borderWidth, yStart + borderWidth + 28, width - borderWidth * 2, -28)
  -- lcd.color(var.textColor)
  -- lcd.drawMask(xStart + padding * 0, yStart, channelMask)

  -- lcd.color(var.textColor)
  -- lcd.drawMask(xStart + padding * 1, yStart, channelMask)
  -- lcd.drawMask(xStart + padding * 2, yStart, channelMask)
  -- lcd.drawMask(xStart + padding * 3, yStart, channelMask)
  -- lcd.drawMask(xStart + padding * 4, yStart, channelMask)
  -- lcd.drawMask(xStart + padding * 5, yStart, channelMask)
  -- lcd.drawMask(xStart + padding * 6, yStart, channelMask)
  -- lcd.drawMask(xStart + padding * 7, yStart, channelMask)
end

return module