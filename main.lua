local var = require('var')
local util = require('util')
local time = require('time')
local switch = require('switch')
local ext = require('ext')
local rx = require('rx')

local bitmap, mask
local Rud = 0
local Ele = 1
local Thr = 2
local Ail = 3
local step = 8

local modelBitmapWidth = 280
local modelBitmapHeight = 134

local themeColor = lcd.RGB(0x4C, 0x3C, 0xDE)
local themeBgColor = lcd.themeColor(THEME_DEFAULT_BGCOLOR)

local modelMask = lcd.loadMask('./model-mask.png')

local function create()
  return {
    w=784,
    h=316,
    bgColor=lcd.RGB(0xD0, 0xD0, 0xD0),
    mainColor=lcd.RGB(0x00, 0xFC, 0x80),
    bitmap=lcd.loadBitmap(model.bitmap()),
    flyTime=0,
    allTime=0,
    flyCounts=0,
    alpha=2,
    reserve=1,
    trim1=0,
    trim2=0,
    trim3=0,
    trim4=0,
    p1=0,
    p2=0,
    p3=-30,
    p4=0,
    SA=var.MIN,
    SB=var.MIN,
    SC=var.MIN,
    SD=var.MIN,
    SE=var.MIN,
    SF=var.MIN,
    SG=var.MIN,
    SH=var.MIN,
    SI=var.MIN,
    SJ=var.MIN,
    switchTable={ var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN, var.MIN },
    switchNameTable={ 'SA', 'SB', 'SC', 'SD', 'SE', 'SF', 'SG', 'SH', 'SI', 'SJ' },
    switchTwoStageNameTable={ 'SE', 'SF', 'SG', 'SH', 'SI', 'SJ' },
    lastTime=os.clock(),
    ext=0,
    extMin=var.MAX,
    extMax=0,
    extCell=0,
    extCellMin=var.MAX,
    extCellMax=0,
    rxBatt=0,
    rxBattMin=var.MAX,
    rxBattMax=0,
  }
end

local function configure(widget)
  line = form.addLine('BackgroundColor')
  form.addColorField(line, nil, function() return widget.bgColor end, function(color) widget.bgColor = color end)
  line = form.addLine('MainColor')
  form.addColorField(line, nil, function() return widget.mainColor end, function(color) widget.mainColor = color end)
  line = form.addLine('FlyCounts')
  form.addNumberField(line, nil, 0, 9999, function() return widget.flyCounts end, function(flyCounts) widget.flyCounts = flyCounts end)
end

local function read(widget)
  widget.bgColor = storage.read('bgColor')
  widget.mainColor = storage.read('mainColor')
  widget.flyCounts = storage.read('flyCounts')
end

local function write(widget)
  storage.write('bgColor', widget.bgColor)
  storage.write('mainColor', widget.mainColor)
  storage.write('flyCounts', widget.flyCounts)
end

local function menu(widget)
  return {
    {'Lua... playNumber(RSSI)',
      function()
        local sensor = system.getSource('RSSI')
        system.playNumber(sensor:value(), sensor:unit(), sensor:decimals())
        local buttons = {
          {label="OK", action=function() return true end},
          {label="Cancel", action=function() return true end},
          {label="Nothing", action=function() return false end},
        }
        form.openDialog("Dialog demo", "This is a demo to show how to use LUA Message Dialog", buttons)        
      end
    },
  }
end

local function wakeupControlSurface(widget)
  local trim1 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Ail}):value())
  local trim2 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Ele}):value())
  local trim3 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Thr}):value())
  local trim4 = util.calcTrim(system.getSource({category=CATEGORY_TRIM, member=Rud}):value())
  local p1 = util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=0}):value())
  local p2 = -util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=1}):value())
  local p3 = -util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=2}):value())
  local p4 = util.calc1024(system.getSource({category=CATEGORY_CHANNEL, member=3}):value())

  if trim1 ~= widget.trim1 then
    widget.trim1 = trim1
    lcd.invalidate()
  end

  if trim2 ~= widget.trim2 then
    widget.trim2 = trim2
    lcd.invalidate()
  end

  if trim3 ~= widget.trim3 then
    widget.trim3 = trim3
    lcd.invalidate()
  end

  if trim4 ~= widget.trim4 then
    widget.trim4 = trim4
    lcd.invalidate()
  end

  if p1 ~= widget.p1 then
    widget.p1 = p1
    lcd.invalidate()
  end

  if p2 ~= widget.p2 then
    widget.p2 = p2
    lcd.invalidate()
  end

  if p3 ~= widget.p3 then
    widget.p3 = p3
    lcd.invalidate()
  end

  if p4 ~= widget.p4 then
    widget.p4 = p4
    lcd.invalidate()
  end
end

local function wakeup(widget)
  local w, h = lcd.getWindowSize()
  if w ~= widget.w then
    widget.w = w
    lcd.invalidate()
  end
  if h ~= widget.h then
    widget.h = h
    lcd.invalidate()
  end
  time.wakeup(widget)
  ext.wakeup(widget)
  switch.wakeup(widget)
  rx.wakeup(widget)
  wakeupControlSurface(widget)
end

local function paintModelBitmap(widget, x, y)
  lcd.drawBitmap(x, y, widget.bitmap, modelBitmapWidth, modelBitmapHeight)
  lcd.color(lcd.RGB(225, 225, 225))
  lcd.drawMask(x, y, modelMask)
end

