class "SmartTwtich"

require("DamageLib")

local evar = {}

function SmartTwtich:__init()
	if myHero.charName ~= "Twitch" then return end
	--self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function()	self:Tick()	end)
	Callback.Add("Draw", function()	self:Draw()	end)
	PrintChat("SmartTwtich Loaded")
	self:AddToTable()
end

local W = {Range = 950, Delay = 0.25, Radius = 50, Speed = 1410}
local E = {Range = 1200, Delay = 0, Radius = 0, Speed = 1337000}
local R = {Range = 700, Delay = 0, Radius = 0, Speed = 0}


function SmartTwtich:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "SmartTwtich", name = "SmartTwtich", leftIcon = "https://puu.sh/urBfI/1d6b44343f.jpg"})

	--Spells
	self.Menu:MenuElement({type = MENU, id = "Spells", name = "Auto Spells"})
	self.Menu.Spells:MenuElement({id = "SpellsW", name = "Use W   [?]", value = true, step = 1, tooltip = "W on ComboKey to Slow Enemy and Stack Faster"})
	self.Menu.Spells:MenuElement({id = "AutoE", name = "Auto Asisted E   [?]", value = true, step = 1, tooltip = "Auto E on Killeable"})

	--Harass
	self.Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Key"})
	self.Menu.Harass:MenuElement({id = "HarassW", name = "Use W   [?]", value = true, step = 1, tooltip = "Not recomended (Burn tons of Mana)"})
	self.Menu.Harass:MenuElement({id = "HarassE", name = "Use E   [?]", value = true, step = 1, tooltip = "Auto E on HarassKey Pressing if Enemy have more than X Stacks Configured by you."})
	self.Menu.Harass:MenuElement({id = "HarassStacks", name = "Min. Stacks to E", value = 3, min = 1, max = 6, step = 1, tooltip = "Auto E on HarassKey Pressing if Enemy have more than X Stacks Configured by you."})
	self.Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 85, min = 25, max = 100, step = 1})

	--Misc
	self.Menu:MenuElement({type = MENU, id = "Misc", name = "Miscellaneous"})
	self.Menu.Misc:MenuElement({id = "StealthRecall", name = "Stealth Recall   [?]", key = 84, tooltip = "Q + B"})
	self.Menu.Misc:MenuElement({id = "AutoQ", name = "Auto Q on Reset WIP   [?]", value = false, tooltip = "Work in progress (WIP)"})
	
--	self.Menu.Spells.AutoE self.Menu.Spells.AutoE
--	self.Menu.Spells.AutoE self.Menu.Spells.AutoE

	--OnDraw
	self.Menu:MenuElement({type = MENU, id = "OnDraw", name = "Drawings"})
	self.Menu.OnDraw:MenuElement({id = "OnDrawW", name = "Draw W", value = true})
	self.Menu.OnDraw:MenuElement({id = "OnDrawE", name = "Draw E", value = true})
	self.Menu.OnDraw:MenuElement({id = "OnDrawR", name = "Draw R", value = true})
	self.Menu.OnDraw:MenuElement({id = "DrawEDamage", name = "Draw E Damage", value = true})
	self.Menu.OnDraw:MenuElement({id = "DTarget", name = "Draw Target", value = true})
	
	--Debug
	self.Menu:MenuElement({type = MENU, id = "Debug", name = "Debug Mode"})
	self.Menu.Debug:MenuElement({id = "Debug", name = "Debug Mode", value = false,  min = false, max = false}) --Kappa
	--Credits
	self.Menu:MenuElement({type = MENU, id = "Credits", name = "Credits"})
	self.Menu.Credits:MenuElement({id = "Smart", name = "Smart",  min = false, max = false})
		self.Menu.Credits:MenuElement({id = "Noddy", name = "Noddy for helping",  min = false, max = false})
			self.Menu.Credits:MenuElement({id = "IC", name = "IC for OnDraw %",  min = false, max = false})
				self.Menu.Credits:MenuElement({id = "Alcoholic", name = "Alcoholic for Maths",  min = false, max = false})
	
end

