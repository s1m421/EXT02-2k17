-- Copyright Smart under GNU licence.
-- Smart LoL GOS User
-- AKA : Call me Smart / SmartSharp
-- Contact skype: smart0095

if myHero.charName ~= "Lux" then return end

require "DamageLib"

-- Spells
local Q = {Delay = 0.250, Radius = 75, Range = 1160, Speed = 1900, Collision = true}
local E = {Delay = 0.250, Radius = 200, Range = 1250, Speed = 900, Collision = false}
local R = {Delay = 1, Radius = 120, Range = 3300, Speed = math.huge, Collision = false}

-- Menu local
local Menu = MenuElement({type = MENU, id = "SmartLux", name = "Smart Lux", leftIcon="http://puu.sh/ul3vR/fc3f5ec4f3.jpg"})

-- Keys Menu
Menu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
Menu.Key:MenuElement({id = "ComboKey", name = "Combo Key", key = 32})
Menu.Key:MenuElement({id = "HarassKey", name = "Harass Key", key = 67})
Menu.Key:MenuElement({id = "WaveClearKey", name = "Wave Clear Key", key = 86})
Menu.Key:MenuElement({id = "LastHitKey", name = "Last Hit Key", key = 88})
Menu.Key:MenuElement({id = "TrapKey", name = "Trap on Fow HK", key = 84})
Menu.Key:MenuElement({id = "StealKey", name = "Steal Drake / Nash Key (Low Range - Behind the Wall of the Boss)", key = 72})

-- Combo Menu
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "SmartQ", name = "Smart Q WIP", value = true})
Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})
Menu.Combo:MenuElement({id = "ComboR", name = "Use R", value = true})
Menu.Combo:MenuElement({id = "SmartR", name = "Smart R - WIP", value = true})

-- Harass Menu
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})
Menu.Harass:MenuElement({id = "HarassMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Farm Menu
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
Menu.Farm:MenuElement({id = "FarmSpells", name = "Farm Spells", value = false})
Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = false})
Menu.Farm:MenuElement({id = "FarmMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- LastHit Menu
Menu:MenuElement({type = MENU, id = "LastHit", name = "Last Hit Settings - WORK IN PROGRESS"})
Menu.LastHit:MenuElement({id = "LastHitQ", name = "Use Q", value = false})
Menu.LastHit:MenuElement({id = "LastHitMana", name = "Min. Mana", value = 40, min = 0, max = 100})

-- Ultimate Misc Menu
Menu:MenuElement({type = MENU, id = "UltimateMisc", name = "Ultimate Misc - WORK IN PROGRESS"})
Menu.UltimateMisc:MenuElement({id = "AutoR", name = "Lux will R to Kill Single enemy on CC", value = true})

-- General Misc Menu
Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
Menu.Misc:MenuElement({id = "MaxRange", name = "Max Range Limiter", value = 0.9, min = 0.5, max = 1, step = 0.01})
Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "eg. X = 0.80 (Q.Range = (1150 * 0.80) = 920)"})
Menu.Misc:MenuElement({id = "Debug", name = "Debug Mode", value = true})

-- Drawings Menu
Menu:MenuElement({type = MENU, id = "Draw", name = "Drawing Settings"})
Menu.Draw:MenuElement({id = "DrawQ", name = "Draw Q", value = true})
Menu.Draw:MenuElement({id = "DrawE", name = "Draw E", value = true})
Menu.Draw:MenuElement({id = "DrawR", name = "Draw R", value = true})
Menu.Draw:MenuElement({id = "DrawTarget", name = "Draw Target", value = true})

--Call me Stupid for not Setting this Function before.
function GetTarget(targetRange)
	local result
	for i = 1,Game.HeroCount()  do
		local hero = Game.Hero(i)
		if isValidTarget(hero, targetRange) and hero.team ~= myHero.team then
      		result = hero
      		break
		end
	end
	return result
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


function GetFarmTarget(minionRange)
	local getFarmTarget
	for j = 1,Game.MinionCount()	do
		local minion = Game.Minion(j)
		if isValidTarget(minion, minionRange) and minion.team ~= myHero.team then
      		getFarmTarget = minion
      		break
		end
	end
	return getFarmTarget
end

-- Damage Calculations TEST Function
function GetRDmg(target)

	local spellLevel = myHero:GetSpellData(_R).level

	local rDamage = {300, 400, 500}
	local apDamage = myHero.ap * 0.70

	local finalDamage = rDamage[spellLevel] + apDamage
	--local finalDamage = (getdmg("R", target, myHero, 1) * luxR[target.networkID].stacks) * 0.8

end

--DEBUG Function

-- FINISH DEBUG


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


