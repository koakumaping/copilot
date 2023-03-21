local var = require('var')
local util = require('util')

local time = require('time')
local switch = require('switch')
local bitmap = require('bitmap')
local ext = require('ext')
local rx = require('rx')
local counts = require('counts')
local trim = require('trim')

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
  trim.wakeup(widget)
end

local function paint(widget)
  lcd.color(widget.bgColor)
  lcd.drawFilledRectangle(0, 0, widget.w, widget.h)

  local left = 296
  local half = 236
  local third = 152
  local forth = 112
  util.drawBox(widget, 0, 0, left, 70 + 36, '', time.paint)
  util.drawBox(widget, 0, 114, left, 43, '', switch.paint)
  util.drawBox(widget, 0, 166, left, var.modelBitmapHeight + 16, '', bitmap.paint)

  -- line 1
  util.drawBox(widget, left + 8, 0, half, 106, '', ext.paint)
  util.drawBox(widget, left + 8 + half + 8, 0, half, 106, '', rx.paint)

  -- line 2
  util.drawBox(widget, left + 8, 114, half, 78, '', ext.paintCell)
  util.drawBox(widget, left + 8 + half + 8, 114, half, 78, '', counts.paint)

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