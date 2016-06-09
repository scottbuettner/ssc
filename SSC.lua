--Stupid Strings Changer (SSC)
--Copyright Zeke Sonxx <github.com/zekesonxx>
--GPL3 licensed

if not _G.tablelength then
	function _G.tablelength(T)
	  local count = 0
	  for _ in pairs(T) do count = count + 1 end
	  return count
	end
end

if not _G.SSC then

	_G.SSC = {}

  SSC.options = {
		malkovich_mode = false
	}
  SSC._optionsfile = "mods/saves/ssc_options.json"
	SSC._replacementsfolder = "mods/saves/SSC"
	SSC._loggingfile = "mods/logs/SSC-strings.txt"
  SSC.modpath = ModPath
	SSC.replacements = {}
	SSC.loggedStrings = {}

	SSC.log = function(str)
		log("[SSC] "..str)
	end

	-- file thingies
	SSC.saveOptions = function()
		local file = io.open(SSC._optionsfile, "w+")
		if file then
			file:write(json.encode(SSC.options))
			file:close()
		end
	end
	SSC.readOptions = function()
		local file = io.open(SSC._optionsfile, "r")
		if file then
			SSC.options = json.decode(file:read("*all"))
			file:close()
		end
	end
	SSC.readReplacements = function()
		local files = file.GetFiles(SSC._replacementsfolder)
		for i, filename in ipairs(files) do
			local file = io.open(SSC._replacementsfolder .. "/" .. filename, "r")
			if file then
				local tomerge = json.decode(file:read("*all"))
				file:close()
				for k,v in pairs(tomerge) do SSC.replacements[k] = v end
				SSC.log("Successfully read replacements file " .. filename .. " (" .. tablelength(tomerge) .. " strings)")
			else
				SSC.log("Failed to read replacements file " .. filename)
			end
		end
		SSC.log("Finished reading replacement files, total of " .. tablelength(SSC.replacements) .." unique strings")
	end
	SSC.readOptions();
	SSC.readReplacements();
	SSC.wasMalkovichOnLaunch = SSC.options.malkovich_mode or false
end

SSC.hook_files = {
	["lib/managers/menumanager"] = "lib/menu.lua",
	["lib/managers/localizationmanager"] = "lib/injector.lua"
}

if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if SSC.hook_files[requiredScript] then
		dofile( SSC.modpath .. SSC.hook_files[requiredScript] )
	end
end

-- load our strings (I know, so weird right?)
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_SSC", function(loc)
	loc:load_localization_file( SSC.modpath .. "en.json" )
end)
