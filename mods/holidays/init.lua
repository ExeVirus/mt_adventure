holidays = {}

holidays.modname = minetest.get_current_modname()
holidays.modpath = minetest.get_modpath(holidays.modname)

dofile(holidays.modpath).."/documentation.lua")

function holidays.log(level, message, ...)
    return minetest.log(level, ("[%s] %s"):format(holidays.modname, message:format(...)))
end

--[[
    local time = os.time() -- a number
    os.date("*t", time) -- {year = 1998, month = 9, day = 16, yday = 259, wday = 4,
     hour = 23, min = 48, sec = 10, isdst = false}
]]--

local function date_lte(d1, d2)
    return d1.month < d2.month or (d1.month == d2.month and d1.day <= d2.day)
end

local function date_range_predicate(start, stop)
    if date_lte(start, stop) then
        return function(date)
            return date_lte(start, date) and date_lte(date, stop)
        end
    else
        return function(date)
            return date_lte(date, stop) or date_lte(start, date)
        end
    end
end

local function or_(...)
    local funs = {...}
    return function(date)
        for _, fun in ipairs(funs) do
            if fun(date) then return true end
        end
        return false
    end
end


-----Holiday Updates
holidays.schedule = {
    christmas = date_range_predicate({month=12, day=24}, {month=12, day=26}),
    easter = date_range_predicate({month=4, day=14}, {month=4, day=20}),  -- 2022 date
    fireworks = or_(
            date_range_predicate({month=7, day=2}, {month=7, day=5}), -- july 4th
            date_range_predicate({month=12, day=31}, {month=1, day=1})  -- new years
    ),
}

function holidays.is_holiday_active(holiday_name)
    local time = os.time()
    local date = os.date("*t", time)
    local predicate = holidays.schedule[holiday_name]
    return predicate and predicate(date)
end

dofile(holidays.modpath .. "/christmas.lua")
dofile(holidays.modpath .. "/easter.lua")
dofile(holidays.modpath .. "/fireworks.lua")
