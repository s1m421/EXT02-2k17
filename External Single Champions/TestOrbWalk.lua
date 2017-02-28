class "Orbwalker"

function Orbwalker:__init()
	self.Range = myHero.range + myHero.boundingRadius*1.5
	self.DMG = math.floor(myHero.totalDamage)
	self.ForceTarget = nil
	self.BlockAttack = false
	self.BlockMovement = false
	self._EnemyHeroes = nil
	self._AllyHeroes = nil
	self._ChampionHandle = {}
	
	Callback.Add("Load", function() self:Load() end)
	self.AA = {state = 1, tick = GetTickCount(), tick2 = GetTickCount(), downTime = GetTickCount(), lastTarget = myHero}
	self.lastAttack = GetTickCount()
	self.lastMove = GetTickCount()
end

function Orbwalker:Load()
	self:GetEnemyHeroes()
	self:GetAllyHeroes()
	self:Menu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end

function Orbwalker:ForceTarget(unit)
	if not unit.dead then self.ForceTarget = unit else self.ForceTarget = nil end
end

function Orbwalker:BlockAttack(bool)
	self.BlockAttack = bool
end

function Orbwalker:BlockMovement(bool)
	self.BlockMovement = bool
end

local OnAttackFunc = function() end
function Orbwalker:OnAttack(func)
	OnAttackFunc = func
end

local OnAttackCompFunc = function() end
function Orbwalker:OnAttackComplete(func)
	OnAttackCompFunc = func
end

function Orbwalker:Tick()
	self:AA_Tick()
	self.Range = myHero.range + myHero.boundingRadius*1.5
	if self:GetMode() == "Combo" then 
		-- self:Combo_Orb()
	elseif self:GetMode() == "Harass" then 
		-- self:Harass_Orb()
	elseif self:GetMode() == "Clear" then 
		-- self:Clear_Orb()
	elseif self:GetMode() == "Lasthit" then 
		-- self:Lasthit_Orb()
	elseif self:GetMode() == "Flee" then 
		-- self:Flee_Orb()
	end
end

function Orbwalker:Draw()

end

function Orbwalker:GetMode()
	if OrbwalkerMenu.Key.Combo:Value() then return "Combo" end
	if OrbwalkerMenu.Key.Harass:Value() then return "Harass" end
	if OrbwalkerMenu.Key.Clear:Value() then return "Clear" end
	if OrbwalkerMenu.Key.LastHit:Value() then return "Lasthit" end
	if OrbwalkerMenu.Key.Flee:Value() then return "Flee" end
    return ""
end
		
function Orbwalker:GetEnemyHeroes()
  if self._EnemyHeroes then return self._EnemyHeroes end
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isEnemy then
	  if self._EnemyHeroes == nil then self._EnemyHeroes = {} end
      table.insert(self._EnemyHeroes, unit)
	  self._ChampionHandle[unit.handle] = unit
    end
  end
  return {}
end

function Orbwalker:GetAllyHeroes()
  if self._AllyHeroes then return self._AllyHeroes end
  for i = 1, Game.HeroCount() do
    local unit = Game.Hero(i)
    if unit.isAlly then
	  if self._AllyHeroes == nil then self._AllyHeroes = {} end
      table.insert(self._AllyHeroes, unit)
	  self._ChampionHandle[unit.handle] = unit
    end
  end
  return {}
end

function Orbwalker:GetHeroByHandle(handle)
	return self._ChampionHandle[handle]
end

function Orbwalker:GetWindUp()
	if myHero.charName == "Poppy" and myHero.range > 400 then return myHero.attackData.windUpTime + 0.1 end
	return myHero.attackData.windUpTime
end

local _PS = {
	["Poppy"] = 1800,
	["Jayce"] = 2000,
	["Elise"] = 1600,
}

function Orbwalker:GetProjectileSpeed()
	if (myHero.range < 400 or myHero.attackData.projectileSpeed == 0) then return math.huge end
	if _PS[myHero.charName] ~= nil then if myHero.range > 400 then return _PS[myHero.charName] end end
	return myHero.attackData.projectileSpeed
