_addon.name = 'hotkeys'
_addon.author = 'Vafilor'
_addon.version = '1.1'

require('logger')
local Button = require("Button")
res = require('resources')

local config = {}

local xRes = windower.get_windower_settings().ui_x_res
local yRes = windower.get_windower_settings().ui_y_res


local player = nil

local last_packet_time = 0
local min_packet_time = 0.025

local finish_act = L{2,3,5}
local start_act = L{7,8,9,12}
local is_busy = 0
local is_casting = false

-- The spell to cast
local spell = "Protect V"

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function debug_message(text, to_log) 
	if (debug == false or text == nil or #text < 1) then
		return
	end

	if (to_log) then
		log("(debug): "..text)
	else
		windower.add_to_chat(207, _addon.name.."(debug): "..text)
	end
end


function check_recast(spell_name)
    local recasts = windower.ffxi.get_spell_recasts()
	local spell = res.spells:with('en', spell_name)
	if (spell == nil) then
        print("spell not found")
		return 0
	end

	local recast = recasts[spell.id]

    return recast
end

a = Button:new({pos={x=100, y=500}})

function check_status()
    local ready = false
    local count = 0

    while not ready and count < 1000 do
        ready = check_recast(spell) <= 0.40
        coroutine.sleep(0.2)
        count = count + 1
    end

    a.image:transparency(0.1)


    print("done")
end

a:add_event_listener("left_click", function() 
    windower.send_command('input /ma "' .. spell.. '" <me>')

    a.image:transparency(0.9)

    return true
end)

local active = true


windower.register_event('incoming chunk', function(id, data)
	if (id ~= 0x28 or not active) then
		return
	end
	local now = os.clock()
	if (now < last_packet_time + min_packet_time) then
		return
	end
	last_packet_time = now

    action = windower.packets.parse_action(data)

	player = windower.ffxi.get_player()

	if (action["actor_id"] == player.id) then 
        local category = action["category"]
        local param = action["param"]

		if start_act:contains(category) then
			if param == 24931 then                  -- Begin Casting/WS/Item/Range
                local spell_id = action["targets"][1]["actions"][1]["param"]
                print("Start casting " .. tostring(spell_id))
				is_busy = 0
				is_casting = true
			elseif param == 28787 then              -- Failed Casting/WS/Item/Range
                print("Failed casting")
				is_casting = false
				is_busy = failed_cast_delay
			end
		elseif category == 6 then                   -- Use Job Ability
			is_busy = ability_delay
		elseif category == 4 then                   -- Finish Casting
            print("Finish casting")
			is_busy = after_cast_delay
			is_casting = false
            coroutine.schedule(check_status, 0.1)
		elseif finish_act:contains(category) then   -- Finish Range/WS/Item Use
			is_busy = 0
			is_casting = false
		end
	end
end)