if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_beacon_hacker")
	resource.AddFile("materials/vgui/ttt/hud_icon_beacon_hacker.png")

	util.AddNetworkString("TTT2BhackerBrought")
end

BHACKER = CLIENT and {}

local bhacker_controls = {
	{name = "on", default = false},
	{name = "cloak", default = true},
	{name = "alerts", default = false},
	{name = "spy", default = true},
	{name = "emp", default = false}
}

local materialIconDisguiser = Material("vgui/ttt/hudhelp/item_disguiser")

ITEM.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}

if CLIENT then
    local trans --rights!

    ITEM.EquipMenuData = {
        type = "item_passive",
        name = "item_beacon_hacker",
        desc = "item_beacon_hacker_desc"
    }
    
    
    ITEM.hud = Material("vgui/ttt/hud_icon_beacon_hacker.png")
    ITEM.material = "vgui/ttt/icon_beacon_hacker"

    function ITEM:DrawInfo()
		return LocalPlayer():GetNWBool("bhacker_on") and "status_on" or "status_off"
	end

    function BHACKER.CreateMenu(parent)
        trans = trans or LANG.GetTranslation

		local dform = vgui.Create("DForm", parent)
		dform:SetName(trans("bhacker_menutitle"))
		dform:StretchToParent(0, 0, 0, 0)
		dform:SetAutoSize(false)

		local owned = LocalPlayer():HasEquipmentItem("item_beacon_hacker")

		if not owned then
			dform:Help(trans("bhacker_not_owned"))

			return dform
		end

		for _, control in pairs(bhacker_controls) do

			local ControlName = "bhacker_" .. control.name

			local dcheck = vgui.Create("DCheckBoxLabel", dform)
			dcheck:SetText(trans("label_" .. ControlName))
			dcheck:SetIndent(5)
			dcheck:SetValue(LocalPlayer():GetNWBool(ControlName, control.default))
			dcheck.controlname = ControlName
			dcheck.OnChange = function(s, val)
				RunConsoleCommand("ttt_set_" .. s.controlname, val and "1" or "0")
				--ply:SetNWBool(s.controlname, val)
			end
			dform:AddItem(dcheck)
		end

		--dform:Help(trans("bhacker_help1"))
		--dform:Help(trans("bhacker_help2"))
		dform:SetVisible(true)

		return dform
    end

    hook.Add("TTTEquipmentTabs", "TTTItemBeaconHacker", function(dsheet)
		trans = trans or LANG.GetTranslation

		if not LocalPlayer():HasEquipmentItem("item_beacon_hacker") then return end

		local dbhacker = BHACKER.CreateMenu(dsheet)

		dsheet:AddSheet(trans("bhacker_name"), dbhacker, "icon16/user.png", false, false, trans("equip_tooltip_bhacker"))
	end)


    --hook.Add("TTT2FinishedLoading", "TTTItemBeaconHackerInitStatus", function()
	--	bind.Register("ttt2_bhacker_menu", function()
	--		--TODO navigate to our tab
	--		RunConsoleCommand("ttt_cl_traitorpopup")
	--	end,
	--	nil, "header_bindings_ttt2", "label_bind_bhacker", KEY_PAD_ENTER)
	--
	--	keyhelp.RegisterKeyHelper("ttt2_bhacker_menu", materialIconDisguiser, KEYHELP_EQUIPMENT, "label_keyhelper_beacon_hacker", function(client)
	--		if client:IsSpec() or not client:HasEquipmentItem("item_beacon_hacker") then return end
	--
	--		return true
	--	end)
	--end)

	net.Receive("TTT2BhackerBrought", function()
		RunConsoleCommand("ttt_cl_traitorpopup_close")
		RunConsoleCommand("ttt_cl_traitorpopup_tab", trans("bhacker_menutitle"))
	end)

end



if SERVER then

    function ITEM:Equip(buyer)
		for _, control in pairs(bhacker_controls) do
			local ControlName = "bhacker_" .. control.name
			buyer:SetNWBool(ControlName, control.default)
		end

		net.Start("TTT2BhackerBrought")
		net.Send(buyer)

	end

	function ITEM:Reset(ply)
		ply:SetNWBool("bhacker_on", false)

		--local foundBinds = bind.FindAll("ttt2_bhacker_menu")
		--local foundBindsCount = #foundBinds
		--for i = 1, foundBindsCount do
		--	bind.Remove(foundBinds[i], name, persistent)
		--end

	end


    local function SetBhackerControl(ply, cmd, args)
		if not IsValid(ply) or not ply:IsActive() or not ply:HasEquipmentItem("item_beacon_hacker") then return end

		local state = #args == 1 and tobool(args[1])

		local i, _ = string.find(cmd, "bhacker_")

		local control = string.sub(cmd, i)

		print(control)

		ply:SetNWBool(control, state)

		if control == "bhacker_on" then
			LANG.Msg(ply, state and "bhacker_turned_on" or "bhacker_turned_off", nil, MSG_MSTACK_ROLE)
		end

	end

    for _, control in pairs(bhacker_controls) do
		concommand.Add("ttt_set_bhacker_" .. control.name, SetBhackerControl)
	end

	hook.Add("TTT2PlayerReady", "TTTItemBeaconHackerPlayerReady", function(ply)
		ply:SetNWVarProxy("bhacker_on", function(ent, name, old, new)
			if not IsValid(ent) or not ent:IsPlayer() then return end

			if new then
				STATUS:AddStatus(ent, "item_beacon_hacker_status")
			else
				STATUS:RemoveStatus(ent, "item_beacon_hacker_status")
			end
		end)
	end)

end


-- THE TODO LIST

--- remove keybinding when no longer have the equipment
--- 
--- Icons