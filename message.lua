local module = {}

local moduleX = 332
local moduleY = 128
local moduleWidth = 120
local moduleHeight = 80

local messageMask = lcd.loadMask('./bitmaps/message.png')

function module.push(widget, value)
  widget.message = value

  local time = os.clock()
  widget.messageStartTime = time
  widget.messageEndTime = time + 5
end

function module.wakeup(widget)
  lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
end

function module.paint(widget, x, y)
  if widget.message ~= '' then
    if widget.messageEndTime <= os.clock() then
      widget.message = ''
      lcd.setClipping(moduleX, moduleY, moduleWidth, moduleHeight)
      print('message unpainted', os.clock())
    end
    lcd.color(widget.libs.var.textColor)
    lcd.drawMask(moduleX, moduleY, messageMask)
    print('message painted', os.clock())
  end
end

return module