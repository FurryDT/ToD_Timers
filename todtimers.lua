--[[
* Addons - Copyright (c) 2021 Ashita Development Team
* Contact: https://www.ashitaxi.com/
* Contact: https://discord.gg/Ashita
*
* This file is part of Ashita.
*
* Ashita is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Ashita is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Ashita.  If not, see <https://www.gnu.org/licenses/>.
--]]

addon.author   = 'FurryDT';
addon.name     = 'ToD Timers';
addon.desc     = 'Diplays timers for NM repops';
addon.version  = '1.0';

require ('common');
local imgui = require('imgui');
local chat = require('chat');
local settings = require('settings');
local zones = require('zones');

local ui_active = true;

NMs = require('NMs');

local active_tods = {};
local active_phs = {};
local active_timers = {};

function log_event(text)
    local logfile = ('%s\\NM_tods.log'):fmt(addon.path);
    local f = io.open(logfile, 'a');
    f:write(text .. '\n');
    f:close();
end

function start_timer(args)
    if args[1] == nil then
        table.insert(active_timers, {start = os.time(), stop = 0});
        print(chat.header('ToD') .. chat.message('New Timer started at ' .. os.date('%X', os.time())));
        return
    end
    table.insert(active_timers, {start = get_tod(args[1]), stop = 0});
    print(chat.header('ToD') .. chat.message('New Timer started at ' .. os.date('%X', get_tod(args[1]))));
end

function stop_timer(args)
    if args[1] then
        active_timers[tonumber(args[1])].stop = os.time();
    else
        for i, timer in pairs(active_timers) do
            if active_timers[i].stop == 0 then
                active_timers[i].stop = os.time();
            end
        end
    end
end

function tod_help()
    for x, y in pairs(tod_subcommands) do
        print(chat.header('ToD Subcommands') .. chat.header(x) .. chat.message(y.help));
    end
end

function get_tod(tod_input)
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

function sort_tods(t)
    local temp = {};
    local kv_switch = {};
    for code, nm_data in pairs(t) do
        kv_switch[nm_data.tod + nm_data.Time] = code;
        table.insert(temp, nm_data.tod + nm_data.Time);
    end
    table.sort(temp);
    local result = {}
    for _, x in pairs(temp) do
        table.insert(result, {ID = t[kv_switch[x]].ID, Name = t[kv_switch[x]].Name,
                              Time = t[kv_switch[x]].Time, tod = t[kv_switch[x]].tod,
                              code = kv_switch[x]});
    end
    return result;
end

function list_nms()
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

function clear_tods(args)
    if args[1] then
        for code, _ in pairs(active_tods) do
            if code == args[1] then
                active_tods[code] = nil;
                print(chat.header('ToD') .. chat.message('ToD for ' .. NMs[args[1]].Name .. ' cleared'));
            end
        end
        for code, _ in pairs(active_phs) do
            if code == args[1] then
                active_phs[code] = nil;
                print(chat.header('ToD') .. chat.message('PH for ' .. NMs[args[1]].Name .. ' cleared'));
                break
            end
        end
        for id, _ in pairs(active_timers) do
            if id == tonumber(args[1]) then
                active_timers[id] = nil;
                print(chat.header('ToD') .. chat.message('Timer ' .. id .. ' cleared'));
            end
        end
    else
        active_tods = {};
        active_phs = {};
        active_timers = {};
        print(chat.header('ToD') .. chat.message('All TODs & Timers cleared'));
    end
end

function kill_ph(nm, time)
    print(chat.header('ToD') .. chat.header(NMs[nm].Name) .. chat.message('Next PH at ' ..
          os.date('%X', time + NMs[nm].Time) .. ' (in ' ..
          os.date('!%X', time + NMs[nm].Time - os.time()) .. ')'));
    local new_ph = {};
    new_ph['Time'] = NMs[nm].Time;
    new_ph['Name'] = NMs[nm].Name;
    new_ph['ID'] = NMs[nm].ID;
    new_ph['tod'] = time + (math.random() / 100); -- adds insignificant random to avoid equal keys
    active_phs[nm] = new_ph;
