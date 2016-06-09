Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_SSCConfigMenu", function(menu_manager)
  MenuCallbackHandler.callback_malkovich_mode = function(self, item)
    SSC.options.malkovich_mode = (item:value() == "on" and true or false)
    SSC.saveOptions()
  end
  MenuCallbackHandler.callback_logging_mode = function(self, item)
    if item:value() == 1 then
      --none
      SSC.options.logging_mode = "none";
    elseif item:value() == 2 then
      --base game only
      SSC.options.logging_mode = "basegame";
    elseif item:value() == 3 then
      --BLT Mods only
      SSC.options.logging_mode = "blt";
    elseif item:value() == 4 then
      --All
      SSC.options.logging_mode = "all";
    end
    --this is only used for reloading the user's preference later
    SSC.options.logging_mode_numerical = item:value();
    SSC.saveOptions()
  end

  MenuCallbackHandler.callback_logging_stf = function(self, item)
    SSC.options.logging_stf = (item:value() == "on" and true or false)
    SSC.saveOptions()
  end

  MenuCallbackHandler.callback_stringid_mode = function(self, item)
    SSC.options.stringid_mode = (item:value() == "on" and true or false)
    SSC.saveOptions()
  end
  SSC.readOptions()
	MenuHelper:LoadFromJsonFile( SSC.modpath .. "menu.json", SSC, SSC.options)
end)
