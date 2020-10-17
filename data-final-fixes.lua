local config = require("config")



-- utility functions

-- split string into list via delimiter
local split = function(in_str, delim)
    local list = {};
    for match in (in_str..delim):gmatch("(.-)"..delim) do
        table.insert(list, match);
    end
    return list;
end

local mlog = function(a, b)
	return math.log(a) / math.log(b)
end

local firstIndex = function(in_table)
	for index,item in pairs(in_table) do
		return index
	end
end

local in_table = function(in_table, comp_table)
	for index,obj in pairs(in_table) do
		for _index,compObj in pairs(comp_table) do
			if (index == compObj) or (obj == compObj) then
				return true
			end
		end
	end
	return false
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



-- wild card string parsing functions

-- return a list of indices at which the target string can be found in the item string
local findIndices = function(item, target)
	local count = 1
	local offset = 1
	local indiceList = {}

	for i=1,#item do
		local letter = string.sub(item, i, i)
		count = count + 1

		if not(letter == string.sub(target, count-1, count-1)) then
			offset = offset + count - 1
			count = 1
		end

		if (count == #target + 1) and (letter == string.sub(target, count-1, count-1)) then
			indiceList[#indiceList + 1] = offset
			offset = offset + count - 1
			count = 1
		end
	end
	return indiceList
end

-- separates the items in search by wild cards (*). Ensures these separated terms can be found in the specified order in the final item string, and that if there are no wild cards at the beginning/end of the serach string, the beginning / end of the search string are also the beginning / end of the item string
local isValidTerm = function(search, item)
	-- separate search by wild cards
	local split_search = split(search, "*")
	-- last index is used to store the index position of the previous term in split_search, ensuring that the next has a higher index in the item string
	local lastIndex = 0

	-- loop through elements of split_search (the text between the wildcards) to see if and where they are found in the string
	for matchObjIndex=1,#split_search do
		-- ensure element is not "" (happens when '*' is at beginning / end of string, or people write '**' for some reason)
		if not(split_search[matchObjIndex] == "") then
			indiceList = findIndices(item, split_search[matchObjIndex])

			if (#indiceList == 0) then
				-- the element of split_search can't be found in the item string
				return false
			end

			-- select the earliest occurence of the search element in item that comes after the index of a prior search element for thisIndex
			-- respectively change lastIndex for future search elements
			local thisIndex = nil
			for index,itemIndex in pairs(indiceList) do
				if itemIndex > lastIndex then
					thisIndex = itemIndex
					lastIndex = thisIndex
					break
				end
			end

			if thisIndex == nil then
				-- An occurence of the search element can't be found in the item string AFTER the prior search element
				return false
			
			elseif matchObjIndex == 1 and not(split_search[matchObjIndex] == "") and not(thisIndex == 1) then
				-- This is the first search element, and it doesn't have a wildcard (*) in front of it! Yet the item string does not start with this search element
				return false

			elseif matchObjIndex == #split_search and not(split_search[matchObjIndex] == "") and not(thisIndex == #item - #split_search[matchObjIndex] + 1) then
				-- This is the last search element, and it doesn't have a wildcard (*) in after it! Yet the item string does not end with this search element
				return false
			end
		end
	end
	return true
end



-- recursive data.lua & config.lua data table parsing, editing and __settings__ attribute finding code

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
		-- move down a step in config.lua data = {} It does so by comparing every key in config.lua with respective directory in the data.raw path. If the wildcard comparison makes the strings out to be equal, that key's contents are compared to the next step of the path next!
		for key,step in pairs(configdata) do
			if not(key == "__settings__") then
				if (isValidTerm(key, split_path[i]) == true) then
					step_name = key
				end
			end
		end
		configdata = configdata[step_name]
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
			local step_name = ""
			for key,step in pairs(configdata) do
				-- move down a step in config.lua data = {} It does so by comparing every key in config.lua with respective directory in the data.raw path. If the wildcard comparison makes the strings out to be equal, that key's contents are compared to the next step of the path next!
				if not(key == "__settings__") then
					if (isValidTerm(key, split_path[i]) == true) then
						step_name = key
					end
				end
			end
			configdata = configdata[step_name]
		end
	end

	-- count measures the number of items denoted in the current config.lua data = {} marked directory
	local count = 0
	for key,item in pairs(configdata) do
		-- look through the contents of the current config.lua data = {} marked directory
		if not(key == "__settings__") then
			count = count + 1
			-- if there is another folder denoted inside config.lua data = {} which has the same name as the folder path of the image that is being replaced then increment step to go into the next directory down the path, and recursively call this function again to explore the contents of the next folder down
			if (isValidTerm(key, split_path[step])) then
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
	local generic_data = data.raw

	for pathIndex=1,#path do
		pathed_data = pathed_data[path[pathIndex]]
		if pathIndex < #path-1 then
			generic_data = generic_data[path[pathIndex]]
		end
	end

	-- do not overwrite image path if image name contains an element of exclude_names declared in settings
	if type(settings["exclude_names"]) == "table" then
		local split_path = split(pathed_data[filename_key], "/")

		for index,name in pairs(settings["exclude_names"]) do

			if(isValidTerm(name, split_path[#split_path])) then
				-- return before overwriting path
				return
			end
		end
	end


	-- adjust image width, height and scale & other properties depending on what the upscale setting is
	if not(settings["upscale"] == nil) and not(settings["upscale"] == 0) then
		

		-- Primary Checks: Ensures images are not changed if they exceed the sprite size limit (note, does not work for all sprites)

		if type(pathed_data["size"]) == "number" then
			if (math.max(math.floor(pathed_data["size"] * settings["upscale"]), 1) >= 8192) then
				log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
				return
			end
		elseif type(pathed_data["size"]) == "table" then
			if (math.max(math.floor(pathed_data["size"][1] * settings["upscale"]), 1) >= 8192 or math.max(math.floor(pathed_data["size"][2] * settings["upscale"]), 1) > 8192) then
				log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
				return
			end
		end

		if type(pathed_data["width"]) == "number" then
			if (math.max(math.floor(pathed_data["width"] * settings["upscale"]), 1) >= 8192) then
				log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
				return
			end
		elseif type(pathed_data["height"]) == "number" then
			if (math.max(math.floor(pathed_data["height"] * settings["upscale"]), 1) >= 8192) then
				log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
				return
			end
		end

		-- find width of animations
		if type(pathed_data["width"]) == "number" and type(pathed_data["line_length"]) == "number" then
			if (math.max(math.floor(pathed_data["line_length"] * pathed_data["width"] * settings["upscale"]), 1) >= 8192) then
				log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
				return
			end
		end
		-- find height of animations
		if type(pathed_data["height"]) == "number" and type(pathed_data["line_length"]) == "number" then
			if (math.max(math.floor(math.ceil((pathed_data["frame_count"] or 1) / pathed_data["line_length"]) * pathed_data["height"] * settings["upscale"]), 1) >= 8192) then
				log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
				return
			end
		end


		-- Secondary Checks: Ensure no values are manipulated twice (and hence deviate 2x as far from the original value as they should)

		if type(pathed_data["stripes"]) == "table" then
			return
		end

		-- ensure animation with term filenames={} is below max resolution of 8192 x / y after rescaling
		if (path[#path] == "filenames" and type(generic_data[path[#path-1]]["slice"]) == "number") then
			if filename_key == 1 then
				if (type(generic_data[path[#path-1]]["width"]) == "number" and math.max(math.floor(generic_data[path[#path-1]]["width"] * generic_data[path[#path-1]]["slice"] * settings["upscale"]), 1) >= 8192) then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
				if (type(generic_data[path[#path-1]]["height"]) == "number" and math.max(math.floor(generic_data[path[#path-1]]["height"] * generic_data[path[#path-1]]["slice"] * settings["upscale"]), 1) >= 8192) then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
			else
				-- check if the first element of animation has already been retextured; if not the animation sprite paths are not replaced as its upscaled width is higher than or equal to the max texture size of 8192
				local split_element_one_path = split(generic_data[path[#path-1]]["filenames"][1], "/")
				if not(split_element_one_path[1] == "__" .. config.resource_pack_name .. "__") then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
			end
		end

		-- ensure animation with term stripes={} is below max resolution of 8192 x / y after rescaling
		if (path[#path-1] == "stripes") then
			if (path[#path] == 1) then
				if (not(generic_data["slice_x"] == nil) and not(generic_data["width"] == nil) and math.max(math.floor(generic_data["width"] * generic_data["slice_x"] * settings["upscale"]), 1) >= 8192) then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
				if (not(generic_data["slice_y"] == nil) and not(generic_data["height"] == nil) and math.max(math.floor(generic_data["height"] * generic_data["slice_y"] * settings["upscale"]), 1) >= 8192) then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
				if (not(generic_data["dice_x"] == nil) and not(generic_data["width"] == nil) and math.max(math.floor(generic_data["width"] * generic_data["dice_x"] * settings["upscale"]), 1) >= 8192) then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
				if (not(generic_data["dice_y"] == nil) and not(generic_data["height"] == nil) and math.max(math.floor(generic_data["height"] * generic_data["dice_y"] * settings["upscale"]), 1) >= 8192) then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
			else
				-- check if the first element of animation has already been retextured; if not the animation sprite paths are not replaced as its upscaled width is higher than or equal to the max texture size of 8192
				local split_element_one_path = split(generic_data["stripes"][1][filename_key], "/")
				if not(split_element_one_path[1] == "__" .. config.resource_pack_name .. "__") then
					log("[ERROR]: Image @ " .. new_path .. " is wider / taller than 8192 px (maximum)! It can't be loaded into the game!")
					return
				end
			end
		end


		-- General Value Manipulation: Change image scaling etc. stored in same table as image

		pathed_data["scale"] = (pathed_data["scale"] or 1) / settings["upscale"]
		--log("scale: " .. pathed_data["scale"])

		if not(pathed_data["width"] == nil) then
			pathed_data["width"] = math.max(math.floor(pathed_data["width"] * settings["upscale"]), 1)
			--log("width: " .. pathed_data["width"])
		end
		if not(pathed_data["height"] == nil) then
			pathed_data["height"] = math.max(math.floor(pathed_data["height"] * settings["upscale"]), 1)
			--log("height: " .. pathed_data["height"])
		end

		if not(pathed_data["x"] == nil) then
			pathed_data["x"] = math.floor(pathed_data["x"] * settings["upscale"])
			--log("x: " .. pathed_data["x"])
		end

		if not(pathed_data["y"] == nil) then
			pathed_data["y"] = math.floor(pathed_data["y"] * settings["upscale"])
			--log("y: " .. pathed_data["y"])
		end

		-- used when x and y property are 0
		if not(pathed_data["position"] == nil) then
			pathed_data["position"] = {math.floor(pathed_data["position"][1] * settings["upscale"]), math.floor(pathed_data["position"][2] * settings["upscale"])}
			--log("x: " .. tostring(pathed_data["position"][1]) .. ", " .. tostring(pathed_data["position"][2]))
		end

		-- sets icon_size if no icons={} or pictures={} table are specified in icon prototype
		if (not(pathed_data["icon_size"] == nil) and filename_key == "icon" and pathed_data["icons"] == nil and pathed_data["pictures"] == nil) then
			pathed_data["icon_size"] = math.max(math.floor(pathed_data["icon_size"] * settings["upscale"]), 1)
		end


		-- Type specific value manipulation: Certain types of sprite importing e.g. as part of an animation, need different values

		if (generic_data["type"]) == "item" then
			if (type(pathed_data["size"]) == "table") then
				pathed_data["size"] = {pathed_data["size"][1] * settings["upscale"], pathed_data["size"][2] / settings["upscale"]}
			elseif (type(pathed_data["size"]) == "number") then
				pathed_data["size"] = pathed_data["size"] * settings["upscale"]
			end
		end

		-- scales shortcut GUI elements
		if (generic_data[path[#path-1]]["type"] == "shortcut") then
			pathed_data["size"] = math.max(math.floor(pathed_data["size"] * settings["upscale"]))
		end

		-- sets item / icon prototype icon_size when images are specified under pictures={} or icons={} keys
		if (generic_data["type"] == "icon" or generic_data["type"] == "item") and (path[#path] == firstIndex(generic_data[path[#path-1]])) then
			generic_data["icon_size"] = math.max(math.floor(generic_data["icon_size"] * settings["upscale"]), 1)
		end

		-- prevents black tiles in scaled terrain (may cause some texture tileability issues)
		if not(pathed_data["probability"] == nil) then
			pathed_data["probability"] = 1
			--log("y: " .. pathed_data["probability"])
		end


		-- upscales resources
		if (path[#path] == "sheet" and path[#path-1] == "stages") or (path[#path-1] == "sheet" and path[#path] == "hr_version") then
			if not(pathed_data["size"] == nil) then
				pathed_data["size"] = pathed_data["size"] * settings["upscale"]
			end
		end

		-- Adjusts properties for animations making use of the stripes attribute
		if (path[#path-1] == "stripes" and path[#path] == 1) then
			pathed_data["scale"] = (pathed_data["scale"] or 1) / settings["upscale"]
			if not(generic_data["scale"] == nil) then
				generic_data["scale"] = generic_data["scale"] / settings["upscale"]
			end
			if not(generic_data["width"] == nil) then
				generic_data["width"] = math.max(math.floor(generic_data["width"] * settings["upscale"]), 1)
			end
			if not(generic_data["height"] == nil) then
				generic_data["height"] = math.max(math.floor(generic_data["height"] * settings["upscale"]), 1)
			end
			if not(generic_data["x"] == nil) then
				generic_data["x"] = math.floor(generic_data["y"] * settings["upscale"])
			end
			if not(generic_data["y"] == nil) then
				generic_data["y"] = math.floor(generic_data["y"] * settings["upscale"])
			end
			--[[if not(generic_data["size"] == nil) then
				if (type(generic_data["size"]) == "table") then
					generic_data["size"] = {math.pow(2, math.floor(mlog(2, math.max(generic_data["size"][1] * settings["upscale"], 1)))), math.pow(2, math.floor(mlog(2, math.max(generic_data["size"][2] * settings["upscale"], 1))))}
				elseif (type(pathed_data["size"]) == "number") then
					generic_data["size"] = math.pow(2, math.floor(mlog(2, math.max(generic_data["size"] * settings["upscale"], 1))))
				end
			end]]--
		end
		-- Adjusts properties for animations making use of the layers TileTransitions filenames attribute
		if (path[#path] == "filenames" and filename_key == 1) then
			if not(generic_data[path[#path-1]]["scale"] == nil) then
				generic_data[path[#path-1]]["scale"] = generic_data[path[#path-1]]["scale"] / settings["upscale"]
			end
			if not(generic_data[path[#path-1]]["width"] == nil) then
				generic_data[path[#path-1]]["width"] = math.max(math.floor(generic_data[path[#path-1]]["width"] * settings["upscale"]), 1)
			end
			if not(generic_data[path[#path-1]]["height"] == nil) then
				generic_data[path[#path-1]]["height"] = math.max(math.floor(generic_data[path[#path-1]]["height"] * settings["upscale"]), 1)
			end
			if not(generic_data[path[#path-1]]["x"] == nil) then
				generic_data[path[#path-1]]["x"] = math.floor(generic_data[path[#path-1]]["y"] * settings["upscale"])
			end
			if not(generic_data[path[#path-1]]["y"] == nil) then
				generic_data[path[#path-1]]["y"] = math.floor(generic_data[path[#path-1]]["y"] * settings["upscale"])
			end
		end
	end

	-- overwrite old path with path to retextured version
	pathed_data[filename_key] = new_path

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
			local split_path = split(item, "/")
			-- ensure this file has not already been retextured
			if not(split_path[1] == "__" .. config.resource_pack_name .. "__") then
				local itemname = split(split_path[#split_path], "%p")
				local itemtype = itemname[#itemname]
				-- ensure the filetype matches .png, .jpg or .ogg
				if (itemtype == "png" or itemtype == "jpg" or itemtype == "ogg") then
					-- use the isReplaceItem to check if config.lua marks this data.raw path to be replaced by a retextured version
					local settings = isReplaceItem(item)
					if type(settings) == "table" then
						-- if so, a settings table is returned containing any other changes that need to be made to data.raw in regards to the file being retextured
						local changed_item_path = "__" .. config.resource_pack_name .. "__/data/" .. item:gsub("__", "")
						-- assign new file path and adjust data.raw according to settings using adjustDataDotRaw function
						adjustDataDotRaw(path, key, changed_item_path, settings)
						if pathed_data == nil then
							return
						end
					end
				end
			end	
		elseif (type(item) == "table") then
			-- if this folder in data.raw contains other folders, add these to the path and recursively call this function to explore the contents of these folders as well for .png, .jpg and .ogg file paths
			checkData(concat(path, {key}))
		end
	end
end

-- only trigger checkdata to look for paths that fit config.lua data = {} table if that table is not empty (__settings__ doesn't count as a directory entry) / has modnames that include a wildcard!
-- Important, as if it were & checkData ran, all files of all actively running mods would need to be retextured (all of data.raw), which is unsustainable, as it would make texturepacks break if it was run with mods that weren't retextured!
local dircount = 0
for key,content in pairs(config.data) do
	if not(key == "__settings__") then
		dircount = dircount + 1
	end
	if string.match(key, "*") then
		dircount = 0
		break
	end
end

if dircount > 0 then
	checkData({})
else
	log("[ERROR] : TEXTURE PACK NOT LOADED. You must explicitly state in the config.lua data table which mods you are retexturing! Your data table is either emtpy, or the mod names contain wild cards (*)! This is NOT allowed! See documentation @ for how to specify what you are retexturing in config.lua!")
end
