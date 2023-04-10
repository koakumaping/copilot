local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 180
local moduleHeight = 88

local rxBatt = 0
local rxBattMin = 1024
local rxBattMax = 0

function module.wakeup(widget)
  local source = system.getSource({ name='RxBatt' })
  if source == nil then
    local _rxBatt = 0
    if _rxBatt ~= rxBatt then
      rxBatt = _rxBatt
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  else
    local _rxBatt = source:value()
    if _rxBatt ~= rxBatt then
      rxBatt = _rxBatt
      if _rxBatt > rxBattMax then rxBattMax = _rxBatt end
      if rxBattMin == 0 then rxBattMin = rxBattMax end
      if _rxBatt < rxBattMin then rxBattMin = _rxBatt end
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  end
end

function module.paint(widget, x, y)
  local xStart = x + 15
  local yStart = y

  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  widget.libs.util.drawChar(widget, xStart, yStart, string.format('%04.2f%s', rxBatt, 'V'))

  lcd.color(textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(xStart + 40, yStart + 62, string.format('%04.2f%s%04.2f%s', rxBattMin == widget.libs.var.MAX and 0 or rxBattMin, ' .. ' , rxBattMax, ' v'))
end

return module