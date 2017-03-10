--HeroCheck
if myHero.charName ~= "Twitch" then return end

--ClassCreated
class "SmartTwitch"

--Deftsu
require "DamageLib" 

--Twitch Spells Data
local Q = {Range = 1150,Delay = 0.25, Radius = 50, Speed = 1200}
local W = {Range = 950, Delay = 0.25, Radius = 50, Speed = 1410}
local E = {Range = 1200, Delay = 0.25, Speed = 7777777}
local R = {Range = 875}
local SmartPoison = {}

--Drawing Resolution
local RES = Game.Resolution()

--INIT Central function
function SmartTwitch:__init()
	Callback.Add("Tick", function()	self:Tick()	end)
	PrintChat("Smart Twitch Remake - Initiated")
	self:AddToTable()
	self:E_Logic()
end


-- Menu
local SmartTwitchMenu = MenuElement({type = MENU, id = "SmartTwitchMenu", name = "Twitch", leftIcon = "http://ddragon.leagueoflegends.com/cdn/7.1.1/img/champion/Twitch.png"})
SmartTwitchMenu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})--Done
SmartTwitchMenu.Key:MenuElement({id = "ComboKey", name = "Combo Key",key = 32 })--Done
SmartTwitchMenu.Key:MenuElement({id = "HarassKey", name = "Harass Key",key = string.byte("C") })--Done
SmartTwitchMenu.Key:MenuElement({id = "ClearKey", name = "Clear Key WIP",key = string.byte("V") })--WIP
SmartTwitchMenu:MenuElement({type = MENU, id = "Combo", name = "Combo Spells"})
SmartTwitchMenu.Combo:MenuElement({id = "UseW", name = "Use W in Combo", value = true})--Done
SmartTwitchMenu.Combo:MenuElement({id = "UseE", name = "Use E in Combo", value = true})--Done
SmartTwitchMenu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
SmartTwitchMenu.Harass:MenuElement({id = "UseW", name = "Use W in Harass", value = true})--Done
SmartTwitchMenu.Harass:MenuElement({id = "UseE", name = "Use E Harass on X Stacks", value = true})--Done
SmartTwitchMenu.Harass:MenuElement({id = "HarassEStackAmmount", name = "Harass E Stacks Ammount", value = 5,min = 0, max = 6, step = 1})--Done
SmartTwitchMenu.Harass:MenuElement({id = "ManaW", name = "Mana for W harass usage(%)", value = 75,min = 0, max = 100, step = 1})--Done
SmartTwitchMenu.Harass:MenuElement({id = "ManaE", name = "Mana for E harass usage(%)", value = 50,min = 0, max = 100, step = 1})--Done
SmartTwitchMenu:MenuElement({type = MENU, id = "Clear", name = "E Clear Settings - WIP [?]"})--WIP
--SmartTwitchMenu.Clear:MenuElement({id = "EMob", name = "Use E On Jungle Mobs", key = string.byte("T"),toggle = true})
--SmartTwitchMenu.Clear:MenuElement({id = "ESiege", name = "Use E On Siege", value = false})
--SmartTwitchMenu.Clear:MenuElement({id = "EKillMinion", name = "Use E kills X minions", value = 5,min = 1, max = 10, step = 1})
SmartTwitchMenu:MenuElement({type = MENU, id = "Misc", name = "Poison Features"})
SmartTwitchMenu.Misc:MenuElement({id = "AutoE", name = "Auto E (KS)", value = true})--Done
--SmartTwitchMenu.Misc:MenuElement({id = "AutoEStack", name = "Auto E on X Stacks", value = false})--Disabled Since AutoE Max Range
--SmartTwitchMenu.Misc:MenuElement({id = "AutoEStackAmmount", name = "Auto E Stacks Ammount", value = 5,min = 0, max = 6, step = 1})--Disabled Since AutoE Max Range
SmartTwitchMenu.Misc:MenuElement({id = "AutoERange", name = "Auto E OUT OF RANGE", value = true})
SmartTwitchMenu.Misc:MenuElement({id = "AutoERangeStacks", name = "OUT OF RANGE - Min Stack", value = 6,min = 0, max = 6, step = 1})
SmartTwitchMenu.Misc:MenuElement({id = "EBeforeDeath", name = "E Before Death", value = true})--Done
SmartTwitchMenu.Misc:MenuElement({id = "HPToEBeforeDeath", name = "Heal % To E before Death", value = 10,min = 0, max = 100, step = 1})--Done
SmartTwitchMenu:MenuElement({type = MENU, id = "Drawing", name = "Draw Settings"})--Done
SmartTwitchMenu.Drawing:MenuElement({id = "DrawW", name = "Draw W Range", value = true})
SmartTwitchMenu.Drawing:MenuElement({id = "DrawE", name = "Draw Poison Range", value = false})
SmartTwitchMenu.Drawing:MenuElement({id = "DrawR", name = "Draw R Range", value = false})
SmartTwitchMenu.Drawing:MenuElement({id = "DrawEDmg", name = "Draw E Dmg", value = true})
SmartTwitchMenu.Drawing:MenuElement({id = "DrawTarget", name = "Draw Target Circle", value = true})

