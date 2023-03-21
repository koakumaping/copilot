local var = require('var')
local util = require('util')
local module = {}

function module.paint(widget, x, y)
  lcd.color(var.textColor)
  util.drawChar(widget, x + 15, y, string.format('%04d', widget.flyCounts))
end

return module