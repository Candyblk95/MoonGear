local addonName, MG = ...
_G.MoonGear = MG
MG.defaults = { mode = "auto", spec = "AUTO", threshold = 0, custom = {} }
local function copy(t)
  local o = {}
  for k,v in pairs(t) do o[k] = type(v) == "table" and copy(v) or v end
  return o
end
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  if type(MoonGearDB) ~= "table" then MoonGearDB = copy(MG.defaults) end
  for k,v in pairs(MG.defaults) do if MoonGearDB[k] == nil then MoonGearDB[k] = type(v) == "table" and copy(v) or v end end
  MG.db = MoonGearDB
  print("|cffbb99ffMoonGear|r loaded. Type /mg help")
end)
SLASH_MOONGEAR1 = "/mg"
SLASH_MOONGEAR2 = "/moongear"
SlashCmdList.MOONGEAR = function(msg)
  if not MG.db then return end
  local cmd,arg = (msg or ""):match("^(%S*)%s*(.-)%s*$")
  cmd = string.lower(cmd or "")
  if cmd == "mode" and (arg == "auto" or arg == "manual" or arg == "hybrid") then
    MG.db.mode = arg
    print("MoonGear mode: "..arg)
  elseif cmd == "spec" and arg ~= "" then
    MG.db.spec = string.upper(arg)
    print("MoonGear spec: "..MG.db.spec)
  elseif cmd == "threshold" and tonumber(arg) then
    MG.db.threshold = math.max(0, tonumber(arg))
    print("MoonGear threshold: "..MG.db.threshold.."%")
  elseif cmd == "weight" then
    local stat,num = arg:match("^(%S+)%s+([%d%.]+)$")
    if stat and num then
      MG.db.custom[string.upper(stat)] = tonumber(num)
      print("MoonGear custom weight: "..stat.." = "..num)
    end
  else
    print("|cffbb99ffMoonGear|r /mg mode auto|manual|hybrid")
    print("/mg spec BALANCE|RESTORATION|FERAL|... ; /mg weight ITEM_MOD_INTELLECT_SHORT 2")
    print("/mg threshold 5 (percentage of weighted score)")
  end
end
