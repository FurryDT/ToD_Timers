local utils = {};

utils.sort_tods = function (t)
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

return utils;