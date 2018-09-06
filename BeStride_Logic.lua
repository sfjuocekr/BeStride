BeStride_Logic = {}

local class = UnitClass("player")
local canRepair = false


function BeStride:Mount(flags)
	
end

function BeStride:buildMountTables()
	BeStride:BuildMasterMountTable()
	BeStride:LoadMountTables()
end

function BeStride:AddNewMount(mountId)
	local name,spellID,_,_,_,_,_,isFactionSpecific,faction,isCollected,_ = C_MountJournal.GetMountInfoByID(value)
	local _,description,_,_,mountTypeID,_ = C_MountJournal.GetMountInfoExtraByID(value)
			
	if isFactionSpecific then
		faction = faction
	else
		faction = ""
	end

	mountTable["master"][mountId] = {
		["name"] = name,
		["spellID"] = spellID,
		["factionLocked"] = isFactionSpecific,
		["faction"] = faction,
		["description"] = description,
		["type"] = mountTypes[mountTypeID],
	}
	
	
end

function BeStride:BuildMasterMountTable()
	for key,value in pairs(C_MountJournal.GetMountIDs()) do
		local name,spellID,_,_,_,_,_,isFactionSpecific,faction,isCollected,_ = C_MountJournal.GetMountInfoByID(value)
		
		if isCollected then
			local _,description,_,_,mountTypeID,_ = C_MountJournal.GetMountInfoExtraByID(value)
			
			if isFactionSpecific then
				faction = faction
			else
				faction = ""
			end
			
			mountTable["master"][mountId] = {
				["name"] = name,
				["spellID"] = spellID,
				["factionLocked"] = isFactionSpecific,
				["faction"] = faction,
				["description"] = description,
				["type"] = mountTypes[mountTypeID],
			}
		end
	end
end

function BeStride:LoadMountTables()
	mountTable["ground"] = {}
	mountTable["flying"] = {}
	mountTable["swimming"] = {}
	mountTable["passenger"] = {}
	mountTable["repair"] = {}
	for key,value in pairs(mountTable["master"]) do
		BeStride:AddCommonMount(key)
		BeStride:AddPassengerMount(key)
		BeStride:AddRepairMount(key)
	end
end

function BeStride:AddCommonMount(mountId)
	local mount = mountTable["master"][mountId]
	if mountTypes[mount["type"]] == "ground" then
		table.insert(mountTable["ground"],key)
	elseif mountTypes[mount["type"]] == "flying" then
		table.insert(mountTable["flying"],key)
	elseif mountTypes[mount["type"]] == "swimming" then
		table.insert(mountTable["swimming"],key)
	end
end

function BeStride:AddPassengerMount(mountId)
	if mountData[mountId]["type"] == "passenger" then
		table.insert(mountTable["passenger"],mountId)
	end
end

function BeStride:AddRepairMount()
	if mountData[mountId]["repair"] then
		table.insert(mountTable["repair"],mountId)
	end
end

function BeStride:GetRidingSkill()
	
end

function BeStride:IsFlyableArea()
	local mapID = C_Map.GetBestMapForUnit(unitToken)
	local zone = BeStride:GetMapUntil(mapID,3)
	local continent = BeStride:GetMapUntil(mapID,2)
	
	-- Northrend Flying
	-- Mists Flying
	
	-- Draenor Flying
	if ( continent["name"] == "Draenor"  and not IsSpellKnown(191645)) then
		return false
	end
	
	-- Legion Flying
	if ( continent["name"] == "Broken Isles" and not IsSpellKnown(233368) ) then
		return false
	end
	
	-- Wintergrasp Flying
	if zone == "Wintergrasp" then 
		return not BeStride:WGActive()
	end
end

function BeStride:WGActive()
	return true
end

function BeStride:GetMapUntil(locID,filter)
	local map = C_Map.GetMapInfo(locID)
	
	if map["mapType"] ~= filter then
		return BeStride:GetMap(map["parentMapID"])
	else
		return map
	end
end

