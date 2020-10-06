local config = require("config")

-- split string into list via delimiter
local split = function(in_str, delim)
    local list = {};
    for match in (in_str..delim):gmatch("(.-)"..delim) do
        table.insert(list, match);
    end
    return list;
end

-- concatenate two lists
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

-- path down the tree in config.lua data = {} (configdata) to find which setting apply to an object
-- split path is the path to the object split by "/"
-- maxstep tells the function how far down the path to the object is defined in configdata and hence to what depth it has to parse configdata for __settings__ keys
local lookForTreeSettings = function(configdata, split_path, maxstep)
	local settings = {}

	for i=1,maxstep do
		-- accumulate & overwrite settings as we travel down the path in config.lua data = {}
		for key,val in pairs(configdata["__settings__"] or {}) do
			settings[key] = val
		end
		-- move down a step in config.lua data = {}
		configdata = configdata[split_path[i]]
	end

	return settings
end

-- See if a path from data.raw is among those declared in the config.lua data = {} table as one to be retextured & hence if the path needs to be changed to the retextured version
isReplaceItem = function(path, step)
	step = step or 1
	local split_path = split(path:gsub("__", ""), "/")

	-- not sure of whether lua keeps variable reference if passed as arguments into a function; hence I pass a key list to the function, and then have it path to where that keylist goes

	local configdata = config.data
	for i=1,step do
		if not(i == step) then
			configdata = configdata[split_path[i]]
		end
	end

	-- count measures the number of items denoted in the current config.lua data = {} marked directory
	local count = 0
	for key,item in pairs(configdata) do
		-- look through the contents of the current config.lua data = {} marked directory
		if not(key == "__settings__") then
			count = count + 1
			-- if there is another folder denoted inside config.lua data = {} which has the same name as the folder path of the image that is being replaced then increment step to go into the next directory down the path, and recursively call this function again to explore the contents of the next folder down
			if (key == split_path[step]) then
				return isReplaceItem(path, step + 1)
			end
		end
	end
	-- when count is 0, there are no subdirectories marked down in config.lua data = {}, either a file or undefined folder has been reached
	-- if its a file, that the path to that file should be changed
	-- if its an undefined folder, than the path given is of an item inside of it. All contents of undefined folders are retextured, so this file falls among that umbrella, and its path should be changed
	if (count == 0) then
		-- find the settings that apply down this config.lua data = {} path
		return lookForTreeSettings(config.data, split_path, step)
	end

	-- this is reached if the path is not among those denoted in config.lua data = {}
	return
end

-- adjust metadata of importing image/sound at path in data.raw as set by the settings accumulated in lookForTreeSettings
local adjustDataDotRaw = function(path, filename_key, new_path, settings)
	local pathed_data = data.raw
	for index,key in pairs(path) do
		pathed_data = pathed_data[key]
	end

	-- do not overwrite image path if image name contains an element of exclude_names declared in settings
	if type(settings["exclude_names"]) == "table" then
		local split_path = split(pathed_data[filename_key], "/")

		for index,name in pairs(settings["exclude_names"]) do
			if string.match(split_path[#split_path], name) then
				-- return before overwriting path
				return
			end
		end
	end

	-- overwrite old path with path to retextured version
	pathed_data[filename_key] = new_path

	-- adjust image width, height and scale depending on what the upscale setting is ()
	if not(settings["upscale"] == nil) then
		local scale = math.pow(settings["upscale"], -1)/2
		-- see if where the data.raw table in which the image path is stored under "filename", also includes keys "height" and "width"
		if not(pathed_data["width"] == nil or pathed_data["height"] == nil) then
			-- if so, overwrite all of those
			pathed_data["width"] = pathed_data["width"] * math.floor(settings["upscale"])
			pathed_data["height"] = pathed_data["height"] * math.floor(settings["upscale"])
			pathed_data["scale"] = scale
		end
	end
	return
end

-- recursively loop through data.raw to find strings (and the list of keys that leads to them in data.raw) which resemble file paths ending in .png, .jpg and .ogg
checkData = function(path)

	-- path is a keylist in data.raw in which this fuction will look for paths that match the description above
	-- navigate to the location in data.raw denoted by path keylist
	local pathed_data = data.raw
	for index,key in pairs(path) do
		pathed_data = pathed_data[key]
	end

	-- look for strings that match the description above in the current data.raw table
	for key,item in pairs(pathed_data) do
		if (type(item) == "string") then
			local itemtype = split(item, "%p")
			-- ensure this file has not already been retextured
			if not(itemtype[3] == config.resource_pack_name) then
				itemtype = itemtype[#itemtype]
				-- ensure the filetype matches .png, .jpg or .ogg
				if (itemtype == "png" or itemtype == "jpg" or itemtype == "ogg") then
					-- use the isReplaceItem to check if config.lua marks this data.raw path to be replaced by a retextured version
					local settings = isReplaceItem(item)
					if type(settings) == "table" then
						-- if so, a settings table is returned containing any other changes that need to be made to data.raw in regards to the file being retextured
						local changed_item_path = "__" .. config.resource_pack_name .. "__/data/" .. item:gsub("__", "")
						-- assign new file path and adjust data.raw according to settings using adjustDataDotRaw function
						adjustDataDotRaw(path, key, changed_item_path, settings)
					end
				end
			end	
		elseif (type(item) == "table") then
			-- if this folder in data.raw contains other folders, add these to the path and recursively call this function to explore the contents of these folders as well for .png, .jpg and .ogg file paths
			checkData(concat(path, {key}))
		end
	end
end

-- only trigger checkdata to look for paths that fit config.lua data = {} table if that table is not empty (__settings__ doesn't count as a directory entry)
-- Important, as if it were & checkData ran, all files of all actively running mods would need to be retextured (all of data.raw), which is unsustainable, as it would make texturepacks break if it was run with mods that weren't retextured!

local dircount = 0
for key,content in pairs(config.data) do
	if not(key == "__settings__") then
		dircount = dircount + 1
	end
end

if dircount > 0 then
	checkData({})
end
