local function loadLib(name)
  local lib = dofile('/scripts/copilot/'..name..'.lua')
  if lib.init ~= nil then
    lib.init()
  end
  return lib
end

local time = loadLib('time')
local switch = loadLib('switch')
local bitmap = loadLib('bitmap')
local ext = loadLib('ext')
local rx = loadLib('rx')
local trim = loadLib('trim')
local copyright = loadLib('copyright')
local channel = loadLib('channel')
local message = loadLib('message')

local initPending = false

-- local testTabele = {}

local function create()
  if not initPending then
    initPending = true
  end

  return {
    w = 784,
    h = 316,
    bitmap = lcd.loadBitmap(model.bitmap()),
    flyCounts = 0,
    libs = {
      var = loadLib('var'),
      util = loadLib('util'),
      message = message,
      counts = loadLib('counts'),
    },
    message = '',
    messageStartTime = 0,
    messageEndTime = 0,
    lastFlyTime = 0,
  }
end

local function configure(widget)
  line = form.addLine('FlyCounts')
  form.addNumberField(line, nil, 0, 9999, function() return widget.flyCounts end, function(flyCounts) widget.flyCounts = flyCounts end)
end

local function read(widget)
  widget.flyCounts = storage.read('flyCounts')
end

local function write(widget)
  storage.write('flyCounts', widget.flyCounts)
end

local function menu(widget)
  return {
    {'Lua Menu Test',
      function()
        local sensor = system.getSource({ name='RxBatt' })
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
  -- print(system.getMemoryUsage().mainStackAvailable)
  -- table.insert(testTabele, {
  --   speed=200,
  --   rssi=50,
  --   RxBatt=22.5,
  --   thr=1024,
  -- })

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
  widget.libs.counts.wakeup(widget)
  copyright.wakeup(widget)
  channel.wakeup(widget)
  message.wakeup(widget)
end

local function paint(widget)
  lcd.color(widget.libs.var.bgColor)
  lcd.drawFilledRectangle(0, 0, widget.w, widget.h)

  local left = 296
  local half = 236
  local third = 152
  local forth = 112
  widget.libs.util.drawBox(widget, 0, 0, left, 70 + 36, time.paint)
  widget.libs.util.drawBox(widget, 0, 114, left, 43, switch.paint)
  widget.libs.util.drawBox(widget, 0, 166, left, widget.libs.var.modelBitmapHeight + 16, bitmap.paint)

  -- line 1
  widget.libs.util.drawBox(widget, left + 8, 0, half, 106, ext.paint)
  widget.libs.util.drawBox(widget, left + 8 + half + 8, 0, half, 106, rx.paint)

  -- line 2
  widget.libs.util.drawBox(widget, left + 8, 114, half, 78, ext.paintCell)
  widget.libs.util.drawBox(widget, left + 8 + half + 8, 114, half, 78, widget.libs.counts.paint)

  -- line 3
  widget.libs.util.drawBox(widget, left + 8, 200, half, 78, trim.paint)
  widget.libs.util.drawBox(widget, left + 8 + half + 8, 200, half, 78, channel.paint)

  -- line 4
  widget.libs.util.drawBox(widget, left + 8, 286, half * 2 + 8, 30, copyright.paint)
  message.paint(widget, 400, 200)
  lcd.setClipping(400, 200, 120, 20)
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
    persistent=false,
    title=false,
  })
end

return {init=init}