--Custom TargetSelector STARTS
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

function STarget(range,t,pos)
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
--Custom TargetSelector FINISH

--Custom CastSpell STARTS
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
--Custom CastSpell FINISH

--Extra Functions STARTS
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
local function GetDistance(p1,p2)
    return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end

function GettingTarget(range)
	local tts = nil
	local G = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if isValidTarget(hero,range) and hero.team ~= myHero.team then
			local dmgtohero = getdmg("AA",hero,myHero)
			local qqk = hero.health/dmgtohero
			if qqk > G or tts == nil then
				tts = hero
			end
		end
	end
	return tts
end

function CountEnemy(pos,range)--MeoBeo
	local G = 0
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)	
		if isValidTarget(hero,range) and hero.isEnemy then
			G = G + 1
		end
	end
	return G	
end

function isReady(slot)
	return Game.CanUseSpell(slot) == 0
end

function isValidTarget(obj,range)
	range = range and range or math.huge
	return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= range
end
--Extra Functions FINISH

--SmartTwitch Functions STARTS
function SmartTwitch:GetTarget(range)
    local target
    for i = 1,Game.HeroCount() do
        local hero = Game.Hero(i)
        if self:IsValidTarget(hero, range) and hero.team ~= myHero.team then
            target = hero
            break
        end
    end
    return target
end

function SmartTwitch:HasBuff(unit, buffname)
    for K, Buff in pairs(self:GetBuffs(unit)) do
        if Buff.name:lower() == buffname:lower() then
            return true
        end
    end
    return false
end

function SmartTwitch:GetBuff(unit, buffname)
	local buff
	for K, Buff in pairs(self:GetBuffs(unit)) do
		if Buff.name:lower() == buffname:lower() then
			buff = Buff
			return buff
		end
	end
	return buff
end

function SmartTwitch:GetBuffs(unit)
    self.buffs = {}
    for i = 0, unit.buffCount do
        local Buff = unit:GetBuff(i)
        if Buff.count > 0 then
            table.insert(self.buffs, Buff)
        end
    end
    return self.buffs
end
--SmartTwitch Functions FINISH

--PoisonData STARTS
function SmartTwitch:AddToTable() --Tables Statments
	for i=1,Game.HeroCount() do
		local hero = Game.Hero(i)
		if hero and hero.isEnemy then
			SmartPoison[hero.networkID] = {}
			SmartPoison[hero.networkID].stacks = 0
			SmartPoison[hero.networkID].tick = 0
			--PrintChat("Initiated " .. hero.charName .. " with " .. SmartPoison[hero.networkID].stacks .. " stacks.")
		end
	end
end

function SmartTwitch:GetEDamage(target) --E Damage Calculations

local spellLevel = myHero:GetSpellData(_E).level
local eDamage = {20, 35, 50, 65, 80}
local stackDamage = {15, 20, 25, 30, 35}
local adDamage = myHero.totalDamage * 0.25
local finalDamage = eDamage[spellLevel] + ((stackDamage[spellLevel] + adDamage) * (SmartPoison[target.networkID].stacks * 0.45))

if stacks == 0 then
		return 0
	else
		return finalDamage
	end
end
--PoisonData FINISH

--CONTAMINATE ALGORITHM STARTS
function SmartTwitch:E_Logic()

-- Stack Manual Counter
function EStacks(unit)
  for i=1,Game.HeroCount() do
      local hero = Game.Hero(i)
      local buff = self:GetBuff(hero, "TwitchDeadlyVenom")
            if hero and hero.isEnemy and self:HasBuff(hero, "TwitchDeadlyVenom") and buff then
              --Print("Stored Stacks = " .. SmartPoison[hero.networkID].stacks)
                  if buff.duration > 5.98 then --HackFix until Api Supports TwitchStacks
                              if SmartPoison[hero.networkID].stacks ~= 6 then
                                SmartPoison[hero.networkID].stacks = SmartPoison[hero.networkID].stacks + 1
                                SmartPoison[hero.networkID].tick = GetTickCount()
                              else
                                SmartPoison[hero.networkID].stacks = 6
                                SmartPoison[hero.networkID].tick = GetTickCount()
                              end
                  end
            elseif hero and hero.isEnemy and not buff then
              SmartPoison[hero.networkID].stacks = 0
              SmartPoison[hero.networkID].tick = 0
            end
    end
end

