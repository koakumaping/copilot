-- Lua LCD Test widget

local bitmap, mask
local pink = lcd.RGB(210, 93, 138)
local Rud = 0
local Ele = 1
local Thr = 2
local Ail = 3
local step = 8

local MAX = 1024
local MIN = MIN

local fontWidth = 48
local dotWidth = 22

local modelBitmapWidth = 280
local modelBitmapHeight = 134

local switchSurfaceX = 100
local switchSurfaceY = 0
local switchSurfaceWidth = 280
local switchSurfaceHeight = 40

local flyTimeX = 0
local flyTimeY = 0
local flyTimeWidth = 48 *4 + 22
local flyTimeHeight = 60

local themeColor = lcd.RGB(0x4C, 0x3C, 0xDE)
local themeBgColor = lcd.themeColor(THEME_DEFAULT_BGCOLOR)

local whiteColor = lcd.RGB(255, 255, 255)
local blackColor = lcd.RGB(0, 0, 0, 0.8)
local greenColor = lcd.RGB(110, 208, 102)
local greyColor = lcd.RGB(64, 64, 64)
local bgColor = lcd.RGB(0xC8, 0xDC, 0xF8)
local textColor = lcd.GREY(80)

local rssi24GMask = lcd.loadMask('./xxs_24g.png')
local rssi900mMask = lcd.loadMask('./xxs_900m.png')
local rssiMask = lcd.loadMask('./rssi.png')
local batteryMask = lcd.loadMask('./battery.png')

local modelMask = lcd.loadMask('./model-mask.png')
local number0 = lcd.loadMask('./0.png')
local number1 = lcd.loadMask('./1.png')
local number2 = lcd.loadMask('./2.png')
local number3 = lcd.loadMask('./3.png')
local number4 = lcd.loadMask('./4.png')
local number5 = lcd.loadMask('./5.png')
local number6 = lcd.loadMask('./6.png')
local number7 = lcd.loadMask('./7.png')
local number8 = lcd.loadMask('./8.png')
local number9 = lcd.loadMask('./9.png')
local colon = lcd.loadMask('./colon.png')
local dot = lcd.loadMask('./dot.png')
local minus = lcd.loadMask('./minus.png')
local charV = lcd.loadMask('./V.png')
local charS = lcd.loadMask('./S.png')

local switchMask = lcd.loadMask('./switch.png')
local switchPositionMask = lcd.loadMask('./switch-position.png')
local readyMask = lcd.loadMask('./ready.png')
local flyingMask = lcd.loadMask('./flying.png')
local flyTimeMask = lcd.loadMask('./flytime.png')

local switchBitmap = lcd.loadBitmap('./check_sw_bg.png')
local switchUpMask = lcd.loadMask('./check_sw_up.png')
local switchMidMask = lcd.loadMask('./check_sw_mid.png')
local switchDownMask = lcd.loadMask('./check_sw_down.png')

local topLeftMask = lcd.loadMask('./tl.png')
local topRightMask = lcd.loadMask('./tr.png')
local bottomLeftMask = lcd.loadMask('./bl.png')
local bottomRightMask = lcd.loadMask('./br.png')

