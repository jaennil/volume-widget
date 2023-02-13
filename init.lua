local gears = require("gears")
local wibox = require("wibox")

-- capture returned output from a shell command
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

volume_widget = wibox.widget.textbox()
volume_widget.set_align("right")
volume_widget:connect_signal("button::release", function(_, _, _, button)
    os.execute("amixer -q sset Master toggle")
    volume_widget.text = get_volume()
end)

function get_volume()
    local volume = os.capture("awk -F\"[][]\" '/dB/ { print $2 }' <(amixer sget Master)", true)
    local state = os.capture("amixer get Master", true)
    if string.find(state, "off") then
        volume = "Mut"
    else
        volume = volume .. "%"
    end
    return volume
end

volume_widget.text = get_volume()

volume_timer = gears.timer({ timeout = 0.1})

function update_volume()
    volume_widget:set_markup(get_volume())
end

volume_timer:connect_signal("timeout", function () update_volume() end)
volume_timer:start()

return setmetatable(volume_widget, { __call = function(_, ...) return volume_widget end })
