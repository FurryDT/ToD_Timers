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
addon.name     = 'ToDTimers';
addon.desc     = 'Diplays timers for NM repops';
addon.version  = '2.0';

require ('common');
require('sugar');
local NMs = require('NMs');
local ui = require('ui');
local utils = require('utils');
local chat = require('chat');
local times = require('times');
local monitor = require('monitor');

function tod_help()
    for x, y in pairs(tod_subcommands) do
        print(chat.header('ToD Subcommands') .. chat.header(x) .. chat.message(y.help));
    end
end

function ph_death(args)
    local nm_code = args[1];
    if NMs[nm_code] == nil then
        print(chat.header('ToD') .. chat.message(nm_code .. ' not found'));
        return
    end
    local time_input = args[2];
    tod_time = utils.process_time_entry(time_input);
    times:kill_ph(nm_code, tod_time)
end

function nm_death(args)
    local nm_code = args[1];
    if NMs[nm_code] == nil then
        print(chat.header('ToD') .. chat.message(nm_code .. ' not found'));
        return
    end
    local time_input = args[2];
    tod_time = utils.process_time_entry(time_input);
    times:kill_nm(nm_code, tod_time);
end

tod_subcommands = {
    ['help'] = {func = tod_help, help = 'Lists ToD subcommands'},
    ['ui'] = {func = ui.toggle, help = 'Toggles UI'},
    ['list'] = {func = utils.list_nms, help = 'Lists NMs'},
    ['timer'] = {func = function (...) times:start_timer(...); end, help = 'Start new ToD Timer; include time for specific start, no time for now'},
    ['stop'] = {func = function (...) times:stop_timer(...); end, help = 'Stop ToD Timer(s), include an ID for specific, no ID for all'},
    ['clear'] = {func = function (...) times:clear(...); end, help = 'Deletes active ToD(s)/Timers, nm code / timer ID for specific, no code for all'},
    ['ph'] = {func = ph_death, help = 'Adds new PH time of death; /tod ph {code} {time}'},
    ['nm'] = {func = nm_death, help = 'Adds new NM time of death; /tod nm {code} {time}'},
    ['add'] = {func = function (...) NMs = utils.add_nm(NMs, ...); end, help = 'Adds new NM to list; /tod add {code} {name} {min_respawn} {PH respawn} {ID 0x...} {PH(s) 0x...}'},
    ['del'] = {func = function (...) NMs = utils.del_nm(NMs, ...); end, help = 'Removes NM from list; /tod del {code}'},
};

--[[ Checks for defeated monsters in incoming packet ]]--
ashita.events.register('packet_in', 'packet_in_cb', function (e)
    local t = nil
    local code = nil
    local time = nil
    t, code, time = monitor.check_for_kills(e);
    if t ~= nil then
        if t == 'nm' then
            times:kill_nm(code, time);
        end
        if t == 'ph' then
            times:kill_ph(code, time);
        end
    end
end);

--[[ Handle ToD commands ]]--
ashita.events.register('command', 'command_cb', function (e)
    -- Parse the command arguments..
    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/tod2')) then -- needs updating to just /tod
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

    tod_help();

end);

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    ui.update(times);
end);