local function indexOf(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return nil
end

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
    source=nil,
    value=nil,
    alpha=2,
    reserve=1,
    rssi2400=0,
    rssi900=0,
    trim1=0,
    trim2=0,
    trim3=0,
    trim4=0,
    p1=0,
    p2=0,
    p3=-30,
    p4=0,
    SA=MIN,
    SB=MIN,
    SC=MIN,
    SD=MIN,
    SE=MIN,
    SF=MIN,
    SG=MIN,
    SH=MIN,
    SI=MIN,
    SJ=MIN,
    switchTable={ MIN, MIN, MIN, MIN, MIN, MIN, MIN, MIN, MIN, MIN },
    switchNameTable={ 'SA', 'SB', 'SC', 'SD', 'SE', 'SF', 'SG', 'SH', 'SI', 'SJ' },
    switchTwoStageNameTable={ 'SE', 'SF', 'SG', 'SH', 'SI', 'SJ' },
    lastTime=os.clock(),
    ext=0,
    extMin=MAX,
    extMax=0,
    extCell=0,
    extCellMin=MAX,
    extCellMax=0,
    rxBatt=0,
    rxBattMin=MAX,
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

local function getCharMask(value)
  if value == 0 or value == '0' then return number0 end
  if value == 1 or value == '1' then return number1 end
  if value == 2 or value == '2' then return number2 end
  if value == 3 or value == '3' then return number3 end
  if value == 4 or value == '4' then return number4 end
  if value == 5 or value == '5' then return number5 end
  if value == 6 or value == '6' then return number6 end
  if value == 7 or value == '7' then return number7 end
  if value == 8 or value == '8' then return number8 end
  if value == 9 or value == '9' then return number9 end

  if value == '.' then return dot end
  if value == '-' then return minus end

  if value == 'S' then return charS end
  if value == 'V' then return charV end
  return colon
end

local function calcTrim(value)
  local base = 30
  local max = 1024
  local minus = 1
  if value < 0 then
    minus = -1
    value = -value
  end

  if value == 0 then
    return 0
  end
  if value < 10 then
    return minus * 1
  end
  if value < 20 then
    return minus * 2
  end
  if value < 30 then
    return minus * 3
  end
  if value < 50 then
    return minus * 4
  end
  if value < 70 then
    return minus * 5
  end
  if value < 90 then
    return minus * 6
  end
  if value < 110 then
    return minus * 7
  end
  if value < 130 then
    return minus * 8
  end
  if value < 160 then
    return minus * 9
  end
  if value < 190 then
    return minus * 10
  end
  if value < 210 then
    return minus * 11
  end
  if value < 250 then
    return minus * 12
  end
  if value < 290 then
    return minus * 13
  end
  if value < 330 then
    return minus * 14
  end
  if value < 370 then
    return minus * 15
  end
  if value < 420 then
    return minus * 16
  end
  if value < 460 then
    return minus * 17
  end
  if value < 500 then
    return minus * 18
  end
  if value < 540 then
    return minus * 19
  end
  if value < 600 then
    return minus * 20
  end
  if value < 660 then
    return minus * 21
  end
  if value < 720 then
    return minus * 22
  end
  if value < 780 then
    return minus * 23
  end
  if value < 840 then
    return minus * 24
  end
  if value < 880 then
    return minus * 25
  end
  if value < 920 then
    return minus * 26
  end
  if value < 960 then
    return minus * 27
  end
  if value < 1000 then
    return minus * 28
  end
  if value < 1024 then
    return minus * 29
  end

  return minus * 30
end

local function calc1024(value)
  local base = 30
  local max = 1024
  return math.floor(value * base / max)
end

local function updatePoints(widget)
  local w, h = lcd.getWindowSize()
  local time = os.clock()
  local delay = widget.delay / 1000

  local value = widget.source:value()
  -- 设置最大值
  if value > widget.max then widget.max = value end

  -- 按比例缩放
  local percent = h / widget.max
  value = h - math.floor(value * percent)

  local currentLength = #widget.points
  if time > widget.lastTime + delay then
    widget.lastTime = time
    if currentLength < w then
        widget.points[currentLength + 1] = value
    else
      for i = 1, w do
        widget.points[i - 1] = widget.points[i]
      end
      widget.points[w] = value
    end
    lcd.invalidate()
  end
end

local function wakeupRssi(widget)
  local rssi2400 = system.getSource({ name='RSSI 2.4G' }):value()
  if rssi2400 ~= widget.rssi2400 then
    widget.rssi2400 = rssi2400
    lcd.invalidate()
  end
end

local function wakeupExt(widget)
  local source = system.getSource({ name='ADC2' })
  if source == nil then
    local ext = 0
    if ext ~= widget.ext then
      widget.ext = ext
      widget.extCell = 0
      lcd.invalidate()
    end
  else
    local ext = source:value()
    if ext ~= widget.ext then
      widget.ext = ext
      if ext > widget.extMax then
        widget.extMax = ext
        widget.extCellMax = ext / 6
      end
      if widget.extMin == 0 then
        widget.extMin = widget.extMax
        widget.extCellMin = widget.extMax / 6
      end
      if ext < widget.extMin then
        widget.extMin = ext
        widget.extCellMin = ext / 6
      end
      widget.extCell = source:value() / 6
      lcd.invalidate()
    end
  end
end

local function wakeupRxBatt(widget)
  local source = system.getSource({ name='RxBatt' })
  if source == nil then
    local rxBatt = 0
    if rxBatt ~= widget.rxBatt then
      widget.rxBatt = rxBatt
      lcd.invalidate()
    end
  else
    local rxBatt = source:value()
    if rxBatt ~= widget.rxBatt then
      widget.rxBatt = rxBatt
      if rxBatt > widget.rxBattMax then widget.rxBattMax = rxBatt end
      if widget.rxBattMin == 0 then widget.rxBattMin = widget.rxBattMax end
      if rxBatt < widget.rxBattMin then widget.rxBattMin = rxBatt end
      lcd.invalidate()
    end
  end
end

local function wakeupTime(widget)
  local flyTime = tonumber(model.getTimer(0):value())
  local allTime = tonumber(model.getTimer(1):value())
  if flyTime ~= widget.flyTime then
    widget.flyTime = flyTime
    lcd.invalidate(flyTimeX, flyTimeY, flyTimeWidth, flyTimeHeight)
  end

  if allTime ~= widget.allTime then
    widget.allTime = allTime
    lcd.invalidate()
  end
end

local function wakeupControlSurface(widget)
  local trim1 = calcTrim(system.getSource({category=CATEGORY_TRIM, member=Ail}):value())
  local trim2 = calcTrim(system.getSource({category=CATEGORY_TRIM, member=Ele}):value())
  local trim3 = calcTrim(system.getSource({category=CATEGORY_TRIM, member=Thr}):value())
  local trim4 = calcTrim(system.getSource({category=CATEGORY_TRIM, member=Rud}):value())
  local p1 = calc1024(system.getSource({category=CATEGORY_CHANNEL, member=Rud}):value())
  local p2 = -calc1024(system.getSource({category=CATEGORY_CHANNEL, member=Ele}):value())
  local p3 = -calc1024(system.getSource({category=CATEGORY_CHANNEL, member=Thr}):value())
  local p4 = calc1024(system.getSource({category=CATEGORY_CHANNEL, member=Ail}):value())

  if trim1 ~= widget.trim1 then
    widget.trim1 = trim1
    lcd.invalidate(600, 0, 784, 75)
  end

  if trim2 ~= widget.trim2 then
    widget.trim2 = trim2
    lcd.invalidate(600, 0, 784, 75)
  end

  if trim3 ~= widget.trim3 then
    widget.trim3 = trim3
    lcd.invalidate(600, 0, 784, 75)
  end

  if trim4 ~= widget.trim4 then
    widget.trim4 = trim4
    lcd.invalidate(600, 0, 784, 75)
  end

  if p1 ~= widget.p1 then
    widget.p1 = p1
    lcd.invalidate(600, 0, 784, 75)
  end

  if p2 ~= widget.p2 then
    widget.p2 = p2
    lcd.invalidate(600, 0, 784, 75)
  end

  if p3 ~= widget.p3 then
    widget.p3 = p3
    lcd.invalidate(600, 0, 784, 75)
  end

  if p4 ~= widget.p4 then
    widget.p4 = p4
    lcd.invalidate(600, 0, 784, 75)
  end
end

local function wakeupSwitchSurface(widget)
  local w, h = lcd.getWindowSize()

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
    lcd.invalidate(308, 0, 308 + 18, 75)
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

local function wakeup(widget)
  -- print('- ', system.getSource({category=CATEGORY_SYSTEM, member=MAX}):value())
  local w, h = lcd.getWindowSize()
  if w ~= widget.w then
    widget.w = w
    lcd.invalidate()
  end
  if h ~= widget.h then
    widget.h = h
    lcd.invalidate()
  end
  -- wakeupRssi(widget)
  wakeupTime(widget)
  wakeupSwitchSurface(widget)
  wakeupExt(widget)
  wakeupRxBatt(widget)
  -- wakeupControlSurface(widget)
  -- local source = system.getSource({ name='RxBatt MAX' })
  -- print(source:name() .. " module:" .. source:module() .. " band:" .. source:band() .. " appId:" .. source:appId() .. " value:" .. source:value())
end

local function drawBox(widget, x, y, w, h, title, f)
  local titleHeight = 36
  local fixTitleHeight = 8

  -- title
  if title ~= '' then
    fixTitleHeight = titleHeight
    h = h + titleHeight
  end

  lcd.color(lcd.RGB(225, 225, 225))
  lcd.drawFilledRectangle(x, y, w, h)
  -- title
  if title ~= '' then
    lcd.font(FONT_STD)
    -- lcd.font(lcd.loadFont('xxxl.fnt'))
    lcd.color(textColor)
    lcd.drawText( x + 8, y + 6, title)
  end
  lcd.color(widget.bgColor)
  lcd.drawMask(x, y, topLeftMask)
  lcd.drawMask(x + w - 6, y, topRightMask)
  lcd.drawMask(x, y + h - 6, bottomLeftMask)
  lcd.drawMask(x + w - 6, y + h - 6, bottomRightMask)

  if f then f(widget, x + 8, y + fixTitleHeight) end
end

local function drawChar(widget, x, y, value)
  lcd.color(textColor)
  local s = tostring(value)
  local xStart = x

  for i = 1, string.len(s) do
    local current = string.sub(s, i, i)
    lcd.drawMask(xStart, y, getCharMask(current))
    if current == '.' or current == ':' then
      xStart = xStart + dotWidth
    else
      xStart = xStart + fontWidth
    end
  end
end

local function paintModelBitmap(widget, x, y)
  lcd.drawBitmap(x, y, widget.bitmap, modelBitmapWidth, modelBitmapHeight)
  lcd.color(lcd.RGB(225, 225, 225))
  lcd.drawMask(x, y, modelMask)
end

local function paintTime(widget, x, y)
  local xStart = x + 33
  local yStart = y

  if flyTimeX ~= xStart then flyTimeX = xStart end
  if flyTimeY ~= yStart then flyTimeY = yStart end

  local flyTimeSeconds = string.format('%02d', widget.flyTime % 60)
  local flyTimeMinutes = string.format('%02d', (widget.flyTime - flyTimeSeconds) / 60)

  local allTimeHour = string.format('%02d', math.floor(widget.allTime / 3600))
  local allTimeMinutes = string.format('%02d', math.floor((widget.allTime - allTimeHour * 3600) / 60))

  -- if widget.switchTable[5] > 0 then
  --   if flyTimeSeconds % 2 == 0 then
  --     lcd.color(blackColor)
  --   else
  --     lcd.color(themeBgColor)
  --   end
  -- else
  --   lcd.color(blackColor)
  -- end

  drawChar(widget, xStart, yStart, string.format('%s:%s', flyTimeMinutes, flyTimeSeconds))
  lcd.color(textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(xStart + 5, y + 66, 'Latabu')
  lcd.drawText(x + 176, y + 66, string.format('%s:%s', allTimeHour, allTimeMinutes))
end

local function getSwitchValue(widget, name)
  local index = indexOf(widget.switchNameTable, name)
  return widget.switchTable[index]
end

local function paintSwitchName(xStart, yStart, name)
  lcd.color(whiteColor)
  lcd.font(FONT_XS)
  lcd.drawText(xStart, yStart, name)
end

local function paintSwitch(widget, xStart, yStart, name, index)
  local borderWidth = 2
  local paddingRight = 8
  local width = 27
  local height = 27
  local activeHeight = (height - 4) / 2

  local value = getSwitchValue(widget, name)

  lcd.drawBitmap(xStart + (paddingRight + width) * index, yStart, switchBitmap)
  if value < 0 then lcd.color(widget.mainColor) else lcd.color(greyColor) end
  lcd.drawMask(xStart + (paddingRight + width) * index + 7, yStart + 1, switchUpMask)
  if indexOf(widget.switchTwoStageNameTable, name) == nil then
    if value == 0 then lcd.color(widget.mainColor) else lcd.color(greyColor) end
    lcd.drawMask(xStart + (paddingRight + width) * index + 10, yStart + 10, switchMidMask)
  end
  if value > 0 then lcd.color(widget.mainColor) else lcd.color(greyColor) end
  lcd.drawMask(xStart + (paddingRight + width) * index + 7, yStart + 18, switchDownMask)

  -- name
  -- lcd.color(whiteColor)
  -- lcd.font(FONT_XS)
  -- lcd.drawText(xStart + (paddingRight + width) * index + 5, yStart + 28, name)
end

local function paintSwitchSurface(widget, x, y)
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

local function paintContralSurface(widget, w, h)
  local paddingRight = 16
  local size = 65 + 2

  local xStart = w - size * 2 - paddingRight - paddingRight / 2 - 1
  local yStart = 0

  local borderColor = lcd.RGB(255, 255, 255, 0.4)
  local themeColor = widget.mainColor
  local themeBgColor = themeBgColor

  local trim1 = widget.trim1
  local trim2 = widget.trim2
  local trim3 = widget.trim3
  local trim4 = widget.trim4
  -- lcd.drawText(w / 2, h / 2, widget.p1)
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
  local xRight = xLeft + size + paddingRight
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

local function paintRssi(widget, x, y, type)
  lcd.color(whiteColor)
  if type == '24G' then
    lcd.drawMask(x + 7, y + 5, rssi24GMask)
  else
    lcd.drawMask(x + 7, y + 5, rssi900mMask)
  end
  lcd.color(greenColor)
  lcd.drawMask(x + 8, y + 9, rssiMask)
end

local function paintBat(widget, x, y)
  lcd.color(greenColor)
  lcd.drawMask(x, y, batteryMask)
end

local function paintExt(widget, x, y)
  drawChar(widget, x + 15, y, string.format('%04.1f%s', widget.ext, 'V'))

  lcd.color(textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 40 + 15, y + 66, string.format('%04.2f%s%04.2f%s', widget.extCellMin == MAX and 0 or widget.extCellMin, ' .. ' , widget.extCellMax, ' v'))
end

local function paintExtCellVoltage(widget, x, y)
  drawChar(widget, x + 15, y, string.format('%04.2f%s', widget.extCell, 'V'))

  -- lcd.color(textColor)
  -- lcd.font(FONT_L_BOLD)
  -- lcd.drawText(x + 40 + 12, y + 66, string.format('%04.2f%s%04.2f%s', widget.extCellMin == MAX and 0 or widget.extCellMin, ' .. ' , widget.extCellMax, ' v'))
end

local function paintRxBatt(widget, x, y)
  drawChar(widget, x + 15, y, string.format('%04.2f%s', widget.rxBatt, 'V'))

  lcd.color(textColor)
  lcd.font(FONT_L_BOLD)
  lcd.drawText(x + 40 + 15, y + 66, string.format('%04.2f%s%04.2f%s', widget.rxBattMin == MAX and 0 or widget.rxBattMin, ' .. ' , widget.rxBattMax, ' v'))
end

local function paintFlyCounts(widget, x, y)
  drawChar(widget, x + 15, y, string.format('%04d', widget.flyCounts))
end

local function paint(widget)
  local w, h = lcd.getWindowSize()
  lcd.color(widget.bgColor)
  lcd.drawFilledRectangle(0, 0, widget.w, widget.h)

  local left = 296
  local half = 236
  local third = 152
  local forth = 112
  drawBox(widget, 0, 0, left, 70 + 36, '', paintTime)
  drawBox(widget, 0, 114, left, 43, '', paintSwitchSurface)
  drawBox(widget, 0, 166, left, modelBitmapHeight + 16, '', paintModelBitmap)

  -- line 1
  drawBox(widget, left + 8, 0, half, 106, '', paintExt)
  drawBox(widget, left + 8 + half + 8, 0, half, 106, '', paintRxBatt)

  -- line 2
  drawBox(widget, left + 8, 114, half, 78, '', paintExtCellVoltage)
  drawBox(widget, left + 8 + half + 8, 114, half, 78, '', paintFlyCounts)

  -- line 3
  drawBox(widget, left + 8, 200, half, 116, '')
  drawBox(widget, left + 8 + half + 8, 200, half, 116, '')
end

local function init()
  system.registerWidget({key="copilot", name="Copilot", create=create, configure=configure, read=read, write=write, wakeup=wakeup, paint=paint})
end

return {init=init}