local module = {}

local moduleX = 332
local moduleY = 128
local moduleWidth = 120
local moduleHeight = 80

local topLeftMask = lcd.loadMask('./bitmaps/tl.png')
local topRightMask = lcd.loadMask('./bitmaps/tr.png')
local bottomLeftMask = lcd.loadMask('./bitmaps/bl.png')
local bottomRightMask = lcd.loadMask('./bitmaps/br.png')

local messageMask = lcd.loadMask('./bitmaps/message.png')

message = ''
messageStartTime = 0
messageEndTime = 0

function draw(widget)
  lcd.font(FONT_XXL)
  local textW, textH = lcd.getTextSize(message)
  moduleWidth = textW + 16
  moduleHeight = textH + 16

  moduleX = (widget.w - moduleWidth) / 2

  lcd.color(lcd.RGB(255, 255, 255, 0.6))
  lcd.drawFilledRectangle(moduleX, moduleY, moduleWidth, moduleHeight)

  -- lcd.color(lcd.RGB(255, 255, 255, 0))
  -- lcd.drawMask(moduleX, moduleY, topLeftMask)
  -- lcd.drawMask(moduleX + moduleWidth - 6, moduleY, topRightMask)
  -- lcd.drawMask(moduleX, moduleY + moduleHeight - 6, bottomLeftMask)
  -- lcd.drawMask(moduleX + moduleWidth - 6, moduleY + moduleHeight - 6, bottomRightMask)
  lcd.color(widget.libs.var.textColor)
  lcd.drawText(moduleX + 8, moduleY + 8, message)
  -- if f then f(widget, x + 8, y + 8) end
end

function module.push(value)
  message = value

  local time = os.clock()
  messageStartTime = time
  messageEndTime = time + 3
end

function module.wakeup(widget)
  lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
end

function module.paint(widget, x, y)
  if message ~= '' then
    if messageEndTime <= os.clock() then
      message = ''
      lcd.setClipping(moduleX, moduleY, moduleWidth, moduleHeight)
      -- print('message unpainted', os.clock())
    end
    -- lcd.color(widget.libs.var.textColor)
    -- lcd.drawMask(moduleX, moduleY, messageMask)
    -- lcd.color(widget.libs.var.whiteColor)
    -- lcd.drawText(moduleX + 16, moduleY + 16, message)
    draw(widget)
    -- print('message painted', os.clock())
  end
end

return module