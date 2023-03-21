local var = require('var')
local util = require('util')
local module = {}

local switchSurfaceX = 0
local switchSurfaceY = 0
local switchSurfaceWidth = 280
local switchSurfaceHeight = 40

local switchBitmap = lcd.loadBitmap('./bitmaps/check_sw_bg.png')
local switchUpMask = lcd.loadMask('./bitmaps/check_sw_up.png')
local switchMidMask = lcd.loadMask('./bitmaps/check_sw_mid.png')
local switchDownMask = lcd.loadMask('./bitmaps/check_sw_down.png')

function indexOf(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return nil
end

function getSwitchValue(widget, name)
  local index = indexOf(widget.switchNameTable, name)
  return widget.switchTable[index]
end

function paintSwitch(widget, xStart, yStart, name, index)
  local borderWidth = 2
  local paddingRight = 8
  local width = 27
  local height = 27
  local activeHeight = (height - 4) / 2

  local value = getSwitchValue(widget, name)

  lcd.drawBitmap(xStart + (paddingRight + width) * index, yStart, switchBitmap)

  if value < 0 then lcd.color(widget.mainColor) else lcd.color(var.greyColor) end
  lcd.drawMask(xStart + (paddingRight + width) * index + 7, yStart + 1, switchUpMask)

  if indexOf(widget.switchTwoStageNameTable, name) == nil then
    if value == 0 then lcd.color(widget.mainColor) else lcd.color(greyColor) end
    lcd.drawMask(xStart + (paddingRight + width) * index + 10, yStart + 10, switchMidMask)
  end

  if value > 0 then lcd.color(widget.mainColor) else lcd.color(var.greyColor) end
  lcd.drawMask(xStart + (paddingRight + width) * index + 7, yStart + 18, switchDownMask)
end

function module.wakeup(widget)
  local SA = system.getSource('SA'):value()
  local SB = system.getSource('SB'):value()
  local SC = system.getSource('SC'):value()
  local SD = system.getSource('SD'):value()
  local SE = system.getSource('SE'):value()
  local SF = system.getSource('SF'):value()
  local SG = system.getSource('SG'):value()
  local SH = system.getSource('SH'):value()
  local SI = system.getSource('SI'):value()
  local SJ = system.getSource('SJ'):value()

  if SA ~= widget.switchTable[1] then
    widget.switchTable[1] = SA
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SB ~= widget.switchTable[2] then
    widget.switchTable[2] = SB
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SC ~= widget.switchTable[3] then
    widget.switchTable[3] = SC
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SD ~= widget.switchTable[4] then
    widget.switchTable[4] = SD
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SE ~= widget.switchTable[5] then
    widget.switchTable[5] = SE
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SF ~= widget.switchTable[6] then
    widget.switchTable[6] = SF
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SG ~= widget.switchTable[7] then
    widget.switchTable[7] = SG
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SH ~= widget.switchTable[8] then
    widget.switchTable[8] = SH
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SI ~= widget.switchTable[9] then
    widget.switchTable[9] = SI
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end

  if SJ ~= widget.switchTable[10] then
    widget.switchTable[10] = SJ
    lcd.invalidate(switchSurfaceX, switchSurfaceY, switchSurfaceWidth, switchSurfaceHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x + 4
  local yStart = y

  switchSurfaceX = xStart
  switchSurfaceY = yStart

  paintSwitch(widget, xStart, yStart, 'SE', 0)
  paintSwitch(widget, xStart, yStart, 'SF', 1)
  paintSwitch(widget, xStart, yStart, 'SA', 2)
  paintSwitch(widget, xStart, yStart, 'SB', 3)
  paintSwitch(widget, xStart, yStart, 'SC', 4)
  paintSwitch(widget, xStart, yStart, 'SD', 5)
  paintSwitch(widget, xStart, yStart, 'SH', 6)
  paintSwitch(widget, xStart, yStart, 'SG', 7)
end

return module