end

function Orbwalker:AA_Tick()
	if self.AA.state == 1 and myHero.attackData.state == 2 then
		self.lastTick = GetTickCount()
		self.AA.state = 2
		if self:GetHeroByHandle(myHero.attackData.target) ~= nil then
			self.AA.lastTarget = self:GetHeroByHandle(myHero.attackData.target)
		end
		OnAttackFunc()
	end
	if self.AA.state == 2 then
		local passedTime = (Game.Timer() - myHero.attackData.endTime) + (myHero.attackData.endTime) - (myHero.attackData.endTime - myHero.attackData.animationTime)
		if myHero.attackData.state == 1 then
			self.AA.state = 1
		end
		if passedTime + Game.Latency()/1000 > Orbwalker:GetWindUp() - myHero.attackData.castFrame/(200/(0.60*myHero.attackSpeed)) then
		-- if passedTime + Game.Latency()/1000 > Orbwalker:GetWindUp() - myHero.attackData.castFrame/((Game.FPS()+100)/(0.60*myHero.attackSpeed)) then
			self.AA.state = 3
			self.AA.tick2 = GetTickCount()
			self.AA.downTime = myHero.attackData.windDownTime*1000 - (myHero.attackData.windUpTime*1000)
			-- print("WindUp: "..Orbwalker:GetWindUp())
			-- print("ProjSpeed: "..Orbwalker:GetProjectileSpeed())
			-- print("Calc: "..Orbwalker:GetWindUp() - myHero.attackData.castFrame/((Game.FPS()+50)/(0.65*myHero.attackSpeed)))
			DelayAction(function()
				OnAttackCompFunc()
			end,myHero.attackData.castFrame/200 + Game.Latency()/1000)
			if Orbwalker:GetMode() ~= "" then
				self.lastMove = GetTickCount()
				Control.Move()
			end
		end
	end
	if self.AA.state == 3 then
		if GetTickCount() - self.AA.tick2 - Game.Latency() - myHero.attackData.castFrame > myHero.attackData.windDownTime*1000 - (myHero.attackData.windUpTime*1000)/2 then
			self.AA.state = 1
		end
		if myHero.attackData.state == 1 then
			self.AA.state = 1
		end
		if GetTickCount() - self.AA.tick2 > self.AA.downTime + (myHero.attackData.windUpTime*1000)/2 then
			self.AA.state = 1
		end
		if Game.Timer() >= myHero.attackData.endTime - (Game.Latency()/1000) - 0.15 then
			self.AA.state = 1
		end
	end
end

local castAttack = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local function CastAttack(pos,range,delay)
local delay = delay or myHero.attackData.windUpTime*1000/2

local ticker = GetTickCount()
	if castAttack.state == 0 and myHero.pos:DistanceTo(pos.pos) < range and ticker - castAttack.casting > delay + Game.Latency() and Orbwalker.AA.state == 1 and not pos.dead and pos.isTargetable then
		castAttack.state = 1
		castAttack.mouse = mousePos
		castAttack.tick = ticker
		Orbwalker.lastAttack = GetTickCount()
	end
	if castAttack.state == 1 then
		if ticker - castAttack.tick < Game.Latency() and Orbwalker.AA.state == 1 then
				Control.SetCursorPos(pos.pos)
				Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
				Control.mouse_event(MOUSEEVENTF_RIGHTUP)
				castAttack.casting = ticker + delay
			DelayAction(function()
				if castAttack.state == 1 then
					Control.SetCursorPos(castAttack.mouse)
					castAttack.state = 0
				end
			end,Game.Latency()/1000/2)
		end
		if ticker - castAttack.casting > Game.Latency() and castAttack.state == 1 then
			Control.SetCursorPos(castAttack.mouse)
			castAttack.state = 0
		end
	end
end

local castMove = {state = 0, tick = GetTickCount(), mouse = mousePos}
local function CastMove(pos)
local movePos = pos or mousePos
Control.KeyDown(HK_TCO)
DelayAction(function()
	Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
	Control.mouse_event(MOUSEEVENTF_RIGHTUP)
	Control.KeyUp(HK_TCO)
end,0.001)
end

