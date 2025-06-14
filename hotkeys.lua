_addon.name = 'hotkeys'
_addon.author = 'Vafilor'
_addon.version = '1.1'

require('logger')
buttons = require('buttons')

local config = {}

local xRes = windower.get_windower_settings().ui_x_res
local yRes = windower.get_windower_settings().ui_y_res


btn2 = buttons.new(500, 500)

btn2:add_event_listener("click", function(button)
    print("Button was clicked!")

    return true
end)