end

function manual_ph_death(args)
    local nm_code = args[1];
    if NMs[nm_code] == nil then
        print(chat.header('ToD') .. chat.message(nm_code .. ' not found'));
        return
    end
    local time_input = args[2];
    tod_time = get_tod(time_input);
    kill_ph(nm_code, tod_time)
end

function kill_nm(nm, time)
    active_tods[nm] = time;
    NMs[nm].up = nil;
    print(chat.header('ToD') .. chat.header(NMs[nm].Name) .. chat.message('NM added to ToD list'));
end

function manual_nm_death(args)
    local nm_code = args[1];
    if NMs[nm_code] == nil then
        print(chat.header('ToD') .. chat.message(nm_code .. ' not found'));
        return
    end
    local time_input = args[2];
    tod_time = get_tod(time_input);
    kill_nm(nm_code, tod_time);
end

function save_nms()
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

function add_nm(args);
    -- check #args is at least 4
    if (#args < 4) then
        print(chat.header('ToD') .. chat.error('Not enough arguments'));
        return
    end

    -- assign arg[1] code, arg[2] name, args[3] respawn
    local code = args[1];
    local name = args[2];
    local min_repop = tonumber(args[3]);
    local respawn = tonumber(args[4]);

    -- check if code is in
    if NMs[code] ~= nil then
        print(chat.header('ToD') .. chat.error('Code already in use'));
        return
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
    save_nms();
end

function del_nm(args)
    if NMs[args[1]] == nil then
        print(chat.header('ToD') .. chat.error('Code not found'));
        return
    end
    print(chat.header('ToD') .. chat.message(NMs[args[1]].Name .. ' removed from list'));
    NMs[args[1]] = nil;
    save_nms();
end

function something_died(dead_thing)
    local current_zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);
    for nm_code, nm_data in pairs(NMs) do
        if nm_data.Zone == nil or nm_data.Zone == current_zone then
            if dead_thing == nm_data.ID then
                kill_nm(nm_code, os.time());
                log_event(os.date('%d/%m/%y %X', time) .. ' | ToD | ' .. nm_data.Name);
            end
            if nm_data.PH ~= nil then
                for _, ID in pairs(nm_data.PH) do
                    if dead_thing == ID then
                        kill_ph(nm_code, os.time());
                    end
                end
            end 
        end
    end
end

function check_for_kills(e)
    if (e.id == 0x029) then
        local message = struct.unpack('H', e.data, 0x18 + 1);
        local mob_id = struct.unpack('H', e.data, 0x16 + 1);
        if (message == 6 or message == 20) then -- 6 defeated, 20 falls to the ground
            something_died(mob_id);
        end
    end
end

function toggle_ui()
    ui_active = not(ui_active);
end

tod_subcommands = {
    ['list'] = {func = list_nms, help = 'Lists NMs'},
    ['clear'] = {func = clear_tods, help = 'Deletes active ToD(s)/Timers, nm code / timer ID for specific, no code for all'},
    ['help'] = {func = tod_help, help = 'Lists ToD subcommands'},
    ['timer'] = {func = start_timer, help = 'Start new ToD Timer; include time for specific start, no time for now'},
    ['stop'] = {func = stop_timer, help = 'Stop ToD Timer(s), include an ID for specific, no ID for all'},
    ['add'] = {func = add_nm, help = 'Adds new NM to list; /tod add {code} {name} {min_respawn} {PH respawn} {ID 0x...} {PH(s) 0x...}'},
    ['del'] = {func = del_nm, help = 'Removes NM from list; /tod del {code}'},
    ['ph'] = {func = manual_ph_death, help = 'Adds new PH time of death; /tod ph {code} {time}'},
    ['nm'] = {func = manual_nm_death, help = 'Adds new NM time of death; /tod nm {code} {time}'},
    ['ui'] = {func = toggle_ui, help = 'Toggles UI'},
};

