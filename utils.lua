local NMs = require('NMs');
local chat = require('chat');
local settings = require('settings');
local zones = require('zones')

local utils = {};

utils.process_time_entry = function (tod_input)
    local t1 = {}
    local tod = {}
    local count = 0
    for str in string.gmatch(tod_input, '([^:]+)') do
        count = count + 1
        table.insert(t1, str)
    end
    tod = os.date('*t', os.time())
    if count == 2 then
        tod.min = t1[1]
        tod.sec = t1[2]
    elseif count == 3 then
        tod.hour = t1[1]
        tod.min = t1[2]
        tod.sec = t1[3]
    else
        return 0
    end
    return os.time(tod)
end

utils.log_event = function (event, nm_name)
    local logfile = ('%s\\NM_tods.log'):fmt(addon.path);
    local text = os.date('%d/%m/%y %X', time) .. ' | ' .. event .. ' | ' .. nm_name;
    local f = io.open(logfile, 'a');
    f:write(text .. '\n');
    f:close();
end

utils.list_nms = function ()
    local temp = {};
    for x in pairs(NMs) do
        table.insert(temp, x);
    end
    table.sort(temp);
    for x, y in pairs(temp) do
        local message = 'NM Respawn: ' .. os.date('%X', NMs[y].Respawn);
        local message2 = 'ID: [' .. string.format('%03X', NMs[y].ID) .. ']';
        if NMs[y].Zone ~= nil then
            message2 = zones[NMs[y].Zone].en .. ', ' .. message2;
        end
        if #NMs[y].PH > 0 then
            message = message .. ', PH Respawn: ' .. os.date('%X', NMs[y].Time);
            message2 = message2 .. ', PH(s):';
            for _, ph in pairs(NMs[y].PH) do
                message2 = message2 .. ' [' .. string.format('%03X', ph) .. ']';
            end
        end
        print(chat.header('ToD') .. chat.header(y) .. chat.header(NMs[y].Name) .. chat.message(message2));
        print(chat.header('ToD') .. chat.header(y) .. chat.header(NMs[y].Name) .. chat.message(message));
    end
end

utils.sort_phs = function (phs)
    local times = {};
    local codes = {};
    for code, tod in pairs(phs) do
        codes[tod + NMs[code].Time] = code;
        table.insert(times, tod + NMs[code].Time);
    end
    table.sort(times);
    local result = {}
    for _, time in pairs(times) do
        table.insert(result, {code = codes[time], tod = phs[codes[time]]});
    end
    return result;
end

utils.save_nms = function (NMs)
    local file = ('%s\\NMs.lua'):fmt(addon.path);
    local p, s = settings.process(NMs, 'NMs');
    local f = io.open(file, 'w+');
    if (f == nil) then
        return false;
    end
    f:write('local NMs = T{ };\n');
    p:each(function (v) f:write(('%s = T{ };\n'):fmt(v)); end);
    f:write(s);
    f:write('\nreturn NMs;\n');
    f:close();
    print(chat.header('ToD') .. chat.message('NM table updates saved'));
    return true;
end

utils.add_nm = function (NMs, args);
    -- check #args is at least 4
    if (#args < 4) then
        print(chat.header('ToD') .. chat.error('Not enough arguments'));
        return NMs
    end

    -- assign arg[1] code, arg[2] name, args[3] respawn
    local code = args[1];
    local name = args[2];
    local min_repop = tonumber(args[3]);
    local respawn = tonumber(args[4]);

    -- check if code is in
    if NMs[code] ~= nil then
        print(chat.header('ToD') .. chat.error('Code already in use'));
        return NMs
    end

    -- add to NMs table
    NMs[code] = {};
    NMs[code].Name = name
    NMs[code].Time = respawn
    NMs[code].Respawn = min_repop
    NMs[code].Zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);
    if args[5] then -- add ID
        NMs[code]['ID'] = tonumber(args[5]);
    end
    NMs[code]['PH'] = {};
    for i = 6, #args, 1 do  -- add PH(s)
        NMs[code]['PH'][i - 5] = tonumber(args[i]);
    end
    print(chat.header('ToD') .. chat.message(name .. ' added to list'));
    utils.save_nms(NMs);
    return NMs
end

utils.del_nm = function (NMs, args)
    if NMs[args[1]] == nil then
        print(chat.header('ToD') .. chat.error('Code not found'));
        return NMs
    end
    print(chat.header('ToD') .. chat.message(NMs[args[1]].Name .. ' removed from list'));
    NMs[args[1]] = nil;
    utils.save_nms(NMs);
    return NMs
end

return utils;