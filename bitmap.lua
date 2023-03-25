local module = {}

local modelMask = lcd.loadMask('./bitmaps/model-mask.png')
-- local bitmap = lcd.loadBitmap(model.bitmap())

function module.paint(widget, x, y)
  if widget.bitmap ~= nil then
    lcd.drawBitmap(x, y, widget.bitmap, widget.libs.var.modelBitmapWidth, widget.libs.var.modelBitmapHeight)
    lcd.color(lcd.RGB(225, 225, 225))
    lcd.drawMask(x, y, modelMask)
  end
end

return module