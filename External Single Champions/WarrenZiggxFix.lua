if myHero.charName ~= "Ziggs" then return end

require "DamageLib"

-- Spells

Q = {Delay = 0, Range = 1400, Radius = 180, Speed = 1700, Collision = true}
W = {Delay = 0, Range = 1000, Radius = 325, Speed = 1700, Collision = false}
E = {Delay = 0, Range = 900, Radius = 325, Speed = 1700, Collision = false}

-- Menu

Menu = MenuElement({type = MENU, id = "Ziggs", name = "Warren - WarrenZiggs", lefticon="https://digitumart.files.wordpress.com/2015/07/pepe-angry.jpg"})

-- [[Keys]]

Menu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
Menu.Key:MenuElement({id = "ComboKey", name = "Combo Key", key = 32})
Menu.Key:MenuElement({id = "HarassKey", name = "Harass Key", key = 67})
Menu.Key:MenuElement({id = "FarmKey", name = "Farm Key", key = 86})
Menu.Key:MenuElement({id = "LastHitKey", name = "Last Hit Key", key = 88})

-- [[Combo]]
Menu:MenuElement({type = MENU, id = "Combo", name = "Combo Settings"})
Menu.Combo:MenuElement({id = "ComboQ", name = "Use Q", value = true})
Menu.Combo:MenuElement({id = "ComboW", name = "Use W", value = true})
Menu.Combo:MenuElement({id = "ComboE", name = "Use E", value = true})

-- [[Harass]]
Menu:MenuElement({type = MENU, id = "Harass", name = "Harass Settings"})
Menu.Harass:MenuElement({id = "HarassQ", name = "Use Q", value = true})
Menu.Harass:MenuElement({id = "HarassW", name = "Use W", value = true})
Menu.Harass:MenuElement({id = "HarassE", name = "Use E", value = true})

-- [[Farm]]
Menu:MenuElement({type = MENU, id = "Farm", name = "Farm Settings"})
Menu.Farm:MenuElement({id = "FarmSpells", name = "Farm Spells", value = true})
Menu.Farm:MenuElement({id = "FarmQ", name = "Use Q", value = true})
Menu.Farm:MenuElement({id = "FarmE", name = "Use E", value = true})

-- [[Misc]]
Menu:MenuElement({type = MENU, id = "Misc", name = "Misc Settings"})
Menu.Misc:MenuElement({id = "MaxRange", name = "Max Range Limiter", value = 0.9, min = 0.5, max = 1, step = 0.01})
Menu.Misc:MenuElement({type = SPACE, id = "ToolTip", name = "eg. X = 0.80 (Q.Range = (1400 * 0.80) = 1120)"})

-- [[Spell Data]]
local qSpellData = myHero:GetSpellData(_Q);
local wSpellData = myHero:GetSpellData(_W);
local eSpellData = myHero:GetSpellData(_E);
 
-- GetTarget - Returns target
function GetTarget(targetRange)
  local result 
  for i = 1,Game.HeroCount() do
    if isValidTarget(hero, targetRange) and hero.team ~= myHero.team then 
    local hero = Game.Hero(i)
      result = hero
    end
      break 
  end
  return result
end





function GetFarmTarget(minionRange)
  local getFarmTarget
  for j = 1,Game.MinionCount() do
    local minion = Game.Minion(j)
    if isValidTarget(minion, minionRange) and minion.team ~= myHero.team then
      getFarmTarget = minion 
    break
    end
  end
  return getFarmTarget
end


Callback.Add('Tick', function()
    
    if Menu.Key.ComboKey:Value() then
      if isReady(_Q) and Menu.Combo.ComboQ:Value() then
        local qTarget = GetTarget(Q.Range * Menu.Misc.MaxRange:Value())
        if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) == 0 then
          local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay)
          Control.CastSpell(HK_Q, qPos)
        end
      end
      if isReady(_W) and Menu.Combo.ComboW:Value() then
        local wTarget = GetTarget(W.Range * Menu.Misc.MaxRange:Value())
        if wTarget then 
          local wPos = Target:GetPrediction(W.Speed, W.Delay)
          Control.CastSpell(HK_W, wPos)
        end
      end
      if isReady(_E) and Menu.Combo.ComboE:Value() then
        local eTarget = GetTarget(E.Range * Menu.Misc.MaxRange:Value())
        if eTarget then
          local ePos = Target:GetPrediction(E.Speed, E.Delay)
          Control.CastSpell(HK_E, ePos)
        end
      end
	  end -- End of SpaceBar Rotation
      
      
      if Menu.Key.HarassKey:Value() then
        if isReady(_Q) and Menu.Harass.HarassQ:Value() then
          local qTarget = GetTarget(Q.Range:Value())
          if qTarget and qTarget:GetCollision(Q.Radius, Q.Speed, Q.Delay) == 0 then
            local qPos = qTarget:GetPrediction(Q.Speed, Q.Delay) 
            Control.CastSpell(HK_Q, qPos)
          end
        end
        if isReady(_W) and Menu.Harass.HarassW:Value() then 
          local wTarget = GetTarget(W.Range:Value())
          if wTarget then
            local wPos = wTarget:GetPrediction(W.Speed, W.Delay)
            Control.CastSpell(HK_W, wPos)
        end
      end
      if isReady(_E) and Menu.Harass.HarassE:Value() then
        local eTarget = GetTarget(E.Range:Value())
        if eTarget then 
          local ePos = eTarget:GetPrediction(E.Speed, E.Delay)
          Control.CastSpell(HK_E, ePos)
        end
      end
    end
    
      if Menu.Key.FarmKey:Value() then
        if isReady(_Q) and Menu.Farm.FarmQ:Value() then
          local qMinion = GetFarmTarget(Q.Range:Value())
          if qMinion then
            local qMinPos = qMinion:GetPrediction(Q.Speed, Q.Delay)
            control.CastSpell(HK_Q, qMinPos)
          end 
        end
      end
    --end Old SpaceBar
	
	end
	
  end)
    
    
    Callback.Add('Load',function()
        PrintChat("Warrens Ziggs - Loaded")
      end)
    
   
   function isReady(slot)
     return (myHero:GetSpellData(slot).currentCd == 0) and (myHero:GetSpellData(slot).mana < myHero.mana) and (myHero:GetSpellData(slot).level >= 1)
   end
   
   function isValidTarget(obj, spellRange)
     return obj ~= nil and obj.valid and obj.visible and not obj.dead and obj.isTargetable and obj.distance <= spellRange
   end