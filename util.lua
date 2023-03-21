local var = require('var')

local module = {}

local number0 = lcd.loadMask('./0.png')
local number1 = lcd.loadMask('./1.png')
local number2 = lcd.loadMask('./2.png')
local number3 = lcd.loadMask('./3.png')
local number4 = lcd.loadMask('./4.png')
local number5 = lcd.loadMask('./5.png')
local number6 = lcd.loadMask('./6.png')
local number7 = lcd.loadMask('./7.png')
local number8 = lcd.loadMask('./8.png')
local number9 = lcd.loadMask('./9.png')
local colon = lcd.loadMask('./colon.png')
local dot = lcd.loadMask('./dot.png')
local minus = lcd.loadMask('./minus.png')
local charV = lcd.loadMask('./V.png')
local charS = lcd.loadMask('./S.png')

local topLeftMask = lcd.loadMask('./tl.png')
local topRightMask = lcd.loadMask('./tr.png')
local bottomLeftMask = lcd.loadMask('./bl.png')
local bottomRightMask = lcd.loadMask('./br.png')

function module.getCharMask(value)
  if value == 0 or value == '0' then return number0 end
  if value == 1 or value == '1' then return number1 end
  if value == 2 or value == '2' then return number2 end
  if value == 3 or value == '3' then return number3 end
  if value == 4 or value == '4' then return number4 end
  if value == 5 or value == '5' then return number5 end
  if value == 6 or value == '6' then return number6 end
  if value == 7 or value == '7' then return number7 end
  if value == 8 or value == '8' then return number8 end
  if value == 9 or value == '9' then return number9 end

  if value == '.' then return dot end
  if value == '-' then return minus end

  if value == 'S' then return charS end
  if value == 'V' then return charV end
  return colon
end

function module.drawChar(widget, x, y, value)
  lcd.color(var.textColor)
  local s = tostring(value)
  local xStart = x

  for i = 1, string.len(s) do
    local current = string.sub(s, i, i)
    lcd.drawMask(xStart, y, module.getCharMask(current))
    if current == '.' or current == ':' then
      xStart = xStart + var.dotWidth
    else
      xStart = xStart + var.fontWidth
    end
  end
end

function module.drawBox(widget, x, y, w, h, title, f)
  local titleHeight = 36
  local fixTitleHeight = 8

  -- title
  if title ~= '' then
    fixTitleHeight = titleHeight
    h = h + titleHeight
  end

  lcd.color(lcd.RGB(225, 225, 225))
  lcd.drawFilledRectangle(x, y, w, h)
  -- title
  if title ~= '' then
    lcd.font(FONT_STD)
    -- lcd.font(lcd.loadFont('xxxl.fnt'))
    lcd.color(textColor)
    lcd.drawText( x + 8, y + 6, title)
  end
  lcd.color(widget.bgColor)
  lcd.drawMask(x, y, topLeftMask)
  lcd.drawMask(x + w - 6, y, topRightMask)
  lcd.drawMask(x, y + h - 6, bottomLeftMask)
  lcd.drawMask(x + w - 6, y + h - 6, bottomRightMask)

  if f then f(widget, x + 8, y + fixTitleHeight) end
end

function module.calcTrim(value)
  local base = 30
  local max = 1024
  local minus = 1
  if value < 0 then
    minus = -1
    value = -value
  end

  if value == 0 then
    return 0
  end
  if value < 10 then
    return minus * 1
  end
  if value < 20 then
    return minus * 2
  end
  if value < 30 then
    return minus * 3
  end
  if value < 50 then
    return minus * 4
  end
  if value < 70 then
    return minus * 5
  end
  if value < 90 then
    return minus * 6
  end
  if value < 110 then
    return minus * 7
  end
  if value < 130 then
    return minus * 8
  end
  if value < 160 then
    return minus * 9
  end
  if value < 190 then
    return minus * 10
  end
  if value < 210 then
    return minus * 11
  end
  if value < 250 then
    return minus * 12
  end
  if value < 290 then
    return minus * 13
  end
  if value < 330 then
    return minus * 14
  end
  if value < 370 then
    return minus * 15
  end
  if value < 420 then
    return minus * 16
  end
  if value < 460 then
    return minus * 17
  end
  if value < 500 then
    return minus * 18
  end
  if value < 540 then
    return minus * 19
  end
  if value < 600 then
    return minus * 20
  end
  if value < 660 then
    return minus * 21
  end
  if value < 720 then
    return minus * 22
  end
  if value < 780 then
    return minus * 23
  end
  if value < 840 then
    return minus * 24
  end
  if value < 880 then
    return minus * 25
  end
  if value < 920 then
    return minus * 26
  end
  if value < 960 then
    return minus * 27
  end
  if value < 1000 then
    return minus * 28
  end
  if value < 1024 then
    return minus * 29
  end

  return minus * 30
end

function module.calc1024(value)
  local base = 30
  local max = 1024
  return math.floor(value * base / max)
end

return module