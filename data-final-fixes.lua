local config = require("config")


local split = function(in_str, delim)
    local list = {};
    for match in (in_str..delim):gmatch("(.-)"..delim) do
        table.insert(list, match);
    end
    return list;
end

local concat = function(list1, list2)
	local new_list = {}
	for index,item in pairs(list1) do
		new_list[#new_list + 1] = item
	end
	for index,item in pairs(list2) do
		new_list[#new_list + 1] = item
	end
	return new_list
end

isReplaceItem = function(path, step)
	step = step or 1
	local split_path = split(path:gsub("__", ""), "/")

	configdata = config.data
	for i=1,step do
		if not(i == step) then
			configdata = configdata[split_path[i]]
		end
	end

	local count = 0
	for key,item in pairs(configdata) do
		--log(key .. )
		count = count + 1
		if (key == split_path[step]) then
			return isReplaceItem(path, step + 1)

		elseif (item == split_path[step]) then
			return true
		end
	end
	if (count == 0) then
		return true
	end
	return false
end

checkData = function(path)
	--local builder = ""
	--for index,key in pairs(path) do
	--	builder  = builder .. key .. ", "
	--end
	--log(builder)

	local pathed_data = data.raw
	for index,key in pairs(path) do
		pathed_data = pathed_data[key]
	end

	for key,item in pairs(pathed_data) do
		if (type(item) == "string") then
			local itemtype = split(item, "%p")

			if not(itemtype[3] == config.resource_pack_name) then
				itemtype = itemtype[#itemtype]
				if (itemtype == "png" or itemtype == "jpg" or itemtype == "ogg") then
					if (isReplaceItem(item)) then
						--log(item)
						local changed_item_path = "__" .. config.resource_pack_name .. "__/data/" .. item:gsub("__", "")
						--log(changed_item_path)
						pathed_data[key] = changed_item_path
					end
				end
			end	
		elseif (type(item) == "table") then
			--log(tostring(key) .. " " .. type(item))
			--log(tostring(#concat(path, {key})))
			checkData(concat(path, {key}))
		end
	end
end

if not(next(config.data) == nil) then
	checkData({})
end