--[[ Checks for defeated monsters in incoming packet ]]--
ashita.events.register('packet_in', 'packet_in_cb', function (e)
    check_for_kills(e);
end);

--[[ Handle ToD commands ]]--
ashita.events.register('command', 'command_cb', function (e)
    -- Parse the command arguments..
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/tod')) then
        return;
    end

    -- Block all related commands..
    e.blocked = true;

    local new_args = {};
    for i = 3, #args, 1 do
        table.insert(new_args, args[i]);
    end

    -- process known subcommands
    if (tod_subcommands[args[2]] ~= nil) then
        tod_subcommands[args[2]].func(new_args);
        return;
    end

end);

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    local player = GetPlayerEntity();
    if (player == nil or not(ui_active)) then -- when zoning
        return;
    end

    local windowSize = 500;
    imgui.SetNextWindowBgAlpha(0.8);
    imgui.SetNextWindowSize({ windowSize, -1, }, ImGuiCond_Always);
    if (imgui.Begin('ToD', true, bit.bor(ImGuiWindowFlags_NoDecoration))) then
        imgui.TextColored({1.0, 0.5, 1.0, 1.0},'Notorious Monster Tracker');
        imgui.Text('NM ToDs:');
        for x, y in pairs(active_tods) do
            local line = NMs[x].Name .. ' [' .. string.format('%03X', NMs[x].ID) .. ']: ' .. os.date('%X', y) ..' ('
            if os.time() - y > 86400 then
                line = line .. math.floor((os.time() - y) / 86400) .. 'd ';
            end
            if (y + NMs[x].Respawn < os.time()) then
                line = line .. os.date('!%X', os.time() - y - NMs[x].Respawn) .. ' in window)';
                imgui.TextColored({0.5, 0.5, 1.0, 1.0}, line .. ' - Open');
            else
                line = line .. os.date('!%X', NMs[x].Respawn - os.time() + y) .. ' until window)';
                imgui.TextColored({1.0, 0.5, 0.5, 1.0}, line .. ' - ' .. os.date('%X', NMs[x].Respawn));
            end
        end
        imgui.Text('Next PH:');
        for x, y in pairs(sort_tods(active_phs)) do
            local pop = y.tod + y.Time - os.time()
            if pop > 30 then
                imgui.TextColored({ 0.5, 1.0, 0.5, 1.0 }, y.Name .. ' [' .. string.format('%03X', y.ID) ..
                                  ']: ' .. os.date('!%X', pop));
            elseif pop > 0 then
                imgui.TextColored({ 1.0, 1.0, 0.5, 1.0 }, y.Name .. ' [' .. string.format('%03X', y.ID) ..
                                  ']: ' .. os.date('!%X', pop));
            else
                imgui.TextColored({ 1.0, 0.5, 0.5, 1.0 }, y.Name .. ' [' .. string.format('%03X', y.ID) ..
                                  ']: -' .. os.date('!%X', math.abs(pop)));
            end
        end
        imgui.Text('Timers:');
        for x, y in pairs(active_timers) do
            local timer_line = 'Timer ' .. x .. ': ';
            if y.stop == 0 then
                if os.time() - y.start > 86400 then
                    timer_line = timer_line .. math.floor((os.time() - y.start) / 86400) .. 'd ';
                end
                timer_line = timer_line .. os.date('!%X', os.time() - y.start) .. ' (' .. os.time() - y.start .. 's)';
                imgui.TextColored({0.5, 0.5, 1.0, 1.0}, timer_line);
            else
                if y.stop - y.start > 86400 then
                    timer_line = timer_line .. math.floor((y.stop - y.start) / 86400) .. 'd ';
                end
                timer_line = timer_line .. os.date('!%X', y.stop - y.start) .. ' (' .. y.stop - y.start .. 's)';
                imgui.TextColored({0.5, 1.0, 1.0, 1.0}, timer_line);
            end
        end
    end
    imgui.End();
end);
