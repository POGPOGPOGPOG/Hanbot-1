local version = "1.1"

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")
local common = module.load("BlinkEve", "common")

local spellQ = {
range = 800, 
width = 60, 
speed = 2200, 
delay = 0.25, 
boundingRadiusMod = 0,
collision = {
		hero = true,
		minion = true
	}
}

local spellE = {
range = 285
}

local spellR = {
range = 500, 
width = 70, 
speed = math.huge, 
delay = 0.35, 
boundingRadiusMod = 0, 
}


local menu = menu("dontblink", "BlinkEve")
menu:menu("c", "Combo")
menu.c:boolean("rcombo", "Use R in Combo", true)

menu:menu("h", "Harass")
menu.h:boolean("qharass", "Use Q in Harass", true)
menu.h:slider("manaq", "Q Mana", 80, 1, 100, 1)

menu:menu("jc", "Jungle Clear")
menu.jc:boolean("qclear", "Use Q in Jungle Clear", true)
menu.jc:boolean("eclear", "Use E in Jungle Clear", true)

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

TS.load_to_menu(menu)
local TargetSelection = function(res, obj, dist)
	if dist <= spellQ.range then
		res.obj = obj
		return true
	end
end

local TargetSelectionR = function(res, obj, dist)
	if dist <= spellR.range then
		res.obj = obj
		return true
	end
end
local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
end

local TargetSelectionQ = function(res, obj, dist)
	if dist <= spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
end

local TargetSelectionE = function(res, obj, dist)
	if dist <= spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
end

local TargetSelectionW = function(res, obj, dist)
	if dist <= player:spellSlot(1).level * 100 + 1100 then
		res.obj = obj
		return true
	end
end
local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
end

local function count_enemies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.enemies_n - 1 do
		local enemy = objManager.enemies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

local RLevelDamage = {150, 275, 400}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		if target.health > target.maxHealth * 0.3 then
			damage =
			common.CalculateMagicDamage(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * .75)), player)
		else
			damage =
			(common.CalculateMagicDamage(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * .75)), player)) * 2
		end
	end
	return damage
end


local function Combo()
	--TODO: improve W usage
   local target = GetTargetW()
   if common.IsValidTarget(target) and target then
      if(target.pos:dist(player) <= player:spellSlot(1).level * 100 + 1100) then
         player:castSpell("obj", 1, target)
      end
   end
   local target = GetTargetQ()
      if common.IsValidTarget(target) and target then
         local pos = preds.linear.get_prediction(spellQ, target)
		 if player:spellSlot(0).name == "EvelynnQ" then
            if pos and player.pos:to2D():dist(pos.endPos) <= spellQ.range and not preds.collision.get_prediction(spellQ, pos, target) then
               player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
            end
		 else
		    if pos and player.pos:to2D():dist(pos.endPos) <= spellQ.range then
		       player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			end
		 end
      end
   local target = GetTargetE()
   if common.IsValidTarget(target) and target then
      if(target.pos:dist(player) <= spellE.range) then
         player:castSpell("obj", 2, target)
      end
   end
   if menu.c.rcombo:get() then 
	local target = GetTargetR()
	   if common.IsValidTarget(target) and target and not common.CheckBuffType(target, 17) then
	local hp = common.GetShieldedHealth("AP", target)
	   if player:spellSlot(3).state == 0 and vec3(target.x, target.y, target.z):dist(player) < spellR.range and
		  RDamage(target) >= hp then
		  player:castSpell("obj", 3, target)
	   end
	end  
end
end

local function JungleClear()
	if menu.jc.qclear:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if minion and not minion.isDead and minion.isVisible and minion.isTargetable and minion.baseAttackDamage > 5 then
				if minion.pos:dist(player.pos) < spellQ.range then
					player:castSpell("obj", 0, minion)
				end
			end
		end
	end

	if menu.jc.eclear:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if minion and minion.isVisible and minion.isTargetable and not minion.isDead and minion.pos:dist(player.pos) < spellE.range then
				player:castSpell("obj", 2, minion)
			end
		end
	end

   if player:spellSlot(0).state == 0 then
      local enemyMinionsQ = common.GetMinionsInRange(spellQ.range, TEAM_ENEMY)
      for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
         local minion = objManager.minions[TEAM_ENEMY][i]
         if minion and not minion.isDead and common.IsValidTarget(minion) then
            local minion = objManager.minions[TEAM_ENEMY][i]
		    if minion and minion.pos:dist(player.pos) <= spellQ.range and not minion.isDead and common.IsValidTarget(minion) then
		       local minionPos = vec3(minion.x, minion.y, minion.z)
			   if minionPos then
			      local seg = preds.linear.get_prediction(spellQ, minion)
					 if seg and seg.startPos:dist(seg.endPos) < spellQ.range then
					    player:castSpell("pos", 0, vec3(seg.endPos.x, minionPos.y, seg.endPos.y))
					 end
			   end
			end
         end

        
   end
end	
	
end

local function Harass()
      if menu.h.qharass:get() then
	  local target = GetTargetQ()
	     if common.IsValidTarget(target) and target and (player.mana / player.maxMana) * 100 >= menu.h.manaq:get() then
		    if (target.pos:dist(player) < spellQ.range) and (target.pos:dist(player) > 650) then 
			local pos = preds.linear.get_prediction(spellQ, target)
			   if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
			   player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
			   end
			end
		 end
      end
end	  	 
		 
local function OnDraw()
 if player.isOnScreen then 
    if menu.draws.drawq:get() then
	   graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 50)
	end
	--TODO: test this
	if menu.draws.draww:get() then
	   graphics.draw_circle(player.pos, player:spellSlot(1).level * 100 + 1100, 2, menu.draws.colorw:get(), 50)
	end
	--[[if menu.draws.draww:get() then
	   if player:spellSlot(1).level == 1 then	
		  graphics.draw_circle(player.pos, 1200, 2, menu.draws.colorw:get(), 50)
	   end
	   if player:spellSlot(1).level == 2 then	
		   graphics.draw_circle(player.pos, 1300, 2, menu.draws.colorw:get(), 50)
		 end
	    if player:spellSlot(1).level == 3 then	
		   graphics.draw_circle(player.pos, 1400, 2, menu.draws.colorw:get(), 50)
	    end
	    if player:spellSlot(1).level == 4 then	
		   graphics.draw_circle(player.pos, 1500, 2, menu.draws.colorw:get(), 50)
		end
	    if player:spellSlot(1).level == 5 then	
		   graphics.draw_circle(player.pos, 1600, 2, menu.draws.colorw:get(), 50)
		end		
	end]]
	if menu.draws.drawe:get() then
	   graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 50)
	end
 end
end 


local function OnTick()
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.clearkey:get() then
		JungleClear()
	end
end

cb.add(cb.draw, OnDraw)

orb.combat.register_f_pre_tick(OnTick)
