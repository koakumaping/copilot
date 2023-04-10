local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 180
local moduleHeight = 180

local ext = 0
local extMin = 1024
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
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
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
      lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
    end
  end
end

function module.paint(widget, x, y)
  local xStart = x
  local yStart = y
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  widget.libs.util.drawChar(widget, xStart + 15, yStart, string.format('%04.1f%s', ext, 'V'))

  lcd.color(widget.libs.var.textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(xStart + 40 + 15, yStart + 62, string.format('%04.2f%s%04.2f%s', extCellMin == MAX and 0 or extCellMin, ' .. ' , extCellMax, ' v'))
end

function module.paintCell(widget, xStart, yStart)
  widget.libs.util.drawChar(widget, xStart + 15, yStart - 4, string.format('%04.2f%s', extCell, 'V'))
end

return module