-- Events
-- OnUpdate (30')
Callback.Add('Tick',function()



	if Menu.Key.ComboKey:Value()  then--START COMBO SECTION
	--print(myHero:GetSpellData(_E).name)
	-- LuxLightstrikeToggle -- EXPLOSION
	-- LuxLightStrikeKugel -- Lanzamiento
	--local Evar = 0
	--local Qvar = 0
	
	
	if myHero:GetSpellData(_E).name == "LuxLightStrikeKugel" then
   --throw here
   if isReady(_E) and Menu.Combo.ComboE:Value() then
   local eTarget = GetTarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget then
			local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				if Menu.Misc.Debug:Value() then
                PrintChat("Combo E Predict")
			end
		end
		end
else if not isReady(_Q) and isReady(_E) then
local eTarget = GetTarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget then
			local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				if Menu.Misc.Debug:Value() then
				PrintChat("Auto Smart Explosion")
			end
		end
		end
  --explode here
end


		--SMART Q (IF SMART Q ENABLED)
		if isReady(_Q) and --[[not Evar and--]] Menu.Combo.SmartQ:Value() then
			local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget --[[and (IsSlowTarget(qTarget) or IsImmobileTarget(qTarget) or IsFearOrCharm(qTarget))]] and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,qPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				if Menu.Misc.Debug:Value() then
                PrintChat("Smart Q After E Predict")
			end
		end
		end
		
	
		--DEFAULT Q	(IF SMART Q DISABLED)
		if not Menu.Combo.SmartQ:Value() then
		if isReady(_Q) and Menu.Combo.ComboQ:Value() then
			local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,qPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				if Menu.Misc.Debug:Value() then
                PrintChat("Q DEFAULT")
		end
		end
		end
		end
		
		
		

--[[ OLD E SYSTEM
		
		-- THROW E (Actually there are no more E Casting methods) -- PROBLEM HERE
		if isReady(_E) and Menu.Combo.ComboE:Value() then --Throw E
			local eTarget = GetTarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget and Evar then -- Si la E no esta en el Aire entonces la Lanzamos
				local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				local Evar = false -- Como E esta en en Aire desactivamos mas Cast hasta la Q
				if Menu.Misc.Debug:Value() then
                PrintChat("Combo E THROW BEFORE Q")
			end
		end
		end
		
 -- Explodes E
        if isReady(_E) and not Evar and not isReady(_Q) and Menu.Combo.ComboE:Value() then -- Cuando la E este ya en el aire y la Q tambien entonces Explotamos
            local eTarget = GetTarget(E.Range * Menu.Misc.MaxRange:Value())
            if eTarget and IsSlowTarget(eTarget) and not isReady(_Q) then
                local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
                CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
          --local Evar = true -- Reiniciamos bucle de E
				--local Evar = 0
				if Menu.Misc.Debug:Value() then
                PrintChat("Combo E EXPLODED AFTER E-Q")
            end
        end
		end
      
      if not isReady(_E) then --Cuando E esta en CD entonces la habilitamos para volver a lanzar de nuevo.
        local Evar = true
        end
	--]]	

		--- DEFAULT R (IF SMART R DISABLED, BAD IDEA)
				 if isReady(_R) and Menu.Combo.ComboR:Value() and not Menu.Combo.SmartR:Value()  then
			local rTarget = GetTarget(R.Range * Menu.Misc.MaxRange:Value())
		if Menu.Misc.Debug:Value() then
			PrintChat("DEBUG: BAD Logic R Casted")
			if rTarget then
				local rPos = rTarget:GetPrediction(R.Speed, R.Delay)
				Control.CastSpell(HK_R, rPos)
			--end
			end
		end
		end
		
		
		
		
		-- SMART R (IF SMART R ENABLED) NO R IF ENEMY WONT DIE / NO R IF ISNT SAFE HIT ON CC (SINGLE TARGET ATM)
		 if isReady(_R) and Menu.Combo.SmartR:Value() and Menu.Combo.ComboR:Value() then
			local rTarget = GetTarget(R.Range * Menu.Misc.MaxRange:Value())
			if rTarget and IsImmobileTarget(rTarget) then
			PrintChat("Target Not Killeable with R")
				local rPos = rTarget:GetPrediction(R.Speed, R.Delay)
local hp = rTarget.health + rTarget.shieldAP
local dmg = CalcMagicalDamage(myHero,rTarget,200 + 100*myHero:GetSpellData(_R).level + (0.75*myHero.ap))
local dmg2 = dmg * 1.32
--PrintChat(dmg)
PrintChat(dmg2)
						if hp < dmg2 then
						if Menu.Misc.Debug:Value() then
						PrintChat("Debug: R Will KIll So Cast")
				CastSpell(HK_R, rPos, R.Range, R.Delay*1000)--Si el enemigo se mueve falla la R en Root. Set no Pred
			--end
			end
			end
		end
		end
		
		


		
	end--FINISH COMBO KEY
	
			--TRAP KEY
		
		
		if Menu.Key.TrapKey:Value()  then
			local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q, qPos, Q.Range)
		  CastSpell(HK_E, qPos, Q.Range)
		  if not isReady(_Q) and IsImmobileTarget(qTarget) then
		  CastSpell(HK_R, qPos, Q.Range)
				--Control.CastSpell(HK_Q, qPos)
			if Menu.Misc.Debug:Value() then
				PrintChat("DEBUG : Trap Casted")
		end
		end
		end
		

		end--END TRAP KEY

	--Begins Steal Key 1
	
	if Menu.Key.StealKey:Value()  then
		if isReady(_Q) and Menu.Key.StealKey:Value() then
			local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,qPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				--PrintChat("Combo Q Casted")
		end
		end
		
		if isReady(_E) and Menu.Key.StealKey:Value() then
			local eTarget = GetTarget(E.Range * Menu.Misc.MaxRange:Value())
			if eTarget then
				local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
				CastSpell(HK_E, ePos, E.Range, E.Delay*1000)
				--PrintChat("Combo E Casted")
			end
		end
	
	if Menu.Key.HarassKey:Value() and (myHero.mana/myHero.maxMana >= Menu.Harass.HarassMana:Value()/100) then
		if isReady(_Q) and Menu.Harass.HarassQ:Value() then
			local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then
				local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
				Control.CastSpell(HK_Q, qPos)
			end
		end
		if isReady(_W) and Menu.Harass.HarassE:Value() then
			local wTarget = GetTarget(E.Range * Menu.Misc.MaxRange:Value())
			if wTarget then
				local wPos = wTarget:GetPrediction(E.Speed, E.Delay)
				Control.CastSpell(HK_W, wPos)
			end
		end
	end

	if Menu.Key.WaveClearKey:Value() and Menu.Farm.FarmSpells:Value() and (myHero.mana/myHero.maxMana >= Menu.Farm.FarmMana:Value()/100) then
		if isReady(_E) and Menu.Farm.FarmE:Value() then
			local eMinion = GetFarmTarget(E.Range * Menu.Misc.MaxRange:Value())
			if eMinion then
				local eMinPos = eMinion:GetPrediction(E.Speed, E.Delay)
				Control.CastSpell(HK_E, eMinPos)
			end
		end
	end
	
end--End of Steal System

--Start AUTO System
--AUTO Q
if isReady(_Q) then
			local aqTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
			if aqTarget and (IsSlowTarget(aqTarget) or IsImmobileTarget(aqTarget) or IsFearOrCharm(aqTarget)) and aqTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) < 1 then --Added Collision 1 for Q
				local aqPos = aqTarget:GetPrediction(Q.Speed, Q.Delay)
          CastSpell(HK_Q ,aqPos ,Q.Range , Q.Delay*1000)
				--Control.CastSpell(HK_Q, qPos)
				if Menu.Misc.Debug:Value() then
                PrintChat("AUTO Smart Q")
			end
		end
		end
		
		
		--AUTO R
		if isReady(_R) then
			local arTarget = GetTarget(R.Range * Menu.Misc.MaxRange:Value())
			if arTarget and (IsImmobileTarget(arTarget) or IsFearOrCharm(arTarget)) then
			PrintChat("Posible R on Immobile Enemy (But wont die so Aborted)")
				local arPos = arTarget:GetPrediction(R.Speed, R.Delay)