local function paintContralSurface(widget, x, y)
  local size = 65 + 2

  local xStart = x
  local yStart = y

  local borderColor = lcd.RGB(0, 0, 0, 0.4)
  local themeColor = widget.mainColor
  local themeBgColor = themeBgColor

  local trim1 = widget.trim1
  local trim2 = widget.trim2
  local trim3 = widget.trim3
  local trim4 = widget.trim4

  -- left
  local xLeft = xStart
  local yLeft = yStart
  local xLeftCenter = xLeft + (size - 2 - 1) / 2 + 1
  local yLeftCenter = yLeft + (size - 2 - 1) / 2 + 1
  lcd.color(borderColor)
  lcd.drawRectangle(xLeft, yLeft, size, size)
  lcd.color(widget.mainColor)
  lcd.drawFilledCircle(xLeftCenter + widget.p4, yLeftCenter + widget.p3, 5)
  -- left trim
  -- 4
  lcd.color(borderColor)
  lcd.drawLine(xLeftCenter, size + 3, xLeftCenter, size + 4 + 4)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xLeftCenter - 30, size + 4, 30, 4)
  lcd.drawFilledRectangle(xLeftCenter + 1, size + 4, 30, 4)

  lcd.color(widget.mainColor)
  if trim4 < 0 then
    lcd.drawFilledRectangle(xLeftCenter + trim4, size + 4, -trim4, 4)
  elseif trim4 > 0 then
    lcd.drawFilledRectangle(xLeftCenter + 1, size + 4, trim4, 4)
  end

  -- 3
  lcd.color(borderColor)
  lcd.drawLine(xLeft - 4 - 4 - 1, 4 + 30, xLeft - 4, 4 + 30)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xLeft - 4 - 4, 4 + 30 + 1, 4, 30)
  lcd.drawFilledRectangle(xLeft - 4 - 4, 4, 4, 30)

  lcd.color(widget.mainColor)
  if trim3 < 0 then
    lcd.drawFilledRectangle(xLeft - 4 - 4, 4 + 30 + 1, 4, -trim3)
  elseif trim3 > 0 then
    lcd.drawFilledRectangle(xLeft - 4 - 4, 4 + 30 - trim3, 4, trim3)
  end

  --right
  local xRight = xLeft + size + 16
  local yRight = yStart
  local xRightCenter = xRight + (size - 2 - 1) / 2 + 1
  local yRightCenter = yRight + (size - 2 - 1) / 2 + 1
  lcd.color(borderColor)
  lcd.drawRectangle(xRight, yRight, size, size)
  lcd.color(widget.mainColor)
  lcd.drawFilledCircle(xRightCenter + widget.p1, yRightCenter + widget.p2, 5)

  -- right trim
  -- 2
  lcd.color(borderColor)
  lcd.drawLine(xRight + size + 4 - 1, 4 + 30, xRight + size + 4 - 1 + 5, 4 + 30)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xRight + size + 4, 4, 4, 30)
  lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 + 1, 4, 30)

  lcd.color(widget.mainColor)
  -- lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 - 14, 4, 14)
  -- lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 + 1, 4, 10)
  if trim2 < 0 then
    lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 + 1, 4, -trim2)
  elseif trim2 > 0 then
    lcd.drawFilledRectangle(xRight + size + 4, 4 + 30 - trim2, 4, trim2)
  end

  -- 1
  lcd.color(borderColor)
  lcd.drawLine(xRightCenter, size + 3, xRightCenter, size + 4 + 4)
  lcd.color(themeBgColor)
  lcd.drawFilledRectangle(xRightCenter - 30, size + 4, 30, 4)
  lcd.drawFilledRectangle(xRightCenter + 1, size + 4, 30, 4)

  lcd.color(widget.mainColor)
  if trim1 < 0 then
    lcd.drawFilledRectangle(xRightCenter + trim1, size + 4, -trim1, 4)
  elseif trim1 > 0 then
    lcd.drawFilledRectangle(xRightCenter + 1, size + 4, trim1, 4)
  end
end

local function paintExtCellVoltage(widget, x, y)
  util.drawChar(widget, x + 15, y, string.format('%04.2f%s', widget.extCell, 'V'))
end

local function paintFlyCounts(widget, x, y)
  util.drawChar(widget, x + 15, y, string.format('%04d', widget.flyCounts))
end

local function paint(widget)
  local w, h = lcd.getWindowSize()
  lcd.color(widget.bgColor)
  lcd.drawFilledRectangle(0, 0, widget.w, widget.h)

  local left = 296
  local half = 236
  local third = 152
  local forth = 112
  util.drawBox(widget, 0, 0, left, 70 + 36, '', time.paint)
  util.drawBox(widget, 0, 114, left, 43, '', switch.paint)
  util.drawBox(widget, 0, 166, left, modelBitmapHeight + 16, '', paintModelBitmap)

  -- line 1
  util.drawBox(widget, left + 8, 0, half, 106, '', ext.paint)
  util.drawBox(widget, left + 8 + half + 8, 0, half, 106, '', rx.paint)

  -- line 2
  util.drawBox(widget, left + 8, 114, half, 78, '', paintExtCellVoltage)
  util.drawBox(widget, left + 8 + half + 8, 114, half, 78, '', paintFlyCounts)

  -- line 3
  util.drawBox(widget, left + 8, 200, half, 116, '')
  util.drawBox(widget, left + 8 + half + 8, 200, half, 116, '')
end

local function init()
  system.registerWidget({
    key="copilot",
    name="Copilot",
    create=create,
    configure=configure,
    read=read,
    write=write,
    wakeup=wakeup,
    paint=paint,
    menu=menu,
    persistent=true,
    title=false,
  })
end

return {init=init}