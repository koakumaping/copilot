local var = require('var')
local util = require('util')
local module = {}

local rxBatt = 0
local rxBattMin = var.MAX
local rxBattMax = 0

function module.wakeup(widget)
  local source = system.getSource({ name='RxBatt' })
  if source == nil then
    local _rxBatt = 0
    if _rxBatt ~= rxBatt then
      rxBatt = _rxBatt
      lcd.invalidate()
    end
  else
    local _rxBatt = source:value()
    if _rxBatt ~= rxBatt then
      rxBatt = _rxBatt
      if _rxBatt > rxBattMax then rxBattMax = _rxBatt end
      if rxBattMin == 0 then rxBattMin = rxBattMax end
      if _rxBatt < rxBattMin then rxBattMin = _rxBatt end
      lcd.invalidate()
    end
  end
end

function module.paint(widget, x, y)
  util.drawChar(widget, x + 15, y, string.format('%04.2f%s', rxBatt, 'V'))

  lcd.color(textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 40 + 15, y + 66, string.format('%04.2f%s%04.2f%s', rxBattMin == var.MAX and 0 or rxBattMin, ' .. ' , rxBattMax, ' v'))
end

return module