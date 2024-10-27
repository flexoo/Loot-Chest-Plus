-- Table of positions to check for loot to deconstruct
-- Is the automated construction tech researched
-- Change to true if using a Quick Start Mod (like Arumba's) that provides robots/deconstruction planned etc
local auto_cons_researched = true

--								*** Function ***

-- Check if automated construction is researched and change auto_cons_researched to true if so.
function auto_cons_check (force)
    if force then
        if force.technologies["logistic-robotics"].researched then
            auto_cons_researched = true
        end
    elseif game.players[1] and game.players[1].force.technologies["logistic-robotics"].researched then
        auto_cons_researched = true
    end
end


--								*** Scripts ***

--Check if automated construction is researched when a research is finished
script.on_event(defines.events.on_research_finished, function(event)
    auto_cons_check(event.research.force)
end)

-- When an entity dies, we add its position to the table of positions 
-- if we have the automated construction tech and if the mod is enabled
-- ###Big UPS boost created by ptx0### 
script.on_event(defines.events.on_entity_died, function(event)
        local foundLoot = false
        if not storage.artifactList then
                log("[LootChestPlus] Initialise artifactList")
                storage.artifactList = {}
        end
    if string.find(event.entity.name,"spitter") or string.find(event.entity.name, "biter") or string.find(event.entity.name, "worm") or string.find(event.entity.name, "nest") or string.find(event.entity.name, "spawner") then
                entityLoot = event.loot.get_contents() -- gives LuaInventory
                lootCount = 0
                for key,value in pairs(entityLoot) do
                        lootCount = entityLoot[key]
                        itemName = key
                        --if lootCount and lootCount > 0 then
						if #lootCount > 0 then
                                foundLoot = true
                                if not storage.artifactList[itemName] then
                                        storage.artifactList[itemName] = 0
                                end
                                storage.artifactList[itemName] = storage.artifactList[itemName] + lootCount
                                extraText = ""
                                event.loot.clear()
                                extraText = " Uncollected loot has accumulated."
                        end
                end
        else
                return
        end

    if not foundLoot or storage.artifactList == {} then
                return
        end

    --Read storage.artifactList and insert into Loot Chest
        --log("[LootChestPlus] artifactList: "..serpent.block(storage.artifactList))
        local chest = storage.lootChest
        if not chest.valid then
                local errorMsg = "[LootChest+] No loot chest is placed, loot cannot be collected."
                if not storage.validChestCheckCount then
                        storage.validChestCheckCount = 0
                        game.print(errorMsg)
                end
                if storage.validChestCheckCount > 3000 then
                        storage.validChestCheckCount = 0
                        game.print(errorMsg)
                else
                        storage.validChestCheckCount = storage.validChestCheckCount + 1
                end
                return
        end
    local cannotInsert = false
        for _, itemStack in pairs(storage.artifactList) do
                if itemStack > 0 then
                        parameters = {}
                        parameters["name"] = _
                        parameters["count"] = itemStack
                        if(chest.valid and chest.can_insert(parameters)) then
                          chest.insert(parameters)
                          storage.artifactList[parameters["name"]] = 0
                          event.loot.clear()
                        else
                          cannotInsert = true
                        end
                end
        end
    if chest.valid and cannotInsert then
                for _, plr in pairs(chest.force.players) do
                  plr.print("Cannot insert loot. Artifact loot chest is full."..extraText)
                end
        end
end)

script.on_init(function()
  if not storage.lootChest then
		storage.lootChest = {}
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  	if entity.name == "artifact-loot-chest" then
		handleBuiltLootChest(event)
	end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
  local entity = event.entity
  	if entity.name == "artifact-loot-chest" then
		handleBuiltLootChest(event)
	end
end)

script.on_event(defines.events.on_force_created, function(event)
  storage.lootChest = storage.lootChest or {}
 end)
 
script.on_event(defines.events.on_entity_cloned, function(event)
  local entity = event.destination
    if entity.name == "artifact-loot-chest" then
	  storage.lootChest = entity
	end
end)

--logic for handling loot chest spawning, cannot have more than one per force.
function handleBuiltLootChest(event)

	--check if there is a storage table entry for loot chests yet, make one if not.
	if not storage.lootChest then
		storage.lootChest = {}
	end
	
	local chest = event.entity
  
	if not storage.lootChest or not storage.lootChest.valid  then
		storage.lootChest = chest   --this is now the force's chest. 
	else
		game.players[1].print("You can place only one loot chest!")
		chest.surface.spill_item_stack(chest.position, {type = "item", name = "artifact-loot-chest", amount = 1}, true, chest.force)
		chest.destroy()
	end
end