function BeStride_Logic:MountButton()
	local loanedMount = BeStride_Logic:CheckLoanerMount()
	local class = UnitClass("player")
	
	-- Dismount Logic
	-- This Logic needs to be cleaned up more
	if IsMounted() and IsFlying() and BeStride_Logic:IsFlyable() then
		if BeStride_Logic:IsDruid() then
			if BeStride_Logic:DruidFlyingMTFF() then
				BeStride_Mount:DruidFlying()
			elseif BeStride_Logic:NoDismountWhileFlying() then
				BeStride_Mount:Regular()
			else
				Dismount()
				BeStride_Mount:Regular()
			end
		elseif BeStride_Logic:IsPriest() then
			if BeStride_Logic:PriestCanLevitate() then
				BeStride_Mount:PriestLevitate()
			elseif BeStride_Logic:NoDismountWhileFlying() then
				BeStride_Mount:Regular()
			else
				Dismount()
				BeStride_Mount:Regular()
			end
		end
	-- Todo: Cleanup from here
	elseif IsMounted() then
		if IsSwimming() and Bestride_Logic:IsDruid() and BeStride_Logic:DruidCanSwim() and BeStride_Logic:MovementCheck() then -- Todo: Clean this logic up
			BeStride_Mount:DruidAuquaticForm()
		elseif IsSwimming() then
			BeStride_Mount:Swimming()
		else
			Dismount()
			BeStride_Mount:Regular()
		end
	elseif CanExitVehicle() then
		VehicleExit()
		BeStride_Mount:Regular()
	elseif BeStride_Logic:IsMonk() and BeStride_Logic:IsFlyable() and BeStride:MonkCanZen() then
		BeStride_Mount:MonkZen()
	elseif BeStride_Logic:IsPriest() and BeStride_Logic:CanLevitate() and ( BeStride_Logic:IsFalling() or BeStride_Logic:MovementCheck() ) then
		BeStride_Mount:PriestLevitate()
	elseif BeStride_Logic:IsPriest() and BeStride_Logic:CanSlowFall() and ( BeStride_Logic:IsFalling() or BeStride_Logic:MovementCheck() ) then
		BeStride_Mount:MageSlowFall()
	elseif BeStride_Logic:IsFlyable() and IsOutdoors() then
		if BeStride_Logic:CanBroom() then
			BeStride_Mount:Broom()
		elseif IsSwimming() then
			BeStride_Mount:Swimming()
		elseif BeStride_Logic:IsDruid() then
			BeStride_Mount:DruidFlying()
		else
			BeStride_Mount:Flying()
		end
	elseif not BeStride_Logic:IsFlyable() and IsOutdoors() then
		if zone == BestrideLocale.Zone.Oculus and Bestride:Filter(nil, zone) then
		elseif BeStride_Logic:CanBroom() then
			BeStride_Mount:Broom()
		elseif IsSwimming() then
			BeStride_Mount:Swimming()
		elseif BeStride_Logic:HasLoanedMount() then
			BeStride_Mount:LoanedMount()
		elseif BeStride_Logic:IsDruid() then
			BeStride_Mount:Druid()
		end
	elseif not IsOutdoors() then
		if IsSwimming() then
			BeStride_Mount:Swimming()
		elseif BeStride_Logic:IsDruid() then
			BeStride_Logic:Druid()
		end
	else
		BeStride_Logic:Regular()
	end
end

function BeStride_Logic:RegularMount()
end

-- Checks Player Speed
-- Returns: integer
function BeStride_Logic:MovementCheck()
	if BeStride_Logic:SpeedCheck() ~= 0 then
		return true
	else
		return false
	end
end

-- Checks Player Speed
-- Returns: integer
function BeStride_Logic:SpeedCheck()
	return GetUnitSpeed("player")
end

function BeStride_Logic:IsFlyable()
	if IsFlyableArea() and BeStride_Logic:IsFlyableArea() then
		return true
	else
		return false
	end
end

function BeStride_Logic:IsFalling()
	return IsFalling()
end

-- +------------+ --
-- Special Checks --
-- +------------+ --

function BeStride_Logic:CheckLoanerMount()
	return false
	--local zone = GetRealZoneText()
	--if zone == BestrideLocale.Zone.Dalaran then
	--	local subzone = GetSubZoneText()
	--	if subzone == BestrideLocale.Zone.DalaranSubZone.Underbelly or
	--			subzone == BestrideLocale.Zone.DalaranSubZone.UnderbellyDescent or
	--			subzone == BestrideLocale.Zone.DalaranSubZone.CircleofWills or
	--			subzone == BestrideLocale.Zone.DalaranSubZone.BlackMarket then
	--		if GetItemCount(139421, false) > 0 then
	--			return 139421
	--		else
	--			return nil
	--		end
	--	else
	--		return nil
	--	end
	--elseif zone == BestrideLocale.Zone.StormPeaks or zone == BestrideLocale.Zone.Icecrown then
	--	if GetItemCount(44221, false) > 0 then
	--		return 44221
	--	elseif GetItemCount(44229, false) > 0 then
	--		return 44229
	--	else
	--		return nil
	--	end
	--end
	--return nil
end

-- Check whether we can dismount while flying
-- Returns: boolean
function BeStride_Logic:NoDismountWhileFlying()
	-- Todo: Bitwise Compare
	if BeStride.db.profile.settings["nodismountwhileflying"] then
		return true
	else
		return false
	end
end

-- Check whether we force a repair mount
-- Returns: boolean
function BeStride_Logic:ForceRepair()
	if BeStride.db.profile.settings["repair"]["force"] then
		return true
	else
		return false
	end
end

-- Checks whether we check to repair or not
-- Returns: boolean
function BeStride_Logic:UseRepair()
	if BeStride.db.profile.settings["repair"]["use"] then
		return true
	else
		return false
	end
end

-- Get repair threshold
-- Returns: signed integer
function BeStride_Logic:GetRepairThreshold()
	if BeStride.db.profile.settings["repair"]["durability"] then
		return BeStride.db.profile.settings["repair"]["durability"]
	else
		return -1
	end
end

-- Check whether we can repair
-- Returns: boolean
function BeStride_Logic:CanRepair()
	if canRepair then
		return true
	end
	
	if BeStride_Mount:CountRepairMounts() > 0 then
	end
	
	return false
end

-- Check whether we need to repair
-- Returns: boolean
function BeStride_Logic:NeedToRepair()
	if BeStride_Logic:ForceRepair() then
		return true
	end
	
	if size(BeStride.db.profile.misc.RepairMounts) > 0 and BeStride_Logic:UseRepair() then
		for i = 0, 17 do
			local current, maximum = GetInventoryItemDurability(i)
			if current ~= nil and maximum ~= nil and ( (current/maximum) <= BeStride_Logic:GetRepairThreshold() ) then
				return true
			end
		end
	end
	
	return false
end

-- +----------+ --
-- Class Checks --
-- +----------+ --

-- Check for Druid
function BeStride_Logic:IsDruid()
	if class["class"] == "DRUID" then
		return true
	else
		return false
	end
end

-- Check for Mage
function BeStride_Logic:IsMage()
	if class["class"] == "MAGE" then
		return true
	else
		return false
	end
end

-- Check for Priest
function BeStride_Logic:IsPriest()
	if class["class"] == "PRIEST" then
		return true
	else
		return false
	end
end

-- Check for Monk
function BeStride_Logic:IsMonk()
	if class["class"] == "MONK" then
		return true
	else
		return false
	end
end

-- Check for DeathKnight
function BeStride_Logic:IsDeathKnight()
end

-- +--------------------------+ --
-- Class Specific Spells Checks --
-- +--------------------------+ --
-- ------------ --
-- Druid Spells --
-- ------------ --

-- Check for Swim Form
-- Returns: boolean
function BeStride_Logic:DruidCanSwim()
	if IsUsableSpell(783) then
		return true
	else
		return false
	end
end

-- Check for Travel Form
-- Returns: boolean
function BeStride_Logic:DruidCanTravel()
	if IsUsableSpell(783) then
		return true
	else
		return false
	end
end

-- Check for Travel Form
-- Returns: boolean
function BeStride_Logic:DruidCanCat()
	if IsUsableSpell(783) then
		return true
	else
		return false
	end
end

-- Check for Flight Form
-- Returns: boolean
function BeStride_Logic:DruidCanFly()
	if IsUsableSpell(783) then
		return true
	else
		return false
	end
end


-- +-------------------------+ --
-- Class Specific Mount Checks --
-- +-------------------------+ --

-- ----- --
-- Druid --
-- ----- --

-- Check for Flying, Mounted and Mount to Flight Form
-- Returns: boolean
function BeStride_Logic:DruidFlyingMTFF()
	-- Had a "GetUnitSpeed("player") ~= 0", unsure if we want to go with that
	-- Todo: Bitwise Compare
	if BeStride.db.profile.settings["classes"]["druid"]["mountedtoflightform"] then
		return true
	else
		return false
	end
end