local attacks = {}
local runningMinions = {}
local runningMinionsOn = {}
local mustLasthit = {}
local canLasthit = {}
local missLasthit = {}
local canOrb = {}
local waitOrb = false
local closeTurret = myHero
local turretTarget = 1
local Turret_DMG = {
	["SRU_ChaosMinionRanged"] = 0.7,
	["SRU_ChaosMinionMelee"] = 0.4325,
	["SRU_ChaosMinionSiege"] = 0.14,
	["SRU_ChaosMinionSuper"] = 0.05,
	["SRU_OrderMinionRanged"] = 0.7,
	["SRU_OrderMinionMelee"] = 0.4325,
	["SRU_OrderMinionSiege"] = 0.14,
	["SRU_OrderMinionSuper"] = 0.05
}

for i = 1, Game.TurretCount() do
	local turret = Game.Turret(i)
	if turret.isAlly and turret.pos:DistanceTo(Vector(0,0,0)) < 500 then
		closeTurret = turret
		break
	end
end

local attack_tick = Callback.Add("Tick",function() AttackLoop() end)
function AttackLoop()
	attacks = {}
	runningMinions = {}
	for i = 1, Game.MinionCount() do
		local minion = Game.Minion(i)
		if minion.valid and minion.isAlly and minion.pos:DistanceTo(myHero.pos) < 2500 then
			local aaData = minion.attackData
			if aaData.target ~= nil then
				local projectileSpeed = aaData.projectileSpeed
				local mName = minion.charName
				if mName:find("Melee") or mName:find("Super") then projectileSpeed = math.huge end
				local state = aaData.state
				local windUp = mName:find("Siege") and 0.25 or aaData.windUpTime
				if state == 1 then runningMinions[minion.networkID] = minion end
				if state == 2 or state == 3 then if attacks[aaData.target] == nil then attacks[aaData.target] = {} end table.insert(attacks[aaData.target], {aaData.endTime , windUp, projectileSpeed, minion}) end
			end
		end
	end
	for i = 1, Game.TurretCount() do
		local turret = Game.Turret(i)
		if turret.isAlly and turret.valid and turret.pos:DistanceTo(myHero.pos) < 900 then
			closeTurret = turret
			local aaData = turret.attackData
			if aaData.target ~= nil then
				local projectileSpeed = aaData.projectileSpeed
				local state = aaData.state
				local windUp = 0.15
				turretTarget = aaData.target
				-- print(projectileSpeed)
				if state == 2 or state == 3 then if attacks[aaData.target] == nil then attacks[aaData.target] = {} end table.insert(attacks[aaData.target], {aaData.endTime , windUp, projectileSpeed, turret}) end
			end
		end
	end
	for i,v in pairs(Orbwalker:GetAllyHeroes()) do
		if v ~= myHero and v.valid and v.pos:DistanceTo(myHero.pos) < 2500 then
			local aaData = v.attackData
			if aaData.target ~= nil then
				local projectileSpeed = v.range < 400 and math.huge or aaData.projectileSpeed
				local state = aaData.state
				local windUp = aaData.windUpTime
				if state == 2 or state == 3 then if attacks[aaData.target] == nil then attacks[aaData.target] = {} end table.insert(attacks[aaData.target], {aaData.endTime , windUp, projectileSpeed, v}) end
			end
		end
	end
end

