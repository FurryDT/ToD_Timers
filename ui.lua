require ('common');
local imgui = require('imgui');
local NMs = require('NMs');
local utils = require('utils');

local ui = {};
ui.active = True
ui.active_tods = {};
ui.active_phs = {};
ui.active_timers = {};

-- test entries into ui:
table.insert(ui.active_timers, {start = os.time(), stop = 0});

local new_ph = {};
new_ph['Time'] = NMs['ex'].Time;
new_ph['Name'] = NMs['ex'].Name;
new_ph['ID'] = NMs['ex'].ID;
new_ph['tod'] = os.time() - 10;
ui.active_phs['ex'] = new_ph;

ui.active_tods['ex'] = os.time() - 20;
-- end of test entries

ui.update = function ()
    local windowSize = 500;
    imgui.SetNextWindowBgAlpha(0.8);
    imgui.SetNextWindowSize({ windowSize, -1, }, ImGuiCond_Always);
    if (imgui.Begin('TodTimers', true, bit.bor(ImGuiWindowFlags_NoDecoration))) then
        imgui.TextColored({1.0, 0.5, 1.0, 1.0},'Notorious Monster Tracker');
        for x, y in pairs(ui.active_tods) do
            local line = NMs[x].Name .. ' [' .. string.format('%03X', NMs[x].ID) .. ']: ' .. os.date('%X', y) ..' ('
            if (y + NMs[x].Respawn < os.time()) then
                line = line .. os.date('!%X', os.time() - y - NMs[x].Respawn) .. ' in window)';
                imgui.TextColored({0.5, 0.5, 1.0, 1.0}, line);
            else
                line = line .. os.date('!%X', NMs[x].Respawn - os.time() + y) .. ' until window)';
                imgui.TextColored({1.0, 0.5, 0.5, 1.0}, line);
            end
        end
        imgui.Text('Next PH:');
        for x, y in pairs(utils.sort_tods(ui.active_phs)) do
            local line = y.Name;
            for _, ph_id in pairs(NMs[y.code].PH) do
                line = line .. ' ['.. string.format('%03X', ph_id) .. ']';
            end
            local pop = y.tod + y.Time - os.time()
            if pop > 30 then
                imgui.TextColored({ 0.5, 1.0, 0.5, 1.0 }, line .. ': ' .. os.date('!%X', pop));
            elseif pop > 0 then
                imgui.TextColored({ 1.0, 1.0, 0.5, 1.0 }, line ..': ' .. os.date('!%X', pop));
            else
                imgui.TextColored({ 1.0, 0.5, 0.5, 1.0 }, line .. ': -' .. os.date('!%X', math.abs(pop)));
            end
        end
        imgui.Text('Timers:');
        for x, y in pairs(ui.active_timers) do
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
end

return ui;