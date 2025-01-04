require('sugar');
local chat = require('chat');
local utils = require('utils');
local NMs = require('NMs');

times = {};
times.active_tods = {};
times.active_phs = {};
times.active_timers = {};

times.clear = function (self, args)
    if args[1] then
        for code, _ in pairs(self.active_tods) do
            if code == args[1] then
                self.active_tods[code] = nil;
                print(chat.header('ToD') .. chat.message('ToD for ' .. NMs[args[1]].Name .. ' cleared'));
            end
        end
        for code, _ in pairs(self.active_phs) do
            if code == args[1] then
                self.active_phs[code] = nil;
                print(chat.header('ToD') .. chat.message('PH for ' .. NMs[args[1]].Name .. ' cleared'));
            end
        end
        for id, _ in pairs(self.active_timers) do
            if id == tonumber(args[1]) then
                self.active_timers[id] = nil;
                print(chat.header('ToD') .. chat.message('Timer ' .. id .. ' cleared'));
            end
        end
    else
        self.active_tods = {};
        self.active_phs = {};
        self.active_timers = {};
        print(chat.header('ToD') .. chat.message('All TODs & Timers cleared'));
    end
end

times.start_timer = function (self, args)
    if #args == 0 then
        table.insert(self.active_timers, {start = os.time(), stop = 0});
        print(chat.header('ToD') .. chat.message('New Timer started at ' .. os.date('%X', os.time())));
        return
    end
    table.insert(self.active_timers, {start = utils.process_time_entry(args[1]), stop = 0});
    print(chat.header('ToD') .. chat.message('New Timer started at ' .. os.date('%X', utils.process_time_entry(args[1]))));
end

times.stop_timer = function (self, args)
    if args[1] then
        self.active_timers[tonumber(args[1])].stop = os.time();
    else
        for i, timer in pairs(self.active_timers) do
            if timer.stop == 0 then
                self.active_timers[i].stop = os.time();
            end
        end
    end
end

times.kill_ph = function (self, nm, time)
    print(chat.header('ToD') .. chat.header(NMs[nm].Name) .. chat.message('Next PH at ' ..
          os.date('%X', time + NMs[nm].Time) .. ' (in ' ..
          os.date('!%X', time + NMs[nm].Time - os.time()) .. ')'));
    self.active_phs[nm] = time + (math.random() / 100); -- adds insignificant random to avoid equal keys in sort
end

times.kill_nm = function (self, nm, time)
    print(chat.header('ToD') .. chat.header(NMs[nm].Name) .. chat.message('NM added to ToD list'));
    self.active_tods[nm] = time;
end

return times;