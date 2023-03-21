local var = require('var')
local util = require('util')
local module = {}

local Rud = 0
local Ele = 1
local Thr = 2
local Ail = 3
local step = 8

function module.wakeup(widget)
  local trim1 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Ail}):value())
  local trim2 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Ele}):value())
  local trim3 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Thr}):value())
  local trim4 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Rud}):value())
  local p1 = util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=0}):value())
  local p2 = -util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=1}):value())
  local p3 = -util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=2}):value())
  local p4 = util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=3}):value())

  if trim1 ~= widget.trim1 then
    widget.trim1 = trim1
    lcd.invalidate()
  end

  if trim2 ~= widget.trim2 then
    widget.trim2 = trim2
    lcd.invalidate()
  end

  if trim3 ~= widget.trim3 then
    widget.trim3 = trim3
    lcd.invalidate()
  end

  if trim4 ~= widget.trim4 then
    widget.trim4 = trim4
    lcd.invalidate()
  end

  if p1 ~= widget.p1 then
    widget.p1 = p1
    lcd.invalidate()
  end

  if p2 ~= widget.p2 then
    widget.p2 = p2
    lcd.invalidate()
  end

  if p3 ~= widget.p3 then
    widget.p3 = p3
    lcd.invalidate()
  end

  if p4 ~= widget.p4 then
    widget.p4 = p4
    lcd.invalidate()
  end
end

function module.paint(widget, x, y)
  local size = 65 + 2

  local xStart = x
  local yStart = y

  local borderColor = lcd.RGB(0, 0, 0, 0.4)
  local themeColor = widget.mainColor
  local themeBgColor = var.themeBgColor

  local trim1 = widget.trim1
  local trim2 = widget.trim2
  local trim3 = widget.trim3
  local trim4 = widget.trim4

  -- left
  local xLeft = xStart
  local yLeft = yStart
  local xLeftCenter = xLeft + (size - 2 - 1) / 2 + 1
  local yLeftCenter = yLeft + (size - 2 - 1) / 2 + 1
  lcd.color(borderColor)
  lcd.drawRectangle(xLeft, yLeft, size, size)
  lcd.color(widget.mainColor)
  lcd.drawFilledCircle(xLeftCenter + widget.p4, yLeftCenter + widget.p3, 5)
  -- left trim
  -- 4
  lcd.color(borderColor)
  lcd.drawLine(xLeftCenter, size + 3, xLeftCenter, size + 4 + 4)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xLeftCenter - 30, size + 4, 30, 4)
  lcd.drawFilledRectangle(xLeftCenter + 1, size + 4, 30, 4)

  lcd.color(widget.mainColor)
  if trim4 < 0 then
    lcd.drawFilledRectangle(xLeftCenter + trim4, size + 4, -trim4, 4)
  elseif trim4 > 0 then
    lcd.drawFilledRectangle(xLeftCenter + 1, size + 4, trim4, 4)
  end

  -- 3
  lcd.color(borderColor)
  lcd.drawLine(xLeft - 4 - 4 - 1, 4 + 30, xLeft - 4, 4 + 30)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xLeft - 4 - 4, 4 + 30 + 1, 4, 30)
  lcd.drawFilledRectangle(xLeft - 4 - 4, 4, 4, 30)

  lcd.color(widget.mainColor)
  if trim3 < 0 then
    lcd.drawFilledRectangle(xLeft - 4 - 4, 4 + 30 + 1, 4, -trim3)
  elseif trim3 > 0 then
    lcd.drawFilledRectangle(xLeft - 4 - 4, 4 + 30 - trim3, 4, trim3)
  end

  --right
  local xRight = xLeft + size + 16
  local yRight = yStart
  local xRightCenter = xRight + (size - 2 - 1) / 2 + 1
  local yRightCenter = yRight + (size - 2 - 1) / 2 + 1
  lcd.color(borderColor)
  lcd.drawRectangle(xRight, yRight, size, size)
  lcd.color(widget.mainColor)
  lcd.drawFilledCircle(xRightCenter + widget.p1, yRightCenter + widget.p2, 5)

  -- right trim
  -- 2
  lcd.color(borderColor)
  lcd.drawLine(xRight + size + 4 - 1, 4 + 30, xRight + size + 4 - 1 + 5, 4 + 30)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xRight + size + 4, 4, 4, 30)
  lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 + 1, 4, 30)

  lcd.color(widget.mainColor)
  -- lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 - 14, 4, 14)
  -- lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 + 1, 4, 10)
  if trim2 < 0 then
    lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 + 1, 4, -trim2)
  elseif trim2 > 0 then
    lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 - trim2, 4, trim2)
  end

  -- 1
  lcd.color(borderColor)
  lcd.drawLine(xRightCenter, size + 3, xRightCenter, size + 4 + 4)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xRightCenter - 30, size + 4, 30, 4)
  lcd.drawFilledRectangle(xRightCenter + 1, size + 4, 30, 4)

  lcd.color(widget.mainColor)
  if trim1 < 0 then
    lcd.drawFilledRectangle(xRightCenter + trim1, size + 4, -trim1, 4)
  elseif trim1 > 0 then
    lcd.drawFilledRectangle(xRightCenter + 1, size + 4, trim1, 4)
  end
end

return module