local hp = arTarget.health + arTarget.shieldAP
local dmg = CalcMagicalDamage(myHero,rTarget,200 + 100*myHero:GetSpellData(_R).level + (0.75*myHero.ap))
local dmg2 = dmg * 1.2
PrintChat(dmg)
--print(dmg)
						if hp < dmg2 then
						if Menu.Misc.Debug:Value() then
						PrintChat("Debug: Auto R on Killeable Immobile Enemy")
				CastSpell(HK_R, arPos, R.Range, R.Delay*1000)--Si el enemigo se mueve falla la R en Root. Set no Pred
			--end
			end
			end
		end
		end
-- END AUTO SYSTEM
end)--END OnUptade TICK




-- OnLoad
Callback.Add('Load',function()
	PrintChat("Smart Lux - Loaded")
end)

-- OnDraw ADJUSTABLE by Scale MISC to prevent MAX RANGE PROBLEMS and Complains :D
function OnDraw()
	if myHero.dead then return end

	if Menu.Draw.DrawQ:Value()	then
		Draw.Circle(myHero.pos,Q.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end
	if Menu.Draw.DrawE:Value()	then
		Draw.Circle(myHero.pos,E.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end
	if Menu.Draw.DrawR:Value()	then
		Draw.Circle(myHero.pos,R.Range * Menu.Misc.MaxRange:Value(),1,Draw.Color(255, 255, 255, 255))
	end

    if Menu.Draw.DrawTarget:Value() then
	    local drawTarget = GetTarget(Q.Range)
	    if drawTarget then
		    Draw.Circle(drawTarget.pos,80,3,Draw.Color(255, 255, 0, 0))
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

--[[ TO DO :

Auto R to kill (Ks)
Auto R en X enemies Slider
Fix R en Combo (inmobile target no pred)

E QR Dragon / Nash Stealer (Ya vere)
Ally Shielding

Wave Clear E en X minions Slider

Q para LastHit que no alcanze el AA por distancia o windup

+ Algunos misc como:

No autoatak apartir de X Nivel
Solo autoatak si no hay spells disponibles o esta cerca o lux tiene el buff de AA
Stack Tear con Shield constante si hay mas de 90% Mana

]]--

-- CREDITS : Smart
-- Thanks to Noddy for helping
-- Contact Skype: smart0095