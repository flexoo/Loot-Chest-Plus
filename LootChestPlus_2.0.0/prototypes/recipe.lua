data:extend(
{
  {
    type = "recipe",
    name = "artifact-loot-chest",
    enabled = false,
	energy_required = 5,
	ingredients =
	{
	  {type = "item", name = "steel-plate", amount = 24},
	  {type = "item", name = "electronic-circuit", amount = 25},
	  {type = "item", name = "advanced-circuit", amount = 5}
	},	
    results = {
        {type = "item", name = "artifact-loot-chest", amount = 1}},
	requester_paste_multiplier = 1
  }
})

--Unlock the loot-chest when you research Logistic robotics
table.insert(data.raw["technology"]["logistic-robotics"].effects,{type="unlock-recipe",recipe="artifact-loot-chest"})

--Unlock the loot-chest when you research logistic-system (Deadlock's Industrial Revolution 2)
if mods["IndustrialRevolution"] then
table.insert(data.raw.technology["logistic-system"].effects,{type="unlock-recipe",recipe="artifact-loot-chest"})
end