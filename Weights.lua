local _, MG = ...
-- Conservative starter presets, NOT validated Forever DPS simulations.
MG.presets = {
 DRUID = {
  BALANCE = {ITEM_MOD_INTELLECT_SHORT=1.2,ITEM_MOD_SPIRIT_SHORT=0.35,ITEM_MOD_SPELL_POWER_SHORT=2.0,ITEM_MOD_STAMINA_SHORT=0.2},
  RESTORATION = {ITEM_MOD_INTELLECT_SHORT=1.0,ITEM_MOD_SPIRIT_SHORT=0.9,ITEM_MOD_SPELL_HEALING_DONE_SHORT=2.0,ITEM_MOD_STAMINA_SHORT=0.2},
  FERAL = {ITEM_MOD_AGILITY_SHORT=1.5,ITEM_MOD_STRENGTH_SHORT=1.1,ITEM_MOD_STAMINA_SHORT=0.5,ITEM_MOD_ATTACK_POWER_SHORT=0.5},
 },
 MAGE = {DEFAULT={ITEM_MOD_INTELLECT_SHORT=1.2,ITEM_MOD_SPIRIT_SHORT=0.3,ITEM_MOD_SPELL_POWER_SHORT=2}},
 WARLOCK = {DEFAULT={ITEM_MOD_INTELLECT_SHORT=1.1,ITEM_MOD_STAMINA_SHORT=0.7,ITEM_MOD_SPELL_POWER_SHORT=2}},
 WARRIOR = {DEFAULT={ITEM_MOD_STRENGTH_SHORT=1.2,ITEM_MOD_STAMINA_SHORT=0.7,ITEM_MOD_AGILITY_SHORT=0.6,ITEM_MOD_ATTACK_POWER_SHORT=0.5}},
 ROGUE = {DEFAULT={ITEM_MOD_AGILITY_SHORT=1.3,ITEM_MOD_STRENGTH_SHORT=0.7,ITEM_MOD_ATTACK_POWER_SHORT=0.6}},
 HUNTER = {DEFAULT={ITEM_MOD_AGILITY_SHORT=1.3,ITEM_MOD_INTELLECT_SHORT=0.3,ITEM_MOD_ATTACK_POWER_SHORT=0.6}},
 PRIEST = {DEFAULT={ITEM_MOD_INTELLECT_SHORT=1.2,ITEM_MOD_SPIRIT_SHORT=0.7,ITEM_MOD_SPELL_POWER_SHORT=1.6}},
 PALADIN = {DEFAULT={ITEM_MOD_STRENGTH_SHORT=1,ITEM_MOD_INTELLECT_SHORT=0.5,ITEM_MOD_STAMINA_SHORT=0.6}},
 SHAMAN = {DEFAULT={ITEM_MOD_INTELLECT_SHORT=1,ITEM_MOD_STRENGTH_SHORT=0.6,ITEM_MOD_STAMINA_SHORT=0.5}},
}
function MG:GetWeights()
 local _,class = UnitClass("player")
 local presets = self.presets[class] or {}
 local spec = self.db.spec
 if self.db.mode == "auto" or (self.db.mode == "hybrid" and spec == "AUTO") then
   -- Talent inference requires client validation; never pretend to know.
   spec = "DEFAULT"
 end
 local base = presets[spec] or presets.DEFAULT
 if not base then for _,v in pairs(presets) do base=v break end end
 local result = {}
 for k,v in pairs(base or {}) do result[k]=v end
 if self.db.mode == "hybrid" then for k,v in pairs(self.db.custom) do result[k]=v end end
 return result, spec
end
function MG:Score(link, weights)
 if not link or type(GetItemStats) ~= "function" then return nil end
 local ok,stats = pcall(GetItemStats,link)
 if not ok or type(stats) ~= "table" then return nil end
 local total,matched=0,0
 for stat,value in pairs(stats) do
   if weights[stat] and type(value)=="number" then total=total+value*weights[stat]; matched=matched+1 end
 end
 if matched==0 then return nil end
 return total
end
