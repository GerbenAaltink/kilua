require 'table'

function getDateString()
    return os.date("%Y-%m-%d")
end

function getDateTimeString()
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
    acnt.path = "/home/gerben/.config/kilo/statistics/" .. acnt.fileName
    return acnt
end

function serializeObject(obj)
    serialized = ""
    for k, v in pairs(obj) do
        serialized = serialized .. "{" .. string.len(k) .. ":" .. k .. ":" .. string.len(v) .. ":" .. v .. "}\n"
    end
    return serialized
end

function unserializeObject(obj, data)
    debug = false
    while (string.len(data) > 0)
    do
        if string.sub(data, 0, 1) == "{" then
            data = string.sub(data, 2)
            endPos = string.find(data, ":") - 1
            length = string.sub(data, 0, endPos)
            if debug then
                print("KeyLength: " .. length)
            end
            data = string.sub(data, string.len(length) + 2)
            name = string.sub(data, 0, length)
            data = string.sub(data, length + 2)
            endPos = string.find(data, ":")
            valueLength = string.sub(data, 0, endPos - 1)
            if debug then
                print("KeyName: " .. name)
            end
            if debug then
                print("ValueLength: " .. valueLength)
            end
            valueData = string.sub(data, string.len(valueLength) + 2, valueLength + string.len(valueLength) + 1)
            -- valueData = string.sub(data, 0, valueLength);
            if debug then
                print("ValueData: " .. valueData)
            end
            data = string.sub(data, valueLength + string.len(valueLength) + 4)
            vType = type(obj[name])
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
    data = serializeObject(self)
    file = io.open(self.path, "w+")
    io.output(file)
    io.write(data)
    io.close()
    return data
end

function Statistics:read()
    file = io.open(self.path, "r")
    if not file then
        return
    end


    io.input(file)

    data = io.read(1024 * 1024)

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
    " keys pressed. " .. self.mistakeCount .. " mistakes. " .. self.newLineCount .. " new lines added. "
end

function Statistics:test()
    self:incrementPressCount()
    self:incrementMistakeCount()
    self:incrementNewLineCount()
    return self:toString()
end

stats = Statistics:create()
stats:read()

-- stats:test()


function generateStatusBarText()
    return stats:toString() .. " " .. _VERSION .. " " .. stats.fileName .. " " .. stats.lastSaved
end

function square(val1)
    return val1 * val1
end

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

