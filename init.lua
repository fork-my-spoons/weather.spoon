local obj = {}
obj.__index = obj

-- Metadata
obj.name = "weather"
obj.version = "1.0"
obj.author = "Pavel Makhov"
obj.homepage = "https://github.com/fork-my-spoons/jira-issues.spoon"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.indicator = nil
obj.timer = nil
obj.api_key = nil
obj.lat = nil
obj.lon = nil

obj.iconPath = hs.spoons.resourcePath("icons")

local wind_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }})
local humidity_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 12 }})
local sunrise_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 16 }})
local sunset_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 16 }})
local sun_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 16 }, color = {hex = '#F4A71D'}})
local moon_icon = hs.styledtext.new(' ', { font = {name = 'feather', size = 16 }, color = {hex = '#72B8D4'}})


local icon_map = {
    ["01d"] = "clear",
    ["02d"] = "mostlysunny",
    ["03d"] = "partlycloudy",
    ["04d"] = "partlycloudy",
    ["09d"] = "chancerain",
    ["10d"] = "rain",
    ["11d"] = "tstorm",
    ["13d"] = "snow",
    ["50d"] = "fog",
    ["01n"] = "nt_clear",
    ["02n"] = "nt_mostlysunny",
    ["03n"] = "nt_partlycloudy",
    ["04n"] = "nt_partlycloudy",
    ["09n"] = "nt_chancerain",
    ["10n"] = "nt_rain",
    ["11n"] = "nt_tstorm",
    ["13n"] = "nt_snow",
    ["50n"] = "nt_fog"
}

local function updateMenu() 
    local query
    if obj.lat ~= nil and obj.lon ~= nil then
        query = string.format('lat=%s&lon=%s', obj.lat, obj.lon)
    else
        query = 'q=' .. obj.city
    end
    local url = string.format('http://api.openweathermap.org/data/2.5/weather?%s&appid=%s&units=%s', query, obj.app_id, obj.units)
    hs.http.asyncGet(url, nil, function(status, body)
        local weather = hs.json.decode(body)
        obj.indicator:setTitle(math.floor(weather.main.temp + 0.5))
        obj.indicator:setIcon(hs.image.imageFromPath(obj.iconPath .. '/white/png/32x32/' .. icon_map[weather.weather[1].icon] .. '.png'):setSize({w=16,h=16}), false)

        local menu = {}

        table.insert(menu, {
            image = hs.image.imageFromPath(obj.iconPath .. '/white/png/128x128/' .. icon_map[weather.weather[1].icon] .. '.png'):setSize({w=64,h=64}),
            title = hs.styledtext.new('Feels like ' .. math.floor(weather.main.feels_like) .. '\n') 
                .. hs.styledtext.new(weather.weather[1].description .. '\n')
                .. wind_icon .. hs.styledtext.new(weather.wind.speed .. ' m/s\n')
                .. humidity_icon .. hs.styledtext.new(weather.main.humidity .. ' %')
        })

        local sunrise = weather.sys.sunrise
        local sunset = weather.sys.sunset
        local now = weather.dt
        local is_night = now > sunset
        if is_night then 
            s = sunset
            e = sunrise + 86400
        else
            s = sunrise
            e = sunset
        end

        local pct = (weather.dt - s) / (e - s)
        local c = math.floor(40 * pct)
        
        table.insert(menu, {title = '-'})
        table.insert(menu, {
            disabled = false,
            title = 
            (is_night and sunset_icon or sunrise_icon)
            .. hs.styledtext.new(string.rep(' ', c))
            .. (is_night and moon_icon or sun_icon)
            .. hs.styledtext.new(string.rep(' ', 40 - c))
            .. (is_night and sunrise_icon or sunset_icon)
            .. hs.styledtext.new('\n')
            .. hs.styledtext.new(os.date("%H:%M", s))
            .. hs.styledtext.new(string.rep(' ', 38))
            .. hs.styledtext.new(os.date("%H:%M", e), {color = {hex = '#ffffff'}})
        })
        obj.indicator:setMenu(menu)

    end)
end

function obj:init()
    self.indicator = hs.menubar.new()

    self.timer = hs.timer.new(300, updateMenu)
end

function obj:setup(args)
    self.app_id = args.app_id
    self.lat = args.lat
    self.lon = args.lon
    self.city = args.city
    if (args.units == 'f' or args.units == 'F') then
        self.units = 'imperial'
    else
        self.units = 'metric'
    end
end

function obj:start()
    self.timer:fire()
    self.timer:start()
end

return obj