function SDistance(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

local _IsVisible = {}
function OnVision(unit)
	if _IsVisible[unit.networkID] == nil then _IsVisible[unit.networkID] = {state = unit.visible , tick = GetTickCount(), pos = unit.pos} end
	if _IsVisible[unit.networkID].state == true and not unit.visible then _IsVisible[unit.networkID].state = false _IsVisible[unit.networkID].tick = GetTickCount() end
	if _IsVisible[unit.networkID].state == false and unit.visible then _IsVisible[unit.networkID].state = true _IsVisible[unit.networkID].tick = GetTickCount() end
	return _IsVisible[unit.networkID]
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

function Priority(charName)
  local p1 = {"Alistar", "Amumu", "Blitzcrank", "Braum", "Cho'Gath", "Dr. Mundo", "Garen", "Gnar", "Maokai", "Hecarim", "Jarvan IV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "TahmKench", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Poppy"}
  local p2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gragas", "Irelia", "Jax", "Lee Sin", "Morgana", "Janna", "Nocturne", "Pantheon", "Rengar", "Rumble", "Swain", "Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai", "Bard", "Nami", "Sona", "Camille"}
  local p3 = {"Akali", "Diana", "Ekko", "FiddleSticks", "Fiora", "Gangplank", "Fizz", "Heimerdinger", "Jayce", "Kassadin", "Kayle", "Kha'Zix", "Lissandra", "Mordekaiser", "Nidalee", "Riven", "Shaco", "Vladimir", "Yasuo", "Zilean", "Zyra", "Ryze"}
  local p4 = {"Ahri", "Anivia", "Annie", "Ashe", "Azir", "Brand", "Caitlyn", "Cassiopeia", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "Karma", "Karthus", "Katarina", "Kennen", "KogMaw", "Kindred", "Leblanc", "Lucian", "Lux", "Malzahar", "MasterYi", "MissFortune", "Orianna", "Quinn", "Sivir", "Syndra", "Talon", "Teemo", "Tristana", "TwistedFate", "Twitch", "Varus", "Vayne", "Veigar", "Velkoz", "Viktor", "Xerath", "Zed", "Ziggs", "Jhin", "Soraka"}
  if table.contains(p1, charName) then return 1 end
  if table.contains(p2, charName) then return 1.25 end
  if table.contains(p3, charName) then return 1.75 end
  return table.contains(p4, charName) and 2.25 or 1
end

function STarget(range,t,pos)-- Ty Nod
local t = t or "AD"
local pos = pos or myHero.pos
local target = {}
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.isEnemy and not hero.dead then
			OnVision(hero)
		end
		if hero.isEnemy and hero.valid and not hero.dead and (OnVision(hero).state == true or (OnVision(hero).state == false and GetTickCount() - OnVision(hero).tick < 650)) and hero.isTargetable then
			local heroPos = hero.pos
			if OnVision(hero).state == false then heroPos = hero.pos + Vector(hero.pos,hero.posTo):Normalized() * ((GetTickCount() - OnVision(hero).tick)/1000 * hero.ms) end
			if SDistance(pos,heroPos) <= range then
				if t == "AD" then
					target[(CalcPhysicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
				elseif t == "AP" then
					target[(CalcMagicalDamage(myHero,hero,100) / hero.health)*Priority(hero.charName)] = hero
				elseif t == "HYB" then
					target[((CalcMagicalDamage(myHero,hero,50) + CalcPhysicalDamage(myHero,hero,50))/ hero.health)*Priority(hero.charName)] = hero
				end
			end
		end
	end
	local bT = 0
	for d,v in pairs(target) do
		if d > bT then
			bT = d
		end
	end
	if bT ~= 0 then return target[bT] end
end

function IsImmobileTarget(unit) --Noddy CC Detector
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 or buff.name == "recall") and buff.count > 0 then
            return true
        end
    end
    return false    
end

function IsSlowTarget(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and buff.type == 10 and buff.count > 0 then
            return true
        end
    end
    return false    
end

function IsFearOrCharm(unit)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff and (buff.type == 21 or buff.type == 22) and buff.count > 0 then
            return true
        end
    end
    return false    
end

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

function SmartTwtich:AddToTable()
	for i=1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.isEnemy then
			evar[hero.networkID] = {}
			evar[hero.networkID].stacks = 0
			evar[hero.networkID].tick = 0
			--PrintChat("Initiated " .. hero.charName .. " with " .. evar[hero.networkID].stacks .. " stacks.")
		end
	end
end

function SmartTwtich:Tick()
	if myHero.dead then return end

	if self.Menu.Spells.AutoE:Value() and self:CanCast(_E) then
		self:KS()
	end

	if self.Menu.Misc.StealthRecall:Value() and self:CanCast(_Q) then
		self:CastQ()
		DelayAction(function()
			Control.CastSpell('B')
		end, 0.2)
	end

	for i=1,Game.HeroCount() do
		local hero = Game.Hero(i)
		local buff = self:GetBuff(hero, "TwitchDeadlyVenom")
		if hero and hero.isEnemy and self:HasBuff(hero, "TwitchDeadlyVenom") and buff then
			-- PrintChat("Buff Duration = " .. buff.duration)
			-- PrintChat("Buff Expire time = " .. buff.expireTime)
			-- PrintChat("Current Game Tick = " .. GetTickCount())
			-- PrintChat("Stored Value = " .. evar[hero.networkID].tick)
			-- PrintChat("Stored Stacks = " .. evar[hero.networkID].stacks)
			if buff.duration > 5.98 then
				if evar[hero.networkID].stacks ~= 6 then
					evar[hero.networkID].stacks = evar[hero.networkID].stacks + 1
					evar[hero.networkID].tick = GetTickCount()
				else
					evar[hero.networkID].stacks = 6
					evar[hero.networkID].tick = GetTickCount()
					--PrintChat(hero.charName .. " Has " .. evar[hero.networkID].stacks .. " Stacks")
				end
			end
		elseif hero and hero.isEnemy and not buff then
			evar[hero.networkID].stacks = 0
			evar[hero.networkID].tick = 0
		end
	end

    if self:Mode() == "Combo" then
        self:Combo()
    elseif self:Mode() == "Harass" then
        self:Harass()
    end

end

function SmartTwtich:Combo()

	local Quse = self.Menu.Misc.AutoQ:Value()
	local Wuse = self.Menu.Spells.SpellsW:Value()
	local Euse = self.Menu.Spells.AutoE:Value()
	local Ruse = self.Menu.Spells.SpellsR:Value()
	local AutoR = self.Menu.Spells.AutoR:Value()

	local target = STarget(W.Range)

	if target and self:IsValidTarget(target, W.Range) --[[and not isSlowTarget(target) ]]then-- SpellsLOGIC
		if Wuse and self:CanCast(_W) and evar[target.networkID].stacks < 6 then
			local castPos = target:GetPrediction(W.Speed, W.Delay)
			self:CastW(castPos)
		elseif Euse then
			self:KS()
		end
	end
end

function SmartTwtich:Harass()

	local Wuse = self.Menu.Harass.HarassW:Value()
	local Euse = self.Menu.Harass.HarassE:Value()
	local harassStacks = self.Menu.Harass.HarassStacks:Value()

	local target = STarget(W.Range)

	if target and self:IsValidTarget(target, W.Range) and (myHero.mana/myHero.maxMana >= self.Menu.Harass.HarassMana:Value() / 100) then
		if Wuse and self:CanCast(_W) and evar[target.networkID].stacks < 6 then
			local castPos = target:GetPrediction(W.Speed, W.Delay)
			self:CastW(castPos)
		elseif Euse and evar[target.networkID].stacks >= harassStacks then
			self:CastE()
		end
	end
end

function SmartTwtich:CastQ()
	Control.CastSpell(HK_Q)
end

function SmartTwtich:CastW(position)
	CastSpell(HK_W, position)
end

function SmartTwtich:CastE()
	Control.CastSpell(HK_E)
end

function SmartTwtich:CastR()
	Control.CastSpell(HK_R)
end

function SmartTwtich:Mode()
    if Orbwalker["Combo"].__active then
        return "Combo"
    elseif Orbwalker["Harass"].__active then
        return "Harass"
    elseif Orbwalker["Farm"].__active then
        return "Farm"
    elseif Orbwalker["LastHit"].__active then
        return "LastHit"
    end
    return ""
end

function SmartTwtich:KS()
	for i = 1, Game.HeroCount() do
  		local hero = Game.Hero(i);
	    if hero and hero.valid and hero.isEnemy and hero.visible then
	    	if hero.distance <= E.Range then
	          	local spellDmg = self:GetEDamage(hero)
	          	if spellDmg > hero.health then
	                self:CastE()
	            end
	        end
	    end
	end
end

function SmartTwtich:GetFarmTarget(range)
    local target
    for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if self:IsValidTarget(minion, range) and minion.team ~= myHero.team then
            target = minion
            break
        end
    end
    return target
end

function SmartTwtich:GetPercentHP(unit)
    return 100 * unit.health / unit.maxHealth
end

function SmartTwtich:GetPercentMP(unit)
    return 100 * unit.mana / unit.maxMana
end

function SmartTwtich:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function SmartTwtich:GetBuff(unit, buffname)
	local buff
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			buff = Buff
			return buff
		end
	end
	return buff
end


--local hp = arTarget.health + arTarget.shieldAD
--local dmg = CalcMagicalDamage(myHero,arTarget,20 + 15*myHero:GetSpellData(_E).level + stackDamage[spellLevel] (0.25*myHero.ad))


function SmartTwtich:GetEDamage(target)

	local spellLevel = myHero:GetSpellData(_E).level

	local eDamage = {20, 35, 50, 65, 80}
	local stackDamage = {15, 20, 25, 30, 35}
	local adDamage = myHero.totalDamage * 0.25
	local apDamage = myHero.ap * 0.20

	--local finalDamage = eDamage[spellLevel] + ((stackDamage[spellLevel] + adDamage + apDamage) * (stacks * 3))
	local finalDamage = (getdmg("E", target, myHero, 1) * evar[target.networkID].stacks) * 0.8

	if stacks == 0 then
		return 0
	else
		--PrintChat(evar[target.networkID].stacks .. " is equal to " .. finalDamage .. " damage")
		return finalDamage
	end
end

function SmartTwtich:BuffStacks(unit, buffname)
  	for i = 0, unit.buffCount do
    	local buff = unit:GetBuff(i)
    	if buff.name == buffname and buff.stacks > 0 then
			return buff.stacks
    	end
  	end
  	return 0
end

function SmartTwtich:KillableWithE(range)
	local canKill = false
	for i = 1, Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero.team ~= myHero.team and self:GetEDamage(hero) >= hero.health and hero.distance < range then
			canKill = true
			break
		end
	end
	return canKill
end

function SmartTwtich:GetBuffs(unit)
    self.buffs = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.buffs, Buff)
        end
    end
    return self.buffs
end

function SmartTwtich:IsReady(spellSlot)
    return myHero:GetSpellData(spellSlot).currentCd == 0 and myHero:GetSpellData(spellSlot).level > 0
end

function SmartTwtich:CheckMana(spellSlot)
    return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function SmartTwtich:CanCast(spellSlot)
    return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function SmartTwtich:IsValidTarget(obj, spellRange)
    return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
end

function SmartTwtich:Draw()
    if myHero.dead then return end

    if self.Menu.OnDraw.OnDrawW:Value() then
        Draw.Circle(myHero.pos,W.Range,1,Draw.Color(255, 255, 255, 255))
    end
    if self.Menu.OnDraw.OnDrawE:Value() then
        Draw.Circle(myHero.pos,E.Range,1,Draw.Color(255, 255, 255, 255))
    end
    if self.Menu.OnDraw.OnDrawR:Value() then
        Draw.Circle(myHero.pos,R.Range,1,Draw.Color(255, 255, 255, 255))
    end

    if self.Menu.OnDraw.DrawEDamage:Value() then
	    for i=1,Game.HeroCount() do
	    	local hero = Game.Hero(i)
	    	if hero and hero.isEnemy and self:IsValidTarget(hero, math.huge) then
	    		local textPos = hero.pos:To2D()
	    		Draw.Text("Total Damage |  = ~" .. 100 * math.min(1, self:GetEDamage(hero) / hero.health), 15, textPos.x - 60, textPos.y + 80, Draw.Color(255, 255, 0, 0))
				--Draw.Text("Stacks = " .. evar[hero.networkID].stacks .. " | Total Damage = ~" .. self:GetEDamage(hero), 15, textPos.x - 60, textPos.y + 80, Draw.Color(255, 255, 255, 255))
				--PrintChat(hero.maxHealth)
	    	end
	    end
	end

    if self.Menu.OnDraw.DTarget:Value() then
        local DTarget = STarget(R.Range)
        if DTarget then
            Draw.Circle(DTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
        end
    end
end

function OnLoad()
    SmartTwtich()
	PrintChat("Smart Twitch ON")
end