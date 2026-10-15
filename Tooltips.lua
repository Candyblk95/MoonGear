local _, MG = ...
local slots = {
 INVTYPE_HEAD={1},INVTYPE_NECK={2},INVTYPE_SHOULDER={3},INVTYPE_CHEST={5},INVTYPE_ROBE={5},
 INVTYPE_WAIST={6},INVTYPE_LEGS={7},INVTYPE_FEET={8},INVTYPE_WRIST={9},INVTYPE_HAND={10},
 INVTYPE_FINGER={11,12},INVTYPE_TRINKET={13,14},INVTYPE_CLOAK={15},
 INVTYPE_WEAPONMAINHAND={16},INVTYPE_WEAPONOFFHAND={17},INVTYPE_SHIELD={17},INVTYPE_HOLDABLE={17},
 INVTYPE_RANGED={18},INVTYPE_RANGEDRIGHT={18},INVTYPE_THROWN={18},INVTYPE_RELIC={18},
 INVTYPE_2HWEAPON={16,17},INVTYPE_WEAPON={16,17},
}
local function evaluate(link)
 if not MG.db then return end
 local itemID = link and tonumber(link:match("item:(%d+)"))
 if not itemID then return end
 if type(GetItemInfo) ~= "function" then return end
 local _,_,_,_,_,_,_,_,equipLoc = GetItemInfo(link)
 local choices = slots[equipLoc]
 if not choices then return end
 local weights,spec = MG:GetWeights()
 local score = MG:Score(link,weights)
 if not score then return "Stats unavailable or not scored" end
 local bestDelta
 if equipLoc=="INVTYPE_2HWEAPON" then
   local a=MG:Score(GetInventoryItemLink("player",16),weights) or 0
   local b=MG:Score(GetInventoryItemLink("player",17),weights) or 0
   bestDelta=score-a-b
 else
   for _,slot in ipairs(choices) do
     local current=GetInventoryItemLink("player",slot)
     local equipped=current and MG:Score(current,weights) or 0
     if equipped then
       local delta=score-equipped
       if not bestDelta or delta>bestDelta then bestDelta=delta end
     end
   end
 end
 if not bestDelta then return end
 local pct = score ~= 0 and bestDelta / math.max(1, math.abs(score-bestDelta))*100 or 0
 if bestDelta>0 and pct >= MG.db.threshold then
   return string.format("|cff55dd88Upgrade|r %+0.1f%% weighted score (%s)",pct,spec)
 elseif bestDelta<0 then
   return string.format("|cffff7777Downgrade|r %0.1f%% weighted score (%s)",pct,spec)
 end
 return "Sidegrade / below threshold ("..spec..")"
end
local function add(tip,link)
 if not tip or not link then return end
 local text=evaluate(link)
 if text then tip:AddLine("|cffbb99ffMoonGear:|r "..text,1,1,1,true);tip:Show() end
end
-- Modern tooltip post-call hook; used for bags, quests, vendors and AH where supported.
if TooltipDataProcessor and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
 TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,function(tip,data)
   if not data or not data.id then return end
   local link = data.hyperlink or ("item:"..data.id)
   add(tip,link)
 end)
elseif GameTooltip and GameTooltip.HookScript then
 GameTooltip:HookScript("OnTooltipSetItem",function(tip)
   local _,link=tip:GetItem()
   add(tip,link)
 end)
end
