local var = require('var')
local util = require('util')
local module = {}

local modelMask = lcd.loadMask('./model-mask.png')

function module.paint(widget, x, y)
  lcd.drawBitmap(x, y, widget.bitmap, var.modelBitmapWidth, var.modelBitmapHeight)
  lcd.color(lcd.RGB(225, 225, 225))
  lcd.drawMask(x, y, modelMask)
end

return module