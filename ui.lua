require ('common');
local imgui = require('imgui');
local NMs = require('NMs');
local utils = require('utils');

local ui = {};
ui.active = true;

ui.toggle = function ()
    ui.active = not(ui.active);
end

ui.update = function (times)
    local player = GetPlayerEntity();
    if (player == nil or not(ui.active)) then -- when zoning
        return;
    end

    local windowSize = 500;
    imgui.SetNextWindowBgAlpha(0.8);
    imgui.SetNextWindowSize({ windowSize, -1, }, ImGuiCond_Always);
    if (imgui.Begin('TodTimers', true, bit.bor(ImGuiWindowFlags_NoDecoration))) then
        imgui.TextColored({1.0, 0.5, 1.0, 1.0},'Notorious Monster Tracker');
        for c, t in pairs(times.active_tods) do
            local line = NMs[c].Name .. ' [' .. string.format('%03X', NMs[c].ID) .. ']: ' .. os.date('%X', t) ..' ('
            if (t + NMs[c].Respawn < os.time()) then
                line = line .. os.date('!%X', os.time() - t - NMs[c].Respawn) .. ' in window)';
                imgui.TextColored({0.5, 0.5, 1.0, 1.0}, line);
            else
                line = line .. os.date('!%X', NMs[c].Respawn - os.time() + t) .. ' until window)';
                imgui.TextColored({1.0, 0.5, 0.5, 1.0}, line);
            end
        end
        imgui.Text('Next PH:');
        for _, ph_tods in pairs(utils.sort_phs(times.active_phs)) do
            local line = NMs[ph_tods.code].Name;
            for _, ph_id in pairs(NMs[ph_tods.code].PH) do
                line = line .. ' ['.. string.format('%03X', ph_id) .. ']';
            end
            local pop = ph_tods.tod + NMs[ph_tods.code].Time - os.time()
            if pop > 30 then
                imgui.TextColored({ 0.5, 1.0, 0.5, 1.0 }, line .. ': ' .. os.date('!%X', pop));
            elseif pop > 0 then
                imgui.TextColored({ 1.0, 1.0, 0.5, 1.0 }, line ..': ' .. os.date('!%X', pop));
            else
                imgui.TextColored({ 1.0, 0.5, 0.5, 1.0 }, line .. ': -' .. os.date('!%X', math.abs(pop)));
            end
        end
        imgui.Text('Timers:');
        for x, y in pairs(times.active_timers) do
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