-- Twitch E (Contaminate (Poison)) Algorithm
    for i = 1, Game.HeroCount() do
      local hero = Game.Hero(i)
      if hero.isEnemy and isValidTarget(hero,E.Range) then
        --local stack = EStacks(hero)
			local TargetERange = GettingTarget(E.Range)
			local ETargetPos = TargetERange:GetPrediction(E.Range, E.speed, E.delay)
			local stack = EStacks(hero)
			--local target = STarget(E.Range)
									--[[How Algorithm Works:
									E LOGIC CALC ..
									If Auto E or ComboE then
											If E can Kill then
											CAST E
											END
										else if HarassE and E Checks (Stacks, Mana) then
												CAST E
										end
											else if AutoERangeCheck and AutoERange Checks (Stacks, Distance) then
													CAST E
											end
												else if E before Death + Checks then
														CAST E
												end
									end
									--]]
			if SmartTwitchMenu.Misc.AutoE:Value() or SmartTwitchMenu.Key.ComboKey:Value() and SmartTwitchMenu.Combo.UseE:Value() then
									  if SmartTwitch:GetEDamage(hero) > hero.health + hero.shieldAD then
									  --print("KillSecure E")
										Control.CastSpell(HK_E)
										return
									  end
                    elseif SmartTwitchMenu.Key.HarassKey:Value() and SmartTwitchMenu.Harass.UseE:Value() and myHero.mana/myHero.maxMana > SmartTwitchMenu.Harass.ManaE:Value()/100 and SmartPoison[target.networkID].stacks >= SmartTwitchMenu.Harass.HarassEStackAmmount:Value() then 
                    Control.CastSpell(HK_E)
        						--Print("Harass E on X Stacks")
								--end --Old end of elseif
      				
							elseif SmartTwitchMenu.Misc.AutoERange:Value() and SmartTwitchMenu.Misc.AutoERangeStacks:Value() and SmartPoison[TargetERange.networkID].stacks >= SmartTwitchMenu.Misc.AutoERangeStacks:Value() and TargetERange ~= nil and TargetERange and ETargetPos and GetDistance(myHero.pos, TargetERange.pos) > 1050 then
							Control.CastSpell(HK_E)
										--Print("Auto E On MAX RANGE")
							
								elseif SmartTwitchMenu.Misc.EBeforeDeath:Value() and myHero.health/myHero.maxHealth < SmartTwitchMenu.Misc.HPToEBeforeDeath:Value()/100 and CountEnemy(myHero.pos,550) > 0 then
								--If enemyes arround and close to death E before death
								Control.CastSpell(HK_E)
											--Print("Auto E On MAX RANGE")
								end
			end					--New End of E loop --end --Old End of E loop Test
end
end --CONTAMINATE ALGORITHM FINISH

--OnUpdate STARTS
function SmartTwitch:Tick()

--W Usage (Combo+WOnCombo / Harass+WOnHarass + ManaCheck)
  if (SmartTwitchMenu.Key.ComboKey:Value() and SmartTwitchMenu.Combo.UseW:Value()) or (SmartTwitchMenu.Harass.UseW:Value() and SmartTwitchMenu.Key.HarassKey:Value() and myHero.mana/myHero.maxMana > SmartTwitchMenu.Harass.ManaW:Value()/100)	then
        if isReady(_W) then
          local wTarget = STarget(E.Range)
                  if wTarget and myHero.attackData.state == 2 then
                    local pos = wTarget:GetPrediction(W.Speed, W.Radius, W.Delay)
                    CastSpell(HK_W,pos)
                  end
        end
  end
  
self:E_Logic()
	
end
--OnUpdate FINISH

--Drawing STARTS
Callback.Add("Draw", function()
	if myHero.dead then return end
	
if SmartTwitchMenu.Drawing.DrawTarget:Value() then
	    local drawTarget = STarget(E.Range)
	    if drawTarget then
		    Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
	    end
end
	
	
	if SmartTwitchMenu.Drawing.DrawW:Value() and myHero:GetSpellData(1).level > 0 then
		local qcolor = isReady(_W) and  Draw.Color(240,30,144,255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),W.Range,1,qcolor)
	end
	if SmartTwitchMenu.Drawing.DrawR:Value() and myHero:GetSpellData(3).level > 0  then
		local rcolor = isReady(_R) and  Draw.Color(189, 183, 107, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),R.Range,1,rcolor)
	end
	if SmartTwitchMenu.Drawing.DrawE:Value() and myHero:GetSpellData(2).level > 0 then
		local ecolor = isReady(_E) and  Draw.Color(233, 150, 122, 255) or Draw.Color(240,255,0,0)
		Draw.Circle(Vector(myHero.pos),E.Range,1,ecolor)
	end
	
	
	
	 if SmartTwitchMenu.Drawing.DrawEDmg:Value() then
	    for i=1,Game.HeroCount() do
	    	local hero = Game.Hero(i)
	    	if hero and hero.isEnemy then
	    		local textPos = hero.pos:To2D()
	    		--Draw.Text("E Stacks = " .. SmartPoison[hero.networkID].stacks .. " | E Damage = ~" .. SmartTwitch:GetEDamage(hero), 15, textPos.x - 60, textPos.y + 80, Draw.Color(255, 255, 255, 255))
	    	Draw.Text("E DMG " .. tostring(0.1*math.floor(1000 * math.min(1, SmartTwitch:GetEDamage(hero) / hero.health))) .. "%", 15, textPos.x - 20, textPos.y + 60, Draw.Color(255, 255, 0, 0))
			end
	    end
	end
	
	--end
	
end)
--Drawing FINISH

--Load SmartTwitch() & Lets Rock
function OnLoad()
    SmartTwitch()
end
