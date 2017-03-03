-- Copyright Smart under GNU licence.
-- Smart LoL GOS User
-- AKA : Call me Smart / SmartSharp
-- Contact skype: smart0095
require "DamageLib"
--require "LeagueSharp.Common.SmartPort"

-- Spells
local Q = {Delay = 0.250, Radius = 75, Range = 1160, Speed = 1900}
local E = {Delay = 0.250, Radius = 200, Range = 1250, Speed = 900,}
local R = {Delay = 1, Radius = 120, Range = 3300, Speed = math.huge}

-- Menu local
local Menu = MenuElement({type = MENU, id = "SmartTearStacker", name = "Smart Tear Stacker", leftIcon="http://puu.sh/urxln/2d814c7f82.jpg"})


-- Keys Menu
Menu:MenuElement({type = MENU, id = "Enable", name = "Enable/Disable"})
Menu.Enable:MenuElement({id = "Enable", name = "Enable / Disable Button", value = true})

-- Keys Menu
Menu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
Menu.Key:MenuElement({id = "ComboKey", name = "Disable on Combo Key", key = 32})
Menu.Key:MenuElement({id = "HarassKey", name = "Disable on Harass Key", key = 67})
Menu.Key:MenuElement({id = "WaveClearKey", name = "Disable on Wave Clear Key", key = 86})
Menu.Key:MenuElement({id = "LastHitKey", name = "Disable on Last Hit Key", key = 88})
--Menu.Key:MenuElement({id = "TKey", name = "Trap on Fow HK", key = 84})
--Menu.Key:MenuElement({id = "YKey", name = "Disable on T", key = 72})


-- Keys Menu
Menu:MenuElement({type = MENU, id = "Spells", name = "Spells to Use"})
Menu.Spells:MenuElement({id = "Qusage", name = "Use Q to Stack", value = true})
Menu.Spells:MenuElement({id = "Wusage", name = "Use W to Stack", value = true})
Menu.Spells:MenuElement({id = "Eusage", name = "Use E to Stack", value = true})


-- Mana Manager Menu
Menu:MenuElement({type = MENU, id = "ManaManager", name = "Mana Manager"})
Menu.ManaManager:MenuElement({id = "Mana", name = "Min. Mana", value = 90, min = 0, max = 100})

-- Drawings Menu
Menu:MenuElement({type = MENU, id = "DrawOn", name = "Drawing Settings"})
Menu.DrawOn:MenuElement({id = "DrawOn", name = "Draw Status", value = true})



-- CastSpell Mouse Sync TEST Function (Noddy)
local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastSpell(spell,pos,range,delay)
local range = range or math.huge
local delay = delay or 250
local ticker = GetTickCount()

	if castSpell.state == 0 and pos:DistanceTo(myHero.pos) < range and ticker - castSpell.casting > delay + Game.Latency() and pos:ToScreen().onScreen then
		castSpell.state = 1
		castSpell.mouse = mousePos
		castSpell.tick = ticker
	end
	if castSpell.state == 1 then
		if ticker - castSpell.tick < Game.Latency() then
			Control.SetCursorPos(pos)
			Control.KeyDown(spell)
			Control.KeyUp(spell)
			castSpell.casting = ticker + delay
			DelayAction(function()
				if castSpell.state == 1 then
					Control.SetCursorPos(castSpell.mouse)
					castSpell.state = 0
				end
			end,Game.Latency()/1000)
		end
		if ticker - castSpell.casting > Game.Latency() then
			Control.SetCursorPos(castSpell.mouse)
			castSpell.state = 0
		end
	end
end

function GetBuffs(unit)
	T = {}
	for i = 0, unit.buffCount do
		local Buff = unit:GetBuff(i)
		if Buff.count > 0 then
			table.insert(T, Buff)
		end
	end
	return T
end

function ImRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function GetItemSlot(unit, id)
  for i = ITEM_1, ITEM_7 do
    if unit:GetItemData(i).itemID == id then
      return i
    end
  end
  return 0 -- 
end

-- Events
-- OnUpdate (30')
Callback.Add('Tick',function()

	if not Menu.Key.ComboKey:Value() and not Menu.Key.HarassKey:Value() and not Menu.Key.WaveClearKey:Value() and not Menu.Key.LastHitKey:Value() then--IF NOT IN COMBO and others KEYS THEN STACKER WORKS
	if Menu.Enable.Enable:Value() and (myHero.mana/myHero.maxMana >= Menu.ManaManager.Mana:Value()/100) and not ImRecalling() then
			local tear = GetItemSlot(myHero,3070)
		if tear > 0 and myHero:GetSpellData(tear).currentCd == 0 then
        if isReady(_W) then
			Control.CastSpell(HK_W--[[,mousePos,5000]])
        elseif isReady(_E) then
			Control.CastSpell(HK_E--[[,mousePos,5000]])
        elseif isReady(_Q) then
			Control.CastSpell(HK_Q--[[,mousePos,5000]])
        end 
    end
	end
  end
	
end)--END OnUptade TICK




-- OnLoad
Callback.Add('Load',function()
	PrintChat("Smart Tear Stacker - Loaded")
end)

-- OnDraw TEST WIP
function OnDraw()
	if myHero.dead then return end

	if Menu.DrawOn.DrawOn:Value()	then
	if Menu.Enable.Enable:Value() then
		--Draw.text("Stacker On", myHero.pos)
		--Draw.Text(hero.charName,12,posTo2D.x,posTo2D.y,Draw.Color(0x70FF0000));
		end
    end
end


-- isReady - Returns bool
function isReady(slot)
	return (myHero:GetSpellData(slot).currentCd == 0) and (myHero:GetSpellData(spellSlot).mana < myHero.mana) and (myHero:GetSpellData(slot).level >= 1) -- Thanks MeoBeo
end

-- isValidTarget - Returns bool
function isValidTarget(obj, spellRange)
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

-- CREDITS : Smart
-- Thanks to Noddy for helping
-- Contact Skype: smart0095