local NMs = require('NMs');
local utils = require('utils')

monitor = {};

monitor._something_died = function (mob_id)
    local current_zone = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);
    for nm_code, nm_data in pairs(NMs) do
        if nm_data.Zone == nil or nm_data.Zone == current_zone then
            if mob_id == nm_data.ID then
                utils.log_event('ToD', nm_data.Name);
                return 'nm', nm_code, os.time();
            end
            if nm_data.PH ~= nil then
                for _, ID in pairs(nm_data.PH) do
                    if mob_id == ID then
                        return 'ph', nm_code, os.time();
                    end
                end
            end 
        end
    end
end

monitor.check_for_kills = function (packet)
    if (packet.id == 0x029) then
        local message = struct.unpack('H', packet.data, 0x18 + 1);
        local mob_id = struct.unpack('H', packet.data, 0x16 + 1);
        if (message == 6 or message == 20) then -- 6 defeated, 20 falls to the ground
            return monitor._something_died(mob_id);
        end
    end
end

return monitor;