local function HP_Pred(unit,time)
	local time = time - Game.Latency()/1000
	local hp = unit.health
	local attacksOn = 0
	if Orbwalker.AA.state == 3 then runningMinionsOn = {} end
	for i,v in pairs(attacks) do
		if i == unit.handle  then
			for a in pairs(v) do
				if v[a][4].valid then
					if v[a][3] > 5000 then -- meele ( is fine ) 
						local passedTime =  (Game.Timer() - v[a][1]) + (v[a][1]) - (v[a][1] - v[a][4].attackData.animationTime)
						local timeToHit = v[a][2] - passedTime
						local whileTimeToHit = timeToHit
						local count = 0
						while timeToHit < time do
							if timeToHit > 0 then
								count = count + 1
							end
							timeToHit = timeToHit + v[a][4].attackData.animationTime
						end
						if count > 0 then
							hp = hp - math.floor(v[a][4].totalDamage * (1 + v[a][4].bonusDamagePercent) - unit.flatDamageReduction)*count
							attacksOn = attacksOn + 1
						end
					else -- ranged ( is fine now )
						local passedTime =  (Game.Timer() - v[a][1]) + (v[a][1]) - (v[a][1] - v[a][4].attackData.animationTime)
						local timeToHit = v[a][2] + ((unit.pos:DistanceTo(v[a][4].pos) + v[a][4].boundingRadius) /v[a][3]) - passedTime
						-- local timeToHit = v[a][2] + (unit.pos:DistanceTo(v[a][4].pos) /v[a][3]) - passedTime
						local whileTimeToHit = timeToHit
						local count = 0
						while whileTimeToHit < time do
							if whileTimeToHit > 0 then
								count = count + 1
							end
							whileTimeToHit = whileTimeToHit + v[a][4].attackData.animationTime
						end
						if count > 0 then
							if v[a][4].charName:find("Turret") then
								hp = hp - math.floor(unit.maxHealth*Turret_DMG[unit.charName])*count
							else
								hp = hp - math.floor(v[a][4].totalDamage * (1 + v[a][4].bonusDamagePercent) - unit.flatDamageReduction)*count
							end
							attacksOn = attacksOn + 1
						end
					end
				end
			end
		end
	end
	runningMinionsOn = {}
	runningMinionsOn[unit.networkID] = 0
	for i,v in pairs(runningMinions) do
		local range = (v.charName:find("Melee") or v.charName:find("Super")) and 150 or 650
		if v.pos:DistanceTo(unit.pos) < range + 150 and unit.handle ~= v.attackData.target then
			runningMinionsOn[unit.networkID] = runningMinionsOn[unit.networkID] + 1
		end
	end
	return math.floor(hp)
end

function Orbwalker:Menu()
	OrbwalkerMenu = MenuElement({id = "Orbwalker", name = "HP-Pred | "..myHero.charName, type = MENU ,leftIcon = "http://taggs.co/icons/Goal@2x.png" })
	
	OrbwalkerMenu:MenuElement({id = "Key", name = "Key Settings", type = MENU})
		OrbwalkerMenu.Key:MenuElement({id = "Combo", name = "Combo", key = string.byte(" ")})
		OrbwalkerMenu.Key:MenuElement({id = "Harass", name = "Harass | Mixed", key = string.byte("C")})
		OrbwalkerMenu.Key:MenuElement({id = "LastHit", name = "LastHit", key = string.byte("X")})
		OrbwalkerMenu.Key:MenuElement({id = "Clear", name = "Waveclear", key = string.byte("Y")})
		OrbwalkerMenu.Key:MenuElement({id = "Flee", name = "Flee", key = string.byte("Y")})
		
	OrbwalkerMenu:MenuElement({id = "extraWindUp", name = "Extra Windup", value = 0.05, min = 0, max = 0.2, step = 0.01})
	OrbwalkerMenu:MenuElement({id = "savagery", name = "Savagery Stacks", value = 0, min = 0, max = 5, step = 1})

end

Orbwalker:OnAttack(function()
	-- print("!")
end)

Orbwalker:OnAttackComplete(function()
	-- print("?")
end)

