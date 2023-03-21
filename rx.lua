local var = require('var')
local util = require('util')
local module = {}

function module.wakeup(widget)
  local source = system.getSource({ name='RxBatt' })
  if source == nil then
    local rxBatt = 0
    if rxBatt ~= widget.rxBatt then
      widget.rxBatt = rxBatt
      lcd.invalidate()
    end
  else
    local rxBatt = source:value()
    if rxBatt ~= widget.rxBatt then
      widget.rxBatt = rxBatt
      if rxBatt > widget.rxBattMax then widget.rxBattMax = rxBatt end
      if widget.rxBattMin == 0 then widget.rxBattMin = widget.rxBattMax end
      if rxBatt < widget.rxBattMin then widget.rxBattMin = rxBatt end
      lcd.invalidate()
    end
  end
end

function module.paint(widget, x, y)
  util.drawChar(widget, x + 15, y, string.format('%04.2f%s', widget.rxBatt, 'V'))

  lcd.color(textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 40 + 15, y + 66, string.format('%04.2f%s%04.2f%s', widget.rxBattMin == var.MAX and 0 or widget.rxBattMin, ' .. ' , widget.rxBattMax, ' v'))
end

return module