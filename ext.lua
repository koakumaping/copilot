local var = require('var')
local util = require('util')
local module = {}

local ext = 0
local extMin = var.MAX
local extMax = 0
local extCell = 0
local extCellMin = 0
local extCellMax = 0

function module.wakeup(widget)
  local source = system.getSource({ name='ADC2' })
  if source == nil then
    local _ext = 0
    if _ext ~= ext then
      ext = _ext
      extCell = 0
      lcd.invalidate()
    end
  else
    local _ext = source:value()
    if _ext ~= ext then
      ext = _ext
      if _ext > extMax then
        extMax = _ext
        extCellMax = _ext / 6
      end
      if extMin == 0 then
        extMin = extMax
        extCellMin = extMax / 6
      end
      if _ext < extMin then
        extMin = _ext
        extCellMin = _ext / 6
      end
      extCell = source:value() / 6
      lcd.invalidate()
    end
  end
end

function module.paint(widget, x, y)
  util.drawChar(widget, x + 15, y, string.format('%04.1f%s', ext, 'V'))

  lcd.color(var.textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 40 + 15, y + 66, string.format('%04.2f%s%04.2f%s', extCellMin == MAX and 0 or extCellMin, ' .. ' , extCellMax, ' v'))
end

function module.paintCell(widget, x, y)
  util.drawChar(widget, x + 15, y, string.format('%04.2f%s', extCell, 'V'))
end

return module