-- function OnDraw()
function Orbwalker:Draw()
	local myRange = myHero.range + myHero.boundingRadius*1.5
	Draw.Circle(myHero.pos,myRange,1,Draw.Color(240,40,250,100)) -- green
	if closeTurret then Draw.Circle(closeTurret.pos,900,2,Draw.Color(240,40,50,200))  end -- blue 
	if Orbwalker:GetMode() == "Clear" then

		waitOrb = false
		local underTowerClear = false
		mustLasthit = {}
		canLasthit = {}
		missLasthit = {}
		canOrb = {}

		-- if AA.state == 1 then
			for i = 1, Game.MinionCount() do
				local minion = Game.Minion(i)
				if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < myRange + 250 then
					-- local projectileSpeed = (myHero.range < 400 or myHero.attackData.projectileSpeed == 0) and math.huge or myHero.attackData.projectileSpeed
					local projectileSpeed = Orbwalker:GetProjectileSpeed()
					local hpPred = HP_Pred(minion,myHero.attackData.windUpTime + (minion.pos:DistanceTo(myHero.pos))/projectileSpeed - OrbwalkerMenu.extraWindUp:Value())
					-- local hpPred = HP_Pred(minion,myHero.attackData.windUpTime + (minion.pos:DistanceTo(myHero.pos))/projectileSpeed)
					local hpPred2 = HP_Pred(minion,myHero.attackData.windUpTime*3 + (myRange/projectileSpeed)*2 + myHero.attackData.animationTime - OrbwalkerMenu.extraWindUp:Value())
					local myDMG = math.floor(myHero.totalDamage + OrbwalkerMenu.savagery:Value())
					-- print(myDMG)
					if hpPred < - 10 then
						table.insert(missLasthit,minion)
						if attacks[minion.handle] ~= nil then
							runningMinionsOn[minion.networkID] = runningMinionsOn[minion.networkID] + #attacks[minion.handle]
						end
					end
					
						if hpPred <= myDMG and hpPred > 0 and (hpPred2 < 1 or minion.charName:find("Siege")) and minion.pos:DistanceTo(myHero.pos) < myRange then
							table.insert(mustLasthit,minion)
							-- mustLasthit[minion.networkID] = minion
						elseif hpPred <= myDMG and hpPred > 0 and minion.pos:DistanceTo(myHero.pos) < myRange then
							table.insert(canLasthit,minion)
							-- canLasthit[minion.networkID] = minion
						elseif ((hpPred2 - myDMG > 10) or (hpPred2 == minion.health)) and runningMinionsOn[minion.networkID] < 2 and minion.pos:DistanceTo(myHero.pos) < myRange and minion.pos:DistanceTo(closeTurret.pos) > 900 then
						-- elseif ((hpPred2 - myDMG > 10) or (hpPred2 == minion.health)) and runningMinionsOn[minion.networkID] < 2 and minion.pos:DistanceTo(myHero.pos) < myRange then
							table.insert(canOrb,minion)
							-- canOrb[minion.networkID] = minion
						elseif hpPred2 - (minion.health - hpPred) - myDMG < 1 and hpPred2 - (minion.health - hpPred) < minion.health then
							-- Draw.Circle(minion.pos,50,Draw.Color(240,250,250,60)) -- orange
							waitOrb = true
						end
						
					if minion.pos:DistanceTo(closeTurret.pos) < 900 and runningMinionsOn[minion.networkID] < 2 then	
						-- Draw.Circle(minion.pos,50,Draw.Color(240,50,50,220))
						local pewpew = math.floor(hpPred2/math.floor(minion.maxHealth*Turret_DMG[minion.charName]))
						local delay = (1/0.83)*(pewpew)
						-- local undertowerHPPred = HP_Pred(minion,myHero.attackData.windUpTime + (minion.pos:DistanceTo(myHero.pos) - myHero.boundingRadius)/projectileSpeed + delay)
						-- local undertowerHPPred = HP_Pred(minion,myHero.attackData.windUpTime + (minion.pos:DistanceTo(myHero.pos) - myHero.boundingRadius)/projectileSpeed + (math.floor(hpPred2/math.floor(minion.maxHealth*Turret_DMG[minion.charName]))))
						local undertowerHPPred = HP_Pred(minion,myHero.attackData.windUpTime*2 + ((minion.pos:DistanceTo(myHero.pos))/projectileSpeed)*2 + delay + 2)
						-- local undertowerHPPred = HP_Pred(minion,50)

						local check = math.floor((hpPred2-myDMG)/math.floor(minion.maxHealth*Turret_DMG[minion.charName])) -- works
						Draw.Text(pewpew,minion.pos:ToScreen())

						waitOrb = false
						local attacks = math.floor(delay/(0.65*myHero.attackSpeed))
						if undertowerHPPred < 1 and pewpew <= 3 and pewpew >= attacks then
							waitOrb = true
							Draw.Circle(minion.pos,50,Draw.Color(240,250,250,60)) -- orange
						end
						if (pewpew == check or pewpew > 5) and waitOrb == false then
							underTowerClear = true
							Draw.Circle(minion.pos,55,Draw.Color(240,50,50,220))
							table.insert(canOrb,minion)
						end
					end
				end
			end

		
		table.sort(mustLasthit, function(a, b)
					local first = a.maxHealth
					local second = b.maxHealth
					return first > second
				end)
		table.sort(canLasthit, function(a, b)
					local first = a.maxHealth
					local second = b.maxHealth
					return first > second
				end)
		if underTowerClear == true then
			table.sort(canOrb, function(a, b)
						local first = a.pos:DistanceTo(closeTurret.pos)
						local second = b.pos:DistanceTo(closeTurret.pos)
						return first < second
					end)
		end
				
		for i,minion in pairs(missLasthit) do
			-- Draw.Circle(minion.pos,50,Draw.Color(220,245,70,30)) -- red
			-- Control.CastSpell(HK_E,minion)
		end
		
		if mustLasthit[1] ~= nil then
			local minion = mustLasthit[1]
			Draw.Circle(minion.pos,50,Draw.Color(220,245,70,30)) -- red
			
			if Orbwalker.AA.state == 1 and Orbwalker.AA.state ~= 2 and GetTickCount() - Orbwalker.lastAttack > 100 and minion.pos:DistanceTo(myHero.pos) <= myRange then
				CastAttack(minion,myRange,100)
				Orbwalker.lastAttack = GetTickCount()
			end
		elseif canLasthit[1] ~= nil then
			local minion = canLasthit[1]
			Draw.Circle(minion.pos,50,Draw.Color(240,40,250,100)) -- green
			-- Draw.Circle(minion.pos,50,Draw.Color(240,40,250,100))
			if Orbwalker.AA.state == 1 and Orbwalker.AA.state ~= 2 and GetTickCount() - Orbwalker.lastAttack > 100 and minion.pos:DistanceTo(myHero.pos) <= myRange  then
				CastAttack(minion,myRange,100)
				Orbwalker.lastAttack = GetTickCount()
			end
		elseif waitOrb == false or underTowerClear == true then
			if canOrb[1] ~= nil then
				local minion = canOrb[1]
				if Orbwalker.AA.state == 1 and Orbwalker.AA.state ~= 2 and GetTickCount() - Orbwalker.lastAttack > 100 and minion.pos:DistanceTo(myHero.pos) <= myRange  then
					-- print(waitOrb)
					CastAttack(minion,myRange,100)
					Orbwalker.lastAttack = GetTickCount()
				end
			end
		end	
		
		-- end
		
		if Orbwalker.AA.state ~= 2 and GetTickCount() - Orbwalker.lastMove > 220 and GetTickCount() - Orbwalker.lastAttack > 200 then
			CastMove()
			-- Control.Move()
			Orbwalker.lastMove = GetTickCount()
		end
		
	end
end

function OnDraw()
	-- for i = 1, Game.MinionCount() do
		-- local minion = Game.Minion(i)
	-- for i,minion in pairs(GetEnemyHeroes()) do
		-- if minion.valid and minion.isEnemy and minion.pos:DistanceTo(myHero.pos) < 1000 then
			-- local projectileSpeed = myHero.range < 400 and math.huge or myHero.attackData.projectileSpeed
			-- local hpPred = HP_Pred(minion,myHero.attackData.windUpTime + (minion.pos:DistanceTo(myHero.pos) - myHero.boundingRadius*2)/projectileSpeed)
			-- if hpPred < myHero.totalDamage and hpPred > 0 then
				-- if myHero.attackData.state == 1 then
					-- Control.Attack(minion)
				-- end
				-- Draw.Circle(minion.pos)
			-- end
		-- end
	-- end
end


_G.Orbwalker = Orbwalker()

