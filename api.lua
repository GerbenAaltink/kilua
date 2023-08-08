require 'table'

-- TODO: make source conform LUA standards. 
-- It's ny furst Lua application

local function getDateString()
    return os.date("%Y-%m-%d")
end

local function getDateTimeString()
    return os.date("%Y-%m-%d %H:%m:%S")
end

Statistics = {}
Statistics.__index = Statistics

function Statistics:create()
    local acnt = {}
    setmetatable(acnt, Statistics)
    acnt.pressCount = 0
    acnt.mistakeCount = 0
    acnt.newLineCount = 0
    acnt.lastSaved = nil
    acnt.created = getDateTimeString()
    acnt.fileName = getDateString() .. "-statistics.txt"
    -- TODO: remove hardcoded path to my home directory
    acnt.path = "/home/gerben/.config/kilo/statistics/" .. acnt.fileName
    return acnt
end

local function serializeObject(obj)
    -- Self written object serializer
    -- Since this serializer works with stored lengths of values 
    -- it should be super safe.
    local serialized = ""
    for k, v in pairs(obj) do
        serialized = serialized .. "{" .. string.len(k) .. ":" .. k .. ":" .. string.len(v) .. ":" .. v .. "}\n"
    end
    return serialized
end

local function unserializeObject(obj, data)
    -- Self written unserializer
    -- The 'magic' numbers are for ignoring :{}
    -- Since this unserializer works with stored lengths of values 
    -- it should be super safe.
    debug = false
    while (string.len(data) > 0)
    do
        if string.sub(data, 0, 1) == "{" then
            data = string.sub(data, 2)
            local endPos = string.find(data, ":") - 1
            local length = string.sub(data, 0, endPos)
            if debug then
                print("KeyLength: " .. length)
            end
            data = string.sub(data, string.len(length) + 2)
            local name = string.sub(data, 0, tonumber(length))
            data = string.sub(data, length + 2)
            local endPos = string.find(data, ":")
            local valueLength = string.sub(data, 0, endPos - 1)
            if debug then
                print("KeyName: " .. name)
            end
            if debug then
                print("ValueLength: " .. valueLength)
            end
            local valueData = string.sub(data, string.len(valueLength) + 2, valueLength + string.len(valueLength) + 1)
            -- valueData = string.sub(data, 0, valueLength);
            if debug then
                print("ValueData: " .. valueData)
            end
            data = string.sub(data, valueLength + string.len(valueLength) + 4)
            local vType = type(obj[name])
            if vType == "number" then
                obj[name] = tonumber(valueData)
            else
                obj[name] = valueData
            end
        end
    end
end

function Statistics:save()
    self.lastSaved = getDateTimeString()
    local data = serializeObject(self)
    local file = io.open(self.path, "w+")
    io.output(file)
    io.write(data)
    io.close()
    return data
end

function Statistics:ensure()
    -- function that ensures the file is available
    if self.lastSaved then
        return true
    end
    self:read()
    if not self.lastSaved then
        self:save();
    end
    return true
end

function Statistics:read()
    local file = io.open(self.path, "r")
    if not file then
        return
    end

    io.input(file)

    -- TODO: just read to end
    local data = io.read(1024 * 1024)

    io.close()
    unserializeObject(self, data)
end

function Statistics:incrementPressCount()
    self.pressCount = self.pressCount + 1
end

function Statistics:incrementMistakeCount()
    self.mistakeCount = self.mistakeCount + 1
end

function Statistics:incrementNewLineCount()
    self.newLineCount = self.newLineCount + 1
end

function Statistics:toString()
    return self.pressCount ..
    " keys pressed. " .. self.mistakeCount .. " mistakes. " .. self.newLineCount .. " new lines added."
end

function Statistics:test()
    self:incrementPressCount()
    self:incrementMistakeCount()
    self:incrementNewLineCount()
    return self:toString()
end

local stats = Statistics:create()
-- Load statistics of today and create if not exists yet using ensure 
stats:ensure()

local function generateStatusBarText()
    return stats:toString() .. " " .. _VERSION .. " " .. stats.fileName .. " " .. stats.lastSaved
end

-- TODO: onEvent
function event(name, param)
    if name == "keypress" then
        if param == 127 then
            -- backspace
            stats:incrementMistakeCount()
        elseif param == 13 then
            -- return
            stats:incrementNewLineCount()
        else
            -- elke andere
            stats:incrementPressCount()
        end

        stats:save()
    end

    return generateStatusBarText()
end

