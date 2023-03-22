local var = dofile('/scripts/copilot/var.lua')

local module = {}

local number0 = lcd.loadMask('./bitmaps/0.png')
local number1 = lcd.loadMask('./bitmaps/1.png')
local number2 = lcd.loadMask('./bitmaps/2.png')
local number3 = lcd.loadMask('./bitmaps/3.png')
local number4 = lcd.loadMask('./bitmaps/4.png')
local number5 = lcd.loadMask('./bitmaps/5.png')
local number6 = lcd.loadMask('./bitmaps/6.png')
local number7 = lcd.loadMask('./bitmaps/7.png')
local number8 = lcd.loadMask('./bitmaps/8.png')
local number9 = lcd.loadMask('./bitmaps/9.png')
local colon = lcd.loadMask('./bitmaps/colon.png')
local dot = lcd.loadMask('./bitmaps/dot.png')
local minus = lcd.loadMask('./bitmaps/minus.png')
local charV = lcd.loadMask('./bitmaps/V.png')
local charS = lcd.loadMask('./bitmaps/S.png')

local topLeftMask = lcd.loadMask('./bitmaps/tl.png')
local topRightMask = lcd.loadMask('./bitmaps/tr.png')
local bottomLeftMask = lcd.loadMask('./bitmaps/bl.png')
local bottomRightMask = lcd.loadMask('./bitmaps/br.png')

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

function module.convertTrim(value)
  local MAX = 1000
  if value > MAX then value = MAX end
  if value < -MAX then value = -MAX end

  local fixedValue = value + MAX
  local step = 40

  -- fix center if trim value is very small

  if value > 0 and value < step then fixedValue = MAX + step end
  if value < 0 and value > -step then fixedValue = MAX - step end

  return fixedValue // 40
end

function module.convertReverseTrim(value)
  local MAX = 1000
  if value > MAX then value = MAX end
  if value < -MAX then value = -MAX end

  local fixedValue = value + MAX
  local step = 40

  -- fix center if trim value is very small

  if value > 0 and value < step then fixedValue = MAX + step end
  if value < 0 and value > -step then fixedValue = MAX - step end

  return 2000 / step - fixedValue // 40
end

function module.calc1024(value)
  local base = 30
  local max = 1024
  return math.floor(value * base / max)
end

return module