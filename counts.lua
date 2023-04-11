local module = {}

local moduleX = 0
local moduleY = 0
local moduleWidth = 200
local moduleHeight = 60

local current = 0
local _current = 0

local startDate = ''
local stopDate = ''

local modelName = model.name()
local fileName = 'data/fly.csv'
local recordFileName = string.format('%s%s%s', 'data/', model.name(), '.csv')

local lastFlyTime = 0

function getTime()
  return os.date("%Y-%m-%d %H:%M:%S", os.time())
end

function module.save()
  local data = 'Name,FlyTimes,LastFlyTime\n'
  local csv = io.open(fileName, 'r')

  local count = 1
  local saved = 0
  while csv do
    local line = csv:read('*line')
    if line == nil then
      csv:close()
      break
    end
    if count ~= 1 then
      local name, flyTimes, lastFlyTime = line:match('([^,]+),([^,]+),([^,]+)')
      if name == modelName then
        flyTimes = _current
        lastFlyTime = getTime()
        saved = 1
      end
      data = string.format('%s%s,%d,%s\n', data, name, flyTimes, lastFlyTime)
    end
    count = count + 1
  end

  -- if no data in csv
  if saved == 0 then
    data = string.format('%s%s,%d,%s\n', data, modelName, _current, getTime())
  end

  -- save to file
  local filewrite = io.open(fileName, 'w')
  filewrite:write(data)
  filewrite:close()
end

function module.saveRecord()
  local data = 'FlyTime,LandingVoltage,StartDate,StopTime\n'
  local csv = io.open(recordFileName, 'r')
  -- creat if not exist
  if csv == nil then
    filewrite = io.open(recordFileName, 'w')
    filewrite:write(data)
    filewrite:close()
    csv = io.open(recordFileName, 'r')
  end

  local count = 1
  local saved = 0
  while csv do
    local line = csv:read('*line')
    if line == nil then
      csv:close()
      break
    end
    if count ~= 1 then
      data = string.format('%s%s\n', data, line)
    end
    count = count + 1
  end
  -- print(modelName, startDate, stopDate, lastFlyTime)

  local ext = 0
  local source = system.getSource({ name='ADC2' })
  if source ~= nil then
    ext = source:value()
  end

  local lastFlyTimeSeconds = string.format('%02d', lastFlyTime % 60)
  local lastFlyTimeMinutes = string.format('%02d', (lastFlyTime - lastFlyTimeSeconds) / 60) 

  data = string.format('%s%s,%s,%s,%s\n',
    data,
    string.format('%s:%s', lastFlyTimeMinutes, lastFlyTimeSeconds),
    string.format('%d%s(%03.2f%s)', ext, 'v', ext / 6, 'v'),
    startDate,
    stopDate
  )

  print(data)
  -- save to file
  local filewrite = io.open(recordFileName, 'w')
  filewrite:write(data)
  filewrite:close()
end

function module.init()
  -- print('init', model.name(), modelName)
  local csv = io.open(fileName, 'r')
  -- creat if not exist
  if csv == nil then
    filewrite = io.open(fileName, 'w')
    filewrite:write('Name,FlyTimes,LastFlyTime\n')
    filewrite:close()
    csv = io.open(fileName, 'r')
  end

  while csv do
    local line = csv:read('*line')
    if line == nil then
      csv:close()
      break
    end
    local name, flyTimes = line:match("([^,]+),([^,]+)")
    -- print(line)
    if name == modelName then
      _current = flyTimes
      csv:close()
      break
    end
  end
end

function module.add(widget)
  lastFlyTime = widget.lastFlyTime
  _current = _current + 1
  module:save()
  -- print(modelName, startDate, stopDate, widget.lastFlyTime)
  module:saveRecord()
end

function module.start()
  startDate = getTime()
end

function module.stop()
  stopDate = getTime()
end

function module.wakeup(widget)
  if current ~= _current then
    current = _current
    lcd.invalidate(moduleX, moduleY, moduleWidth, moduleHeight)
  end
end

function module.paint(widget, x, y)
  local xStart = x + 15
  local yStart = y - 4
  if moduleX ~= xStart then moduleX = xStart end
  if moduleY ~= yStart then moduleY = yStart end

  lcd.color(widget.libs.var.textColor)
  widget.libs.util.drawChar(widget, xStart, yStart, string.format('%04d', current))
end

return module