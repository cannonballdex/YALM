local Classes = require("yalm.definitions.Classes")
local InventorySlots = require("yalm.definitions.InventorySlots")
local ItemTypes = require("yalm.definitions.ItemTypes")
local bit = require("bit")

local Item = {}
Item.__index = Item

local function parseFlags(flags, object)
	local values = {}
	local newFlags = flags or 0

	for i = 1, #object do
		local flag = bit.band(newFlags, 1)
		newFlags = bit.rshift(newFlags, 1)
		if flag == 1 then
			table.insert(values, object[i])
		end
	end

	return values
end

function Item:new(item_db)
	local o = {
		item_db = item_db or {},
	}
	setmetatable(o, self)
	return o
end

function Item:AugSlot1()
	return self.item_db.augslot1type
end

function Item:AugSlot2()
	return self.item_db.augslot2type
end

function Item:AugSlot3()
	return self.item_db.augslot3type
end

function Item:AugSlot4()
	return self.item_db.augslot4type
end

function Item:AugSlot5()
	return self.item_db.augslot5type
end

function Item:AugSlot6()
	return self.item_db.augslot6type
end

function Item:AugType()
	return self.item_db.augtype
end

function Item:CastTime()
	return self.item_db.CastTime
end

function Item:CHA()
	return self.item_db.acha
end

function Item:Charges()
	return self.item_db.maxcharges
end

function Item:Clairvoyance()
	return self.item_db.clairvoyance
end

function Item:Class(class)
	local classes = parseFlags(self.item_db.classes, Classes)
	for i = 1, #classes do
		if classes[i]:find(class) then
			return class
		end
	end
	return "NULL"
end

function Item:Classes()
	local classes = parseFlags(self.item_db.classes, Classes)
	return #classes
end

function Item:Clicky() end

function Item:Collectible()
	return (self.item_db.collectible or 0) > 0
end

function Item:CombatEffects() end

function Item:Combinable() end

function Item:Container()
	return self.item_db.bagslots
end

function Item:ContentSize()
	return self.item_db.bagsize
end

function Item:Damage()
	return self.item_db.damage
end

function Item:DamageShieldMitigation() end

function Item:DamShield() end

function Item:Deities() end

function Item:Deity(name) end

function Item:Delay()
	return self.item_db.delay
end

function Item:Dex()
	return self.item_db.adex
end

function Item:DMGBonus()
	return self.item_db.extradmgamt
end

function Item:DMGBonusType() end

function Item:DoTShielding() end

function Item:EffectType() end

function Item:Endurance()
	return self.item_db.endurance
end

function Item:EnduranceRegen()
	return self.item_db.enduranceregen
end

function Item:Evolving() end

function Item:Expendable() end

function Item:Familiar() end

function Item:FirstFreeSlot() end

function Item:Focus() end

function Item:Focus2() end

function Item:FocusID()
	return self.item_db.focuseffect
end

function Item:FreeStack() end

function Item:Haste()
	return self.item_db.Haste
end

function Item:HealAmount()
	return self.item_db.healamt
end

function Item:Heirloom()
	return self.item_db.heirloom
end

-- Keep backward compatibility if old code uses the misspelled name.
Item.Heirloiom = Item.Heirloom

function Item:HeroicAGI()
	return self.item_db.heroic_agi
end

function Item:HeroicCHA()
	return self.item_db.heroic_cha
end

function Item:HeroicDEX()
	return self.item_db.heroic_dex
end

function Item:HeroicINT()
	return self.item_db.heroic_int
end

function Item:HeroicSTA()
	return self.item_db.heroic_sta
end

function Item:HeroicSTR()
	return self.item_db.heroic_str
end

function Item:HeroicSvCold() end

function Item:HeroicSvCorruption() end

function Item:HeroicSvDisease() end

function Item:HeroicSvFire() end

function Item:HeroicSvMagic() end

function Item:HeroicSvPoison() end

function Item:HeroicWIS()
	return self.item_db.heroic_wis
end

function Item:HP()
	return self.item_db.hp
end

function Item:HPRegen()
	return self.item_db.regen
end

function Item:Icon()
	return self.item_db.icon
end

function Item:ID()
	return self.item_db.id
end

function Item:IDFile()
	return self.item_db.idfile
end

function Item:IDFile2()
	return self.item_db.idfileextra
end

function Item:Illusion() end

function Item:InstrumentMod()
	return self.item_db.bardvalue
end

function Item:InstrumentType()
	return self.item_db.bardtype
end

function Item:INT()
	return self.item_db.aint
end

function Item:Name()
	return self.item_db.name
end

function Item:NoRent()
	return self.item_db.norent == 0
end

function Item:Quest()
	return (self.item_db.questitemflag or 0) > 0
end

function Item:RecommendLevel()
	return self.item_db.reclevel
end

function Item:RequiredLevel()
	return self.item_db.reqlevel
end

function Item:SellPrice()
	return nil
end

function Item:StackSize()
	return self.item_db.stacksize
end

function Item:Tradeskills()
	return (self.item_db.tradeskills or 0) > 0
end

function Item:Type()
	local itemtype = self.item_db.itemtype
	if itemtype == nil then
		return nil
	end
	return ItemTypes[itemtype + 1]
end

function Item:Value()
	return self.item_db.price
end

function Item:WornSlot(slot)
	if type(slot) ~= "string" then
		return false
	end

	local slots = parseFlags(self.item_db.slots, InventorySlots)
	for i = 1, #slots do
		if slots[i]:find(slot) then
			return true
		end
	end

	return false
end

function Item:WornSlots()
	local slots = parseFlags(self.item_db.slots, InventorySlots)
	return #slots
end

return Item