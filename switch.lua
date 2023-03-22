local var = dofile('/scripts/copilot/var.lua')
local util = dofile('/scripts/copilot/util.lua')
local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 280
local moduleHeight = 40

local switchBitmap = lcd.loadBitmap('./bitmaps/check_sw_bg.png')
local switchUpMask = lcd.loadMask('./bitmaps/check_sw_up.png')
local switchMidMask = lcd.loadMask('./bitmaps/check_sw_mid.png')
local switchDownMask = lcd.loadMask('./bitmaps/check_sw_down.png')

local switchTable = { var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN }
local switchNameTable = { 'SA', 'SB', 'SC', 'SD', 'SE', 'SF', 'SG', 'SH', 'SI', 'SJ' }
local switchTwoStageNameTable = { 'SE', 'SF', 'SG', 'SH', 'SI', 'SJ' }

function indexOf(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return nil
end

function getSwitchValue(widget, name)
  local index = indexOf(switchNameTable, name)
  return switchTable[index]
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

  if indexOf(switchTwoStageNameTable, name) == nil then
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

  if SA ~= switchTable[1] then
    switchTable[1] = SA
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SB ~= switchTable[2] then
    switchTable[2] = SB
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SC ~= switchTable[3] then
    switchTable[3] = SC
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SD ~= switchTable[4] then
    switchTable[4] = SD
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SE ~= switchTable[5] then
    switchTable[5] = SE
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SF ~= switchTable[6] then
    switchTable[6] = SF
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SG ~= switchTable[7] then
    switchTable[7] = SG
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SH ~= switchTable[8] then
    switchTable[8] = SH
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SI ~= switchTable[9] then
    switchTable[9] = SI
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end

  if SJ ~= switchTable[10] then
    switchTable[10] = SJ
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x + 4
  local yStart = y

  moduleX = xStart
  moduleY = yStart

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