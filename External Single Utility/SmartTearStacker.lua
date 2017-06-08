--[[ Copyright Smart under GNU licence. ]]--
local a={Delay=0.250,Radius=75,Range=1160,Speed=1900}local b={Delay=0.250,Radius=200,Range=1250,Speed=900}local c={Delay=1,Radius=120,Range=3300,Speed=math.huge}local d=MenuElement({type=MENU,id="SmartTearStacker",name="Smart Tear Stacker",leftIcon="http://puu.sh/urxln/2d814c7f82.jpg"})d:MenuElement({type=MENU,id="Enable",name="Enable/Disable"})d.Enable:MenuElement({id="Enable",name="Enable / Disable Button",value=true})d:MenuElement({type=MENU,id="Key",name="Key Settings"})d.Key:MenuElement({id="ComboKey",name="Disable on Combo Key",key=32})d.Key:MenuElement({id="HarassKey",name="Disable on Harass Key",key=67})d.Key:MenuElement({id="WaveClearKey",name="Disable on Wave Clear Key",key=86})d.Key:MenuElement({id="LastHitKey",name="Disable on Last Hit Key",key=88})d:MenuElement({type=MENU,id="Spells",name="Spells to Use"})d.Spells:MenuElement({id="Qusage",name="Use Q to Stack",value=true})d.Spells:MenuElement({id="Wusage",name="Use W to Stack",value=true})d.Spells:MenuElement({id="Eusage",name="Use E to Stack",value=true})d:MenuElement({type=MENU,id="ManaManager",name="Mana Manager"})d.ManaManager:MenuElement({id="Mana",name="Min. Mana",value=90,min=0,max=100})d:MenuElement({type=MENU,id="DrawOn",name="Drawing Settings"})d.DrawOn:MenuElement({id="DrawOn",name="Draw Status",value=true})local e={state=0,tick=GetTickCount(),casting=GetTickCount()-1000,mouse=mousePos}local function f(g,h,i,j)local i=i or math.huge;local j=j or 250;local k=GetTickCount()if e.state==0 and h:DistanceTo(myHero.pos)<i and k-e.casting>j+Game.Latency()and h:ToScreen().onScreen then e.state=1;e.mouse=mousePos;e.tick=k end;if e.state==1 then if k-e.tick<Game.Latency()then Control.SetCursorPos(h)Control.KeyDown(g)Control.KeyUp(g)e.casting=k+j;DelayAction(function()if e.state==1 then Control.SetCursorPos(e.mouse)e.state=0 end end,Game.Latency()/1000)end;if k-e.casting>Game.Latency()then Control.SetCursorPos(e.mouse)e.state=0 end end end;function GetBuffs(l)T={}for m=0,l.buffCount do local n=l:GetBuff(m)if n.count>0 then table.insert(T,n)end end;return T end;function ImRecalling()for o,n in pairs(GetBuffs(myHero))do if n.name=="recall"and n.duration>0 then return true end end;return false end;function GetItemSlot(l,p)for m=ITEM_1,ITEM_7 do if l:GetItemData(m).itemID==p then return m end end;return 0 end;Callback.Add('Tick',function()if not d.Key.ComboKey:Value()and not d.Key.HarassKey:Value()and not d.Key.WaveClearKey:Value()and not d.Key.LastHitKey:Value()then if d.Enable.Enable:Value()and myHero.mana/myHero.maxMana>=d.ManaManager.Mana:Value()/100 and not ImRecalling()then local q=GetItemSlot(myHero,3070)local r=GetItemSlot(myHero,3003)local s=GetItemSlot(myHero,3004)if q>0 and myHero:GetSpellData(q).currentCd==0 then if isReady(_W)and d.Spells.Wusage:Value()then Control.CastSpell(HK_W)elseif isReady(_E)and d.Spells.Eusage:Value()then Control.CastSpell(HK_E)elseif isReady(_Q)and d.Spells.Qusage:Value()then Control.CastSpell(HK_Q)end end;if r>0 and myHero:GetSpellData(q).currentCd==0 then if isReady(_W)and d.Spells.Wusage:Value()then Control.CastSpell(HK_W)elseif isReady(_E)and d.Spells.Eusage:Value()then Control.CastSpell(HK_E)elseif isReady(_Q)and d.Spells.Qusage:Value()then Control.CastSpell(HK_Q)end end;if s>0 and myHero:GetSpellData(q).currentCd==0 then if isReady(_W)and d.Spells.Wusage:Value()then Control.CastSpell(HK_W)elseif isReady(_E)and d.Spells.Eusage:Value()then Control.CastSpell(HK_E)elseif isReady(_Q)and d.Spells.Qusage:Value()then Control.CastSpell(HK_Q)end end end end end)Callback.Add('Load',function()PrintChat("Smart Tear Stacker - Loaded")end)function OnDraw()if myHero.dead then return end;if d.DrawOn.DrawOn:Value()then if d.Enable.Enable:Value()then end end end;function isReady(t)return myHero:GetSpellData(t).currentCd==0 and myHero:GetSpellData(spellSlot).mana<myHero.mana and myHero:GetSpellData(t).level>=1 end;function isValidTarget(u,v)return u~=nil and u.valid and u.visible and not u.dead and u.isTargetable and u.distance<=v end
--[[
Contact:
Skype: Smart0095
Discord: Smart#7165
Thanks to
Sebby for inspiration
Noddy for helping
]]--
