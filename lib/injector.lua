CloneClass(LocalizationManager)

function LocalizationManager:_ssc_find_real_string(string_id)
  local return_string = "Locale Error: "..string_id
  local source = "notfound"

  --multi-platform cruft from the original function
  if( not string_id or string_id == "" ) then
    return_string = ""
  elseif( self:exists( string_id .. "_" .. self._platform ) ) then
    string_id = string_id .. "_" .. self._platform
  elseif( self:exists( string_id ) ) then
    string_id = string_id
  end

  if (self:exists(string_id)) then
    --String is from base game
    --If we call Localizer:lookup without any macros set
    --Then it'll return the original string
    --(only really used for logging, to have the game actually render the string we re-look it up)
    source = "basegame"
    return_string = Localizer:lookup(Idstring(string_id))
  end

	if self._custom_localizations[string_id] then
    --String is from BLT
    source = "blt"
		return_string = self._custom_localizations[string_id]
  end

  return {
    source = source,
    string = return_string
  }
end

function LocalizationManager:_ssc_logifneeded(source, string_id, str)
  local alreadylogged = SSC.loggedStrings[string_id] and true or false
  if SSC.options.logging_mode == "none" or alreadylogged == true or
     (SSC.options.logging_mode == "blt" and source ~= "blt") or
     (SSC.options.logging_mode == "basegame" and source ~= "basegame") then
    return
  end
  str = string.gsub(str, "\n", "\\n")
  SSC.loggedStrings[string_id] = str
  if SSC.options.logging_stf and not alreadylogged then
    local file = io.open(SSC._loggingfile, "a+")
    if file then
      file:write(string.format("[%s] %s: %s\n", source, string_id, str))
      file:close()
    end
  end
end

function LocalizationManager:text(string_id, macros)
  if string_id == nil then return end --if you fail so do we

  --[[
    String ID mode
  ]]
  if SSC.options.stringid_mode then
    if string.sub(string_id, 0, 4) == "ssc_" then
      --preserve our own strings
    elseif string_id == "menu_visit_forum3" then
      --The "press any key" text on the splash screen when you launch the game
      --We call ourselves so that this string can be translated in the future.
      return self.text(self, "ssc_stringid_mode_splashscreentext")
    else
      return string_id
    end
  end
  --[[
    Split into a separate function for the sake of readability
  ]]
  local processoroutput = self._ssc_find_real_string(self, string_id)
  local str = processoroutput.string;
  local source = processoroutput.source;

  LocalizationManager:_ssc_logifneeded(source, string_id, str)

  --[[
    If we'd like to replace it
    This is separate from find_real_string so that we can better
    keep track of the source of the string
  ]]
  if SSC.replacements[string_id] then
		str = SSC.replacements[string_id]
    if source == "basegame" then
      source = "basegame-replaced"
    end
	end

  --[[
    Macroization
  ]]
  if source == "basegame" then
    str = self.orig.text(self, string_id, macros)
  elseif source == "basegame-replaced" then
    self._macro_context = macros
    str = self:_localizer_post_process(str)
    self._macro_context = nil
  elseif source == "blt" and macros then
    if macros and type(macros) == "table" then
      for k, v in pairs( macros ) do
        str = str:gsub( "$" .. k, v )
      end
    end
  end

  --[[
    If after all that, we still didn't find the string
    Return with no string.
  ]]
  if str == nil then return end

  --[[
    Malkovich Mode
  ]]
  if SSC.wasMalkovichOnLaunch == true then
    if string.sub(string_id, 0, 4) == "ssc_" then
      --preserve our own strings
    elseif string_id == "menu_visit_forum3" then
      --The "press any key" text on the splash screen when you launch the game
      --We call ourselves so that this string can be translated in the future.
      str = self.text(self, "ssc_malkovich_mode_splashscreentext")
    else
      --[[
        The "original" Malkovich mode just replaced every string with a single Malkovich
        But that didn't really look very good.
        It gave it more of an air of lazyness than amusement.
        This way it replaces every word in each string with "Malkovich"
        Numbers and punctuation are preserved
      ]]
      str = string.gsub(str, "[(%l|%u)]+", "Malkovich")
    end
  end
  return str;
end
