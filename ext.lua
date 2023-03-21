local var = require('var')
local util = require('util')
local module = {}

function module.wakeup(widget)
  local source = system.getSource({ name='ADC2' })
  if source == nil then
    local ext = 0
    if ext ~= widget.ext then
      widget.ext = ext
      widget.extCell = 0
      lcd.invalidate()
    end
  else
    local ext = source:value()
    if ext ~= widget.ext then
      widget.ext = ext
      if ext > widget.extMax then
        widget.extMax = ext
        widget.extCellMax = ext / 6
      end
      if widget.extMin == 0 then
        widget.extMin = widget.extMax
        widget.extCellMin = widget.extMax / 6
      end
      if ext < widget.extMin then
        widget.extMin = ext
        widget.extCellMin = ext / 6
      end
      widget.extCell = source:value() / 6
      lcd.invalidate()
    end
  end
end

function module.paint(widget, x, y)
  util.drawChar(widget, x + 15, y, string.format('%04.1f%s', widget.ext, 'V'))

  lcd.color(var.textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 40 + 15, y + 66, string.format('%04.2f%s%04.2f%s', widget.extCellMin == MAX and 0 or widget.extCellMin, ' .. ' , widget.extCellMax, ' v'))
end

return module