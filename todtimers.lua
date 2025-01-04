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
addon.version  = '2.0';

require ('common');
tod_ui = require('tod');

--[[ Checks for defeated monsters in incoming packet ]]--
ashita.events.register('packet_in', 'packet_in_cb', function (e)

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

end);

--[[
* event: d3d_present
* desc : Event called when the Direct3D device is presenting a scene.
--]]
ashita.events.register('d3d_present', 'present_cb', function ()
    tod